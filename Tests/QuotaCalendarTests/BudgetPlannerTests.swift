import XCTest
@testable import QuotaCalendar

final class BudgetPlannerTests: XCTestCase {
    func testRecentSpeedPredictsWhenTodaysAverageQuotaRunsOut() throws {
        let calendar = Calendar(identifier: .gregorian)
        let reset = Date(timeIntervalSince1970: 1_800_000_000)
        let now = reset.addingTimeInterval(-5 * 24 * 60 * 60)
        let dayStart = calendar.startOfDay(for: now)
        let samples = [
            UsageSample(capturedAt: dayStart, weeklyUsedPercent: 20),
            UsageSample(capturedAt: now.addingTimeInterval(-10 * 60), weeklyUsedPercent: 23),
            UsageSample(capturedAt: now, weeklyUsedPercent: 25)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 25,
            fiveHourUsedPercent: 10,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.todayUsedPercent, 5, accuracy: 0.001)
        XCTAssertEqual(plan.todayBaselineWeeklyUsedPercent, 20, accuracy: 0.001)
        XCTAssertEqual(plan.todayRemainingAllowancePercent, 10, accuracy: 0.001)
        XCTAssertEqual(plan.halfHourUsagePercentPerHour, 8.063, accuracy: 0.001)
        XCTAssertEqual(plan.recentUsagePercentPerDay, 193.516, accuracy: 0.001)
        let exhaustion = try XCTUnwrap(plan.predictedDailyAllowanceExhaustionAt)
        XCTAssertEqual(exhaustion.timeIntervalSince(now), 4464.752, accuracy: 1)
    }

    func testUsageSpeedUsesWeightedAverageOfRecentFiveIntervals() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let samples = [
            UsageSample(capturedAt: now.addingTimeInterval(-150 * 60), weeklyUsedPercent: 10),
            UsageSample(capturedAt: now.addingTimeInterval(-120 * 60), weeklyUsedPercent: 11),
            UsageSample(capturedAt: now.addingTimeInterval(-90 * 60), weeklyUsedPercent: 13),
            UsageSample(capturedAt: now.addingTimeInterval(-60 * 60), weeklyUsedPercent: 16),
            UsageSample(capturedAt: now.addingTimeInterval(-30 * 60), weeklyUsedPercent: 20),
            UsageSample(capturedAt: now, weeklyUsedPercent: 25)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 24,
            fiveHourUsedPercent: 6,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.halfHourUsagePercentPerHour, 7.333, accuracy: 0.001)
        XCTAssertEqual(plan.recentUsagePercentPerDay, 176, accuracy: 0.001)
    }

    func testDailyBaselineResetsToFirstSampleOfEachLocalDay() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let samples = [
            UsageSample(capturedAt: yesterdayStart.addingTimeInterval(12 * 60 * 60), weeklyUsedPercent: 18),
            UsageSample(capturedAt: todayStart.addingTimeInterval(30 * 60), weeklyUsedPercent: 21),
            UsageSample(capturedAt: now, weeklyUsedPercent: 24)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 24,
            fiveHourUsedPercent: 6,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.todayBaselineWeeklyUsedPercent, 21, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 3, accuracy: 0.001)
    }

    func testDailyBaselineIgnoresOldCycleSamplesWhenWeeklyResetHappenedToday() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let cycleStart = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1, hour: 10))!
        let now = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1, hour: 15))!
        let reset = calendar.date(byAdding: .day, value: 7, to: cycleStart)!
        let todayStart = calendar.startOfDay(for: now)
        let samples = [
            UsageSample(capturedAt: todayStart.addingTimeInterval(60 * 60), weeklyUsedPercent: 95),
            UsageSample(capturedAt: cycleStart.addingTimeInterval(60), weeklyUsedPercent: 0),
            UsageSample(capturedAt: now, weeklyUsedPercent: 3)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 3,
            fiveHourUsedPercent: 6,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.todayBaselineWeeklyUsedPercent, 0, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 3, accuracy: 0.001)
    }

    func testWeeklyResetTodayStartsDailyUsageFromZeroWithoutResetSample() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let cycleStart = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1, hour: 10))!
        let now = calendar.date(from: DateComponents(year: 2026, month: 6, day: 1, hour: 18))!
        let reset = calendar.date(byAdding: .day, value: 7, to: cycleStart)!
        let samples = [
            UsageSample(capturedAt: now.addingTimeInterval(-30 * 60), weeklyUsedPercent: 5),
            UsageSample(capturedAt: now, weeklyUsedPercent: 6)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 6,
            fiveHourUsedPercent: 24,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.dailyAllowancePercent, 13.428, accuracy: 0.001)
        XCTAssertEqual(plan.todayBaselineWeeklyUsedPercent, 0, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 6, accuracy: 0.001)
        XCTAssertEqual(plan.todayBudgetUsedPercent, 44.681, accuracy: 0.001)
        XCTAssertEqual(plan.budgetDays[0].usedPercent, 6, accuracy: 0.001)
        XCTAssertEqual(plan.budgetDays[0].budgetUsagePercent, 44.681, accuracy: 0.001)
    }

    func testMissingDailyBaselineStartsFromCurrentWeeklyValue() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 24,
            fiveHourUsedPercent: 6,
            samples: [],
            calendar: calendar
        )

        XCTAssertEqual(plan.todayBaselineWeeklyUsedPercent, 24, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 0, accuracy: 0.001)
    }

    func testUsageSpeedCanUseSavedSamplesBeforeCurrentAppWindow() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let sessionStart = now.addingTimeInterval(-10 * 60)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let samples = [
            UsageSample(capturedAt: sessionStart.addingTimeInterval(-60), weeklyUsedPercent: 12),
            UsageSample(capturedAt: now, weeklyUsedPercent: 15)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 15,
            fiveHourUsedPercent: 5,
            samples: samples,
            speedWindowStartedAt: sessionStart,
            calendar: calendar
        )

        XCTAssertEqual(plan.halfHourUsagePercentPerHour, 16.364, accuracy: 0.001)
        XCTAssertNotNil(plan.predictedDailyAllowanceExhaustionAt)
    }

    func testWorkHoursSplitDailyBudgetIntoHourlyBudget() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(4 * 24 * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 20,
            fiveHourUsedPercent: 4,
            samples: [],
            workHoursPerDay: 8,
            calendar: calendar
        )

        XCTAssertEqual(plan.dailyAllowancePercent, 20, accuracy: 0.001)
        XCTAssertEqual(plan.workHoursPerDay, 8, accuracy: 0.001)
        XCTAssertEqual(plan.hourlyBudgetPercent, 2.5, accuracy: 0.001)
    }

    func testUnusedAverageQuotaCarriesIntoRemainingDays() {
        let calendar = Calendar(identifier: .gregorian)
        let reset = Date(timeIntervalSince1970: 1_800_000_000)
        let now = reset.addingTimeInterval(-5 * 24 * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 20,
            fiveHourUsedPercent: 10,
            samples: [],
            calendar: calendar
        )

        XCTAssertEqual(plan.baseDailyAllowancePercent, 100.0 / 7.0, accuracy: 0.001)
        XCTAssertEqual(plan.pacingBalancePercent, 8.571, accuracy: 0.001)
        XCTAssertGreaterThan(plan.dailyAllowancePercent, plan.baseDailyAllowancePercent)
        XCTAssertEqual(plan.dailyAllowancePercent, 16, accuracy: 0.001)
    }

    func testOverusedAverageQuotaReducesRemainingDays() {
        let calendar = Calendar(identifier: .gregorian)
        let reset = Date(timeIntervalSince1970: 1_800_000_000)
        let now = reset.addingTimeInterval(-5 * 24 * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 40,
            fiveHourUsedPercent: 10,
            samples: [],
            calendar: calendar
        )

        XCTAssertEqual(plan.baseDailyAllowancePercent, 100.0 / 7.0, accuracy: 0.001)
        XCTAssertEqual(plan.pacingBalancePercent, -11.429, accuracy: 0.001)
        XCTAssertLessThan(plan.dailyAllowancePercent, plan.baseDailyAllowancePercent)
        XCTAssertEqual(plan.dailyAllowancePercent, 12, accuracy: 0.001)
    }

    func testProjectedRunoutDoesNotWarnBeforeLastTenPercentOfTodayBudget() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(3 * 24 * 60 * 60)
        let snapshots = [
            UsageSample(capturedAt: now.addingTimeInterval(-10 * 60), weeklyUsedPercent: 68),
            UsageSample(capturedAt: now, weeklyUsedPercent: 70)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 70,
            fiveHourUsedPercent: 30,
            samples: snapshots,
            calendar: calendar
        )

        XCTAssertEqual(plan.weeklyRemainingPercent, 30, accuracy: 0.001)
        XCTAssertEqual(plan.dailyAllowancePercent, 10, accuracy: 0.001)
        XCTAssertEqual(plan.recentUsagePercentPerDay, 288, accuracy: 0.001)
        XCTAssertEqual(plan.risk, .good)
        XCTAssertNotNil(plan.predictedExhaustionAt)
        XCTAssertLessThan(plan.predictedExhaustionAt!, reset)
    }

    func testTodayRiskTurnsCriticalOnlyInLastTenPercentOfDailyBudget() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(3 * 24 * 60 * 60)
        let todayStart = calendar.startOfDay(for: now)
        let samples = [
            UsageSample(capturedAt: todayStart, weeklyUsedPercent: 61),
            UsageSample(capturedAt: now, weeklyUsedPercent: 70)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 70,
            fiveHourUsedPercent: 30,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.dailyAllowancePercent, 10, accuracy: 0.001)
        XCTAssertEqual(plan.todayRemainingAllowancePercent, 1, accuracy: 0.001)
        XCTAssertEqual(plan.risk, .critical)
    }

    func testLowUsageStaysInGoodRiskLevel() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(6 * 24 * 60 * 60)
        let samples = [
            UsageSample(capturedAt: now.addingTimeInterval(-24 * 60 * 60), weeklyUsedPercent: 9),
            UsageSample(capturedAt: now, weeklyUsedPercent: 10)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 10,
            fiveHourUsedPercent: 8,
            samples: samples
        )

        XCTAssertEqual(plan.risk, .good)
        XCTAssertNotNil(plan.predictedExhaustionAt)
        XCTAssertGreaterThan(plan.predictedExhaustionAt!, reset)
    }

    func testRemainingBudgetDaysStartTodayAndUseTodayBudgetUsage() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        let samples = [
            UsageSample(capturedAt: yesterdayStart.addingTimeInterval(60 * 60), weeklyUsedPercent: 10),
            UsageSample(capturedAt: yesterdayStart.addingTimeInterval(2 * 60 * 60), weeklyUsedPercent: 15),
            UsageSample(capturedAt: todayStart.addingTimeInterval(60 * 60), weeklyUsedPercent: 15),
            UsageSample(capturedAt: now, weeklyUsedPercent: 18)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 18,
            fiveHourUsedPercent: 2,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.budgetDays.count, 5)
        XCTAssertEqual(plan.activeBudgetDayCount, 5)
        XCTAssertEqual(plan.budgetDays.first?.date, todayStart)
        XCTAssertEqual(plan.budgetDays.last?.date, calendar.date(byAdding: .day, value: 4, to: todayStart))
        XCTAssertEqual(plan.budgetDays[0].usedPercent, 3, accuracy: 0.001)
        XCTAssertEqual(plan.budgetDays[0].budgetUsagePercent, 18.293, accuracy: 0.001)
        XCTAssertEqual(plan.budgetDays[1].usedPercent, 0, accuracy: 0.001)
    }

    func testSkippedBudgetDayRebalancesDailyAllowance() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 20,
            fiveHourUsedPercent: 2,
            samples: [],
            excludedDayIDs: [BudgetPlanner.dayID(for: tomorrow, calendar: calendar)],
            calendar: calendar
        )

        XCTAssertEqual(plan.budgetDays.count, 5)
        XCTAssertEqual(plan.activeBudgetDayCount, 4)
        XCTAssertEqual(plan.dailyAllowancePercent, 20, accuracy: 0.001)
        XCTAssertTrue(plan.budgetDays[1].isExcluded)
    }

    func testFractionalResetTimeUsesVisibleRemainingCalendarDays() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval((6 * 24 + 19) * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 2,
            fiveHourUsedPercent: 9,
            samples: [],
            calendar: calendar
        )

        XCTAssertEqual(plan.budgetDays.count, 7)
        XCTAssertEqual(plan.dailyAllowancePercent, 14, accuracy: 0.001)
    }
}
