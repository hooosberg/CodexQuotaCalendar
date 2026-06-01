import XCTest
@testable import QuotaCalendar

final class UsageHistoryStoreTests: XCTestCase {
    func testPersistsAtMostOneSamplePerThirtyMinutesButReturnsCurrentPoint() {
        let defaults = makeDefaults()
        let store = UsageHistoryStore(defaults: defaults)
        let start = Date(timeIntervalSince1970: 1_800_000_000)

        let first = store.appending(snapshot: snapshot(weeklyUsedPercent: 10), now: start)
        let second = store.appending(snapshot: snapshot(weeklyUsedPercent: 12), now: start.addingTimeInterval(10 * 60))
        let third = store.appending(snapshot: snapshot(weeklyUsedPercent: 15), now: start.addingTimeInterval(30 * 60))

        XCTAssertEqual(first.map(\.weeklyUsedPercent), [10])
        XCTAssertEqual(second.map(\.weeklyUsedPercent), [10, 12])
        XCTAssertEqual(store.loadSamples().map(\.weeklyUsedPercent), [10, 15])
        XCTAssertEqual(third.map(\.weeklyUsedPercent), [10, 15])
    }

    func testPersistentHistoryKeepsTheMostRecentTwentySamples() {
        let defaults = makeDefaults()
        let store = UsageHistoryStore(defaults: defaults)
        let start = Date(timeIntervalSince1970: 1_800_000_000)

        for index in 0..<25 {
            _ = store.appending(
                snapshot: snapshot(weeklyUsedPercent: Double(index)),
                now: start.addingTimeInterval(Double(index) * 31 * 60)
            )
        }

        let saved = store.loadSamples()
        XCTAssertEqual(saved.count, 20)
        XCTAssertEqual(saved.first?.weeklyUsedPercent, 5)
        XCTAssertEqual(saved.last?.weeklyUsedPercent, 24)
    }

    private func snapshot(weeklyUsedPercent: Double) -> UsageSnapshot {
        UsageSnapshot(
            fetchedAt: 0,
            planType: nil,
            fiveHour: nil,
            oneWeek: UsageWindow(usedPercent: weeklyUsedPercent, windowSeconds: 7 * 24 * 60 * 60, resetAt: nil),
            credits: nil
        )
    }

    private func makeDefaults() -> UserDefaults {
        let name = "QuotaCalendarTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
