import XCTest
@testable import QuotaCalendar

final class BudgetPlannerSmokeTests: XCTestCase {
    func testDailyBaselineMovesForwardWithRemainingWeeklyQuota() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = calendar.date(from: DateComponents(year: 2026, month: 5, day: 31, hour: 10))!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let reset = calendar.date(byAdding: .day, value: 6, to: today)!

        let todayPlan = BudgetPlanner.makePlan(
            now: today,
            resetAt: reset,
            weeklyUsedPercent: 10,
            fiveHourUsedPercent: 0,
            samples: [
                UsageSample(capturedAt: calendar.startOfDay(for: today), weeklyUsedPercent: 2),
                UsageSample(capturedAt: today, weeklyUsedPercent: 10)
            ],
            calendar: calendar
        )

        XCTAssertEqual(todayPlan.todayBaselineWeeklyUsedPercent, 2, accuracy: 0.001)
        XCTAssertEqual(todayPlan.weeklyRemainingPercent, 90, accuracy: 0.001)
        XCTAssertEqual(todayPlan.todayUsedPercent, 8, accuracy: 0.001)
        XCTAssertEqual(todayPlan.dailyAllowancePercent, 15, accuracy: 0.001)
        XCTAssertEqual(todayPlan.todayBudgetUsedPercent, 53.333, accuracy: 0.001)

        let tomorrowPlan = BudgetPlanner.makePlan(
            now: tomorrow,
            resetAt: reset,
            weeklyUsedPercent: 10,
            fiveHourUsedPercent: 0,
            samples: [
                UsageSample(capturedAt: calendar.startOfDay(for: tomorrow), weeklyUsedPercent: 10)
            ],
            calendar: calendar
        )

        XCTAssertEqual(tomorrowPlan.todayBaselineWeeklyUsedPercent, 10, accuracy: 0.001)
        XCTAssertEqual(tomorrowPlan.weeklyRemainingPercent, 90, accuracy: 0.001)
        XCTAssertEqual(tomorrowPlan.todayUsedPercent, 0, accuracy: 0.001)
        XCTAssertEqual(tomorrowPlan.dailyAllowancePercent, 18, accuracy: 0.001)
        XCTAssertEqual(tomorrowPlan.todayBudgetUsedPercent, 0, accuracy: 0.001)
    }

    func testCurrentScreenshotLikeNumbersAreCoincidentalNotTheSameFormula() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval((6 * 24 + 18) * 60 * 60)
        let samples = [
            UsageSample(capturedAt: now.addingTimeInterval(-2 * 60 * 60), weeklyUsedPercent: 1),
            UsageSample(capturedAt: now, weeklyUsedPercent: 3)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 3,
            fiveHourUsedPercent: 2,
            samples: samples,
            calendar: calendar
        )

        XCTAssertEqual(plan.weeklyRemainingPercent, 97, accuracy: 0.001)
        XCTAssertEqual(plan.budgetDays.count, 7)
        XCTAssertEqual(plan.activeBudgetDayCount, 7)
        XCTAssertEqual(plan.dailyAllowancePercent, 13.857, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 3, accuracy: 0.001)
        XCTAssertEqual(plan.todayBudgetUsedPercent, 21.649, accuracy: 0.001)
        XCTAssertEqual(QuotaTextFormatter.percent(plan.dailyAllowancePercent), "14%")
        XCTAssertEqual(QuotaTextFormatter.percent(plan.todayBudgetUsedPercent), "22%")
    }

    func testRemainingCalendarDaysDriveVisibleDayCountAndDailyShare() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 50,
            fiveHourUsedPercent: 0,
            samples: [],
            calendar: calendar
        )

        XCTAssertEqual(plan.budgetDays.count, 5)
        XCTAssertEqual(plan.activeBudgetDayCount, 5)
        XCTAssertEqual(plan.weeklyRemainingPercent, 50, accuracy: 0.001)
        XCTAssertEqual(plan.dailyAllowancePercent, 10, accuracy: 0.001)
    }

    func testSkippedFutureDaysRebalanceEveryRemainingActiveDay() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let today = calendar.startOfDay(for: now)
        let reset = now.addingTimeInterval(5 * 24 * 60 * 60)
        let skippedDays = Set([1, 3].map { offset in
            BudgetPlanner.dayID(
                for: calendar.date(byAdding: .day, value: offset, to: today)!,
                calendar: calendar
            )
        })

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 50,
            fiveHourUsedPercent: 0,
            samples: [],
            excludedDayIDs: skippedDays,
            calendar: calendar
        )

        XCTAssertEqual(plan.budgetDays.count, 5)
        XCTAssertEqual(plan.activeBudgetDayCount, 3)
        XCTAssertEqual(plan.budgetDays.filter(\.isExcluded).count, 2)
        XCTAssertEqual(plan.dailyAllowancePercent, 16.667, accuracy: 0.001)
    }

    func testTodayShareAndRunoutUpdateTogetherWhenUsageChanges() throws {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(4 * 24 * 60 * 60)
        let samples = [
            UsageSample(capturedAt: now.addingTimeInterval(-10 * 60), weeklyUsedPercent: 20),
            UsageSample(capturedAt: now, weeklyUsedPercent: 22)
        ]

        let plan = BudgetPlanner.makePlan(
            now: now,
            resetAt: reset,
            weeklyUsedPercent: 22,
            fiveHourUsedPercent: 2,
            samples: samples,
            speedWindowStartedAt: now.addingTimeInterval(-60 * 60),
            calendar: calendar
        )

        XCTAssertEqual(plan.dailyAllowancePercent, 19.5, accuracy: 0.001)
        XCTAssertEqual(plan.todayUsedPercent, 2, accuracy: 0.001)
        XCTAssertEqual(plan.todayBudgetUsedPercent, 10.256, accuracy: 0.001)
        XCTAssertEqual(plan.halfHourUsagePercentPerHour, 12, accuracy: 0.001)
        let runout = try XCTUnwrap(plan.predictedDailyAllowanceExhaustionAt)
        XCTAssertEqual(runout.timeIntervalSince(now), 87.5 * 60, accuracy: 1)
    }
}
