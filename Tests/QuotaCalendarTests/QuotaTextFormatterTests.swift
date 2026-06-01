import XCTest
@testable import QuotaCalendar

final class QuotaTextFormatterTests: XCTestCase {
    func testWeeklyResetSummaryIncludesWeekdayAndRemainingTimeInChinese() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let reset = now.addingTimeInterval(6 * 24 * 60 * 60 + 22 * 60 * 60)

        let summary = QuotaTextFormatter.resetSummary(
            resetAt: reset,
            now: now,
            language: .zhHans,
            includeWeekday: true
        )

        XCTAssertTrue(summary.contains("恢复"))
        XCTAssertTrue(summary.contains("还剩6天22小时"))
    }

    func testTodayBudgetContextMentionsWeeklyRemaining() {
        let text = QuotaTextFormatter.todayBudgetContext(
            dailyAllowancePercent: 14,
            weeklyRemainingPercent: 99,
            language: .zhHans
        )

        XCTAssertEqual(text, "14% / 剩余周额度 99%")
    }

    func testKoreanResetSummaryAndBudgetContextAreLocalized() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let resetOffset = TimeInterval(183_600)
        let reset = now.addingTimeInterval(resetOffset)

        let summary = QuotaTextFormatter.resetSummary(
            resetAt: reset,
            now: now,
            language: .ko,
            includeWeekday: true
        )
        let context = QuotaTextFormatter.todayBudgetContext(
            dailyAllowancePercent: 13,
            weeklyRemainingPercent: 94,
            language: .ko
        )

        XCTAssertTrue(summary.contains("재설정"))
        XCTAssertTrue(summary.contains("2일 3시간 남음"))
        XCTAssertFalse(summary.contains("resets"))
        XCTAssertFalse(summary.contains("left"))
        XCTAssertEqual(context, "13% / 주간 잔여 94%")
    }

    func testWeekdayTextUsesSelectedLanguageLocale() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let monday = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: calendar.timeZone,
            year: 2026,
            month: 6,
            day: 1,
            hour: 12
        )))

        XCTAssertEqual(QuotaTextFormatter.weekdayText(for: monday, language: .zhHans), "周一")
        XCTAssertEqual(QuotaTextFormatter.weekdayText(for: monday, language: .en), "Mon")

        let italian = QuotaTextFormatter.weekdayText(for: monday, language: .it).lowercased()
        XCTAssertTrue(italian.contains("lun"))
        XCTAssertFalse(italian.contains("周"))

        let korean = QuotaTextFormatter.weekdayText(for: monday, language: .ko)
        XCTAssertTrue(korean.contains("월"))
        XCTAssertFalse(korean.contains("周"))
    }
}
