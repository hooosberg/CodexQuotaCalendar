import Foundation

enum BudgetPlanner {
    static func makePlan(
        now: Date,
        resetAt: Date,
        weeklyUsedPercent: Double,
        fiveHourUsedPercent: Double,
        samples: [UsageSample],
        excludedDayIDs: Set<String> = [],
        speedWindowStartedAt: Date? = nil,
        workHoursPerDay: Double = 8,
        calendar: Calendar = .current
    ) -> BudgetPlan {
        let weeklyUsed = clamp(weeklyUsedPercent)
        let fiveHourUsed = clamp(fiveHourUsedPercent)
        let workHours = min(16, max(1, workHoursPerDay))
        let weeklyRemaining = max(0, 100 - weeklyUsed)
        let fiveHourRemaining = max(0, 100 - fiveHourUsed)
        let cycleDays = 7.0
        let baseDailyAllowance = 100 / cycleDays
        let budgetDates = remainingBudgetDates(now: now, resetAt: resetAt, calendar: calendar)
        let budgetDayIDs = Set(budgetDates.map { dayID(for: $0, calendar: calendar) })
        var effectiveExcludedDayIDs = excludedDayIDs.intersection(budgetDayIDs)
        if effectiveExcludedDayIDs.count >= budgetDates.count,
           let todayID = budgetDates.first.map({ dayID(for: $0, calendar: calendar) }) {
            effectiveExcludedDayIDs.remove(todayID)
        }
        let activeBudgetDayCount = max(1, budgetDates.filter { !effectiveExcludedDayIDs.contains(dayID(for: $0, calendar: calendar)) }.count)
        let cycleStart = resetAt.addingTimeInterval(-cycleDays * 86_400)
        let elapsedCycleDays = min(cycleDays, max(0, now.timeIntervalSince(cycleStart) / 86_400))
        let idealUsedByNow = baseDailyAllowance * elapsedCycleDays
        let pacingBalance = idealUsedByNow - weeklyUsed
        let dailyAllowance = weeklyRemaining / Double(activeBudgetDayCount)
        let todayBaseline = todayBaselineWeeklyUsedPercent(
            now: now,
            weeklyUsed: weeklyUsed,
            samples: samples,
            cycleStart: cycleStart,
            calendar: calendar
        )
        let todayUsed = max(0, weeklyUsed - todayBaseline)
        let todayRemaining = max(0, dailyAllowance - todayUsed)
        let todayBudgetUsed = dailyAllowance > 0 ? (todayUsed / dailyAllowance) * 100 : 100
        let todayBudgetRemaining = max(0, 100 - todayBudgetUsed)
        let hourlyBudget = dailyAllowance / workHours
        let hourlyBudgetShare = 100 / workHours
        let halfHourSpeed = weightedRecentUsagePercentPerHour(
            now: now,
            samples: samples,
            cycleStart: cycleStart,
            speedWindowStartedAt: speedWindowStartedAt
        )
        let halfHourBudgetSpeed = dailyAllowance > 0 ? (halfHourSpeed / dailyAllowance) * 100 : 0
        let recentSpeed = halfHourSpeed * 24
        let predictedDailyAllowanceExhaustion = predictedDailyAllowanceExhaustionDate(
            now: now,
            remainingToday: todayRemaining,
            speedPerHour: halfHourSpeed
        )
        let predictedExhaustion = predictedExhaustionDate(now: now, remaining: weeklyRemaining, speedPerDay: recentSpeed)
        let risk = riskLevel(
            dailyAllowance: dailyAllowance,
            todayRemaining: todayRemaining
        )

        return BudgetPlan(
            now: now,
            resetAt: resetAt,
            weeklyUsedPercent: weeklyUsed,
            fiveHourUsedPercent: fiveHourUsed,
            weeklyRemainingPercent: weeklyRemaining,
            fiveHourRemainingPercent: fiveHourRemaining,
            baseDailyAllowancePercent: baseDailyAllowance,
            dailyAllowancePercent: dailyAllowance,
            pacingBalancePercent: pacingBalance,
            todayBaselineWeeklyUsedPercent: todayBaseline,
            todayUsedPercent: todayUsed,
            todayRemainingAllowancePercent: todayRemaining,
            todayBudgetUsedPercent: todayBudgetUsed,
            todayBudgetRemainingPercent: todayBudgetRemaining,
            workHoursPerDay: workHours,
            hourlyBudgetPercent: hourlyBudget,
            hourlyBudgetSharePercent: hourlyBudgetShare,
            halfHourUsagePercentPerHour: halfHourSpeed,
            halfHourBudgetSpeedPercentPerHour: halfHourBudgetSpeed,
            recentUsagePercentPerDay: recentSpeed,
            predictedDailyAllowanceExhaustionAt: predictedDailyAllowanceExhaustion,
            predictedExhaustionAt: predictedExhaustion,
            risk: risk,
            activeBudgetDayCount: activeBudgetDayCount,
            budgetDays: makeBudgetDays(
                dates: budgetDates,
                now: now,
                weeklyUsed: weeklyUsed,
                samples: samples,
                excludedDayIDs: effectiveExcludedDayIDs,
                dailyBudgetPercent: dailyAllowance,
                cycleStart: cycleStart,
                calendar: calendar
            ),
            monthHeatmap: makeMonthHeatmap(now: now, weeklyUsed: weeklyUsed, speed: recentSpeed, calendar: calendar)
        )
    }

    static func dayID(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            components.year ?? 0,
            components.month ?? 0,
            components.day ?? 0
        )
    }

    private static func clamp(_ value: Double) -> Double {
        min(100, max(0, value))
    }

    private static func todayBaselineWeeklyUsedPercent(
        now: Date,
        weeklyUsed: Double,
        samples: [UsageSample],
        cycleStart: Date,
        calendar: Calendar
    ) -> Double {
        let startOfDay = calendar.startOfDay(for: now)
        if cycleStart >= startOfDay && cycleStart <= now {
            return 0
        }
        let baselineStart = maxDate(startOfDay, cycleStart)
        let daySamples = samples
            .filter { $0.capturedAt >= baselineStart && $0.capturedAt <= now }
            .sorted { $0.capturedAt < $1.capturedAt }
        return daySamples.first?.weeklyUsedPercent ?? weeklyUsed
    }

    private static func weightedRecentUsagePercentPerHour(
        now: Date,
        samples: [UsageSample],
        cycleStart: Date,
        speedWindowStartedAt _: Date?
    ) -> Double {
        let sortedSamples = samples
            .filter { $0.capturedAt >= cycleStart && $0.capturedAt <= now }
            .sorted { $0.capturedAt < $1.capturedAt }
            .reduce(into: [UsageSample]()) { uniqueSamples, sample in
                if uniqueSamples.last?.capturedAt == sample.capturedAt {
                    uniqueSamples[uniqueSamples.count - 1] = sample
                } else {
                    uniqueSamples.append(sample)
                }
            }
        guard sortedSamples.count >= 2 else { return 0 }

        let intervalSpeeds = zip(sortedSamples, sortedSamples.dropFirst()).compactMap { previous, current -> Double? in
            guard current.capturedAt > previous.capturedAt else { return nil }
            let deltaHours = current.capturedAt.timeIntervalSince(previous.capturedAt) / 3_600
            guard deltaHours > 0 else { return nil }
            return max(0, current.weeklyUsedPercent - previous.weeklyUsedPercent) / deltaHours
        }
        let recentSpeeds = Array(intervalSpeeds.suffix(5))
        guard !recentSpeeds.isEmpty else { return 0 }

        let weightedTotal = recentSpeeds.enumerated().reduce(0) { total, item in
            let weight = Double(item.offset + 1)
            return total + item.element * weight
        }
        let totalWeight = Double((1...recentSpeeds.count).reduce(0, +))
        return weightedTotal / totalWeight
    }

    private static func predictedExhaustionDate(now: Date, remaining: Double, speedPerDay: Double) -> Date? {
        guard speedPerDay > 0 else { return nil }
        return now.addingTimeInterval((remaining / speedPerDay) * 86_400)
    }

    private static func predictedDailyAllowanceExhaustionDate(
        now: Date,
        remainingToday: Double,
        speedPerHour: Double
    ) -> Date? {
        guard remainingToday > 0 else { return now }
        guard speedPerHour > 0 else { return nil }
        return now.addingTimeInterval((remainingToday / speedPerHour) * 3_600)
    }

    private static func riskLevel(
        dailyAllowance: Double,
        todayRemaining: Double
    ) -> RiskLevel {
        guard dailyAllowance > 0 else { return .critical }
        if todayRemaining <= dailyAllowance * 0.10 { return .critical }
        return .good
    }

    private static func maxDate(_ left: Date, _ right: Date?) -> Date {
        guard let right else { return left }
        return left > right ? left : right
    }

    private static func remainingBudgetDates(now: Date, resetAt: Date, calendar: Calendar) -> [Date] {
        let todayStart = calendar.startOfDay(for: now)
        let remainingDays = max(1, Int(ceil(max(0, resetAt.timeIntervalSince(now)) / 86_400)))
        return (0..<remainingDays).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: todayStart)
        }
    }

    private static func makeBudgetDays(
        dates: [Date],
        now: Date,
        weeklyUsed: Double,
        samples: [UsageSample],
        excludedDayIDs: Set<String>,
        dailyBudgetPercent: Double,
        cycleStart: Date,
        calendar: Calendar
    ) -> [BudgetDayPlan] {
        let todayStart = calendar.startOfDay(for: now)
        let sortedSamples = (samples + [UsageSample(capturedAt: now, weeklyUsedPercent: weeklyUsed)])
            .filter { $0.capturedAt <= now }
            .sorted { $0.capturedAt < $1.capturedAt }

        return dates.map { date in
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86_400)
            let windowEnd = min(dayEnd, now.addingTimeInterval(0.001))
            let used = date <= todayStart
                ? dailyUsedPercent(start: date, end: windowEnd, samples: sortedSamples, cycleStart: cycleStart)
                : 0
            let id = dayID(for: date, calendar: calendar)
            return BudgetDayPlan(
                dayID: id,
                date: date,
                isToday: calendar.isDate(date, inSameDayAs: now),
                isExcluded: excludedDayIDs.contains(id),
                dailyBudgetPercent: dailyBudgetPercent,
                usedPercent: used,
                budgetUsagePercent: dailyBudgetPercent > 0 ? (used / dailyBudgetPercent) * 100 : 0
            )
        }
    }

    private static func dailyUsedPercent(
        start: Date,
        end: Date,
        samples: [UsageSample],
        cycleStart: Date
    ) -> Double {
        let baselineStart = maxDate(start, cycleStart)
        let baseline: Double?
        if cycleStart >= start && cycleStart < end {
            baseline = 0
        } else {
            baseline = samples.last { $0.capturedAt <= baselineStart }?.weeklyUsedPercent
                ?? samples.first { $0.capturedAt >= baselineStart && $0.capturedAt < end }?.weeklyUsedPercent
        }
        guard let baseline else { return 0 }
        guard let endSample = samples.last(where: { $0.capturedAt < end }) else { return 0 }
        return max(0, endSample.weeklyUsedPercent - baseline)
    }

    private static func makeMonthHeatmap(
        now: Date,
        weeklyUsed: Double,
        speed: Double,
        calendar: Calendar
    ) -> [CalendarHeatmapDay] {
        let monthStartComponents = calendar.dateComponents([.year, .month], from: now)
        let monthStart = calendar.date(from: monthStartComponents) ?? calendar.startOfDay(for: now)
        let weekdayOffset = calendar.component(.weekday, from: monthStart) - calendar.firstWeekday
        let normalizedOffset = (weekdayOffset + 7) % 7
        let gridStart = calendar.date(byAdding: .day, value: -normalizedOffset, to: monthStart) ?? monthStart
        let currentMonth = calendar.component(.month, from: monthStart)

        return (0..<42).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: gridStart) ?? now
            let dayDistance = abs(calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: date).day ?? 0)
            let base = min(1, (weeklyUsed + speed * Double(max(0, 7 - dayDistance)) / 7) / 100)
            return CalendarHeatmapDay(
                date: date,
                intensity: base,
                isInCurrentMonth: calendar.component(.month, from: date) == currentMonth
            )
        }
    }
}
