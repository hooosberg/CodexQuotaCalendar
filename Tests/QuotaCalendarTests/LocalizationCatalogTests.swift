import XCTest
@testable import QuotaCalendar

final class LocalizationCatalogTests: XCTestCase {
    func testTwelveLanguagesAreSupported() {
        XCTAssertEqual(AppLanguage.supported.count, 12)
        XCTAssertEqual(Set(AppLanguage.supported.map(\.rawValue)).count, 12)
    }

    func testRequiredKeysExistForEveryLanguage() {
        let requiredKeys: Set<LocalizedKey> = [
            .appName,
            .todayStatus,
            .weeklyCycle,
            .predictedExhaustion,
            .settings,
            .about,
            .appearanceDay,
            .appearanceNight,
            .privacySummary
        ]

        for language in AppLanguage.supported {
            let keys = Set((LocalizationCatalog.values[language] ?? [:]).keys)
            XCTAssertTrue(requiredKeys.isSubset(of: keys), "Missing keys for \(language.rawValue)")
        }
    }

    func testResetWatcherFooterCopyIsAvailable() throws {
        let titleKey = try XCTUnwrap(LocalizedKey(rawValue: "resetWatcherTitle"))
        let noteKey = try XCTUnwrap(LocalizedKey(rawValue: "resetWatcherNote"))
        let actionKey = try XCTUnwrap(LocalizedKey(rawValue: "followResetWatcher"))

        XCTAssertEqual(LocalizationCatalog.text(titleKey, language: .zhHans), "赛博重置上帝 @thsottiaux")
        XCTAssertEqual(LocalizationCatalog.text(noteKey, language: .zhHans), "点击关注重置情况，顺便给额度焦虑加一点幽默感。")
        XCTAssertEqual(LocalizationCatalog.text(actionKey, language: .zhHans), "关注重置情况")

        XCTAssertEqual(LocalizationCatalog.text(titleKey, language: .en), "Cyber Reset God @thsottiaux")
        XCTAssertEqual(LocalizationCatalog.text(noteKey, language: .en), "Follow reset sightings and keep quota anxiety slightly funnier.")
        XCTAssertEqual(LocalizationCatalog.text(actionKey, language: .en), "Follow reset status")
    }

    func testTenMinuteRefreshCopyIsAvailable() throws {
        let tenMinutesKey = try XCTUnwrap(LocalizedKey(rawValue: "tenMinutes"))

        XCTAssertEqual(RefreshInterval(rawValue: 600)?.rawValue, 600)
        XCTAssertEqual(LocalizationCatalog.text(tenMinutesKey, language: .zhHans), "10 分钟")
        XCTAssertEqual(LocalizationCatalog.text(tenMinutesKey, language: .en), "10 min")
    }

    func testAboutContactUsesSharedSupportEmail() throws {
        let emailKey = try XCTUnwrap(LocalizedKey(rawValue: "aboutSupportEmail"))

        XCTAssertEqual(LocalizationCatalog.text(emailKey, language: .zhHans), "zikedece@proton.me")
        XCTAssertEqual(LocalizationCatalog.text(emailKey, language: .en), "zikedece@proton.me")
    }

    func testAboutAuthorXCopyIsAvailable() throws {
        let titleKey = try XCTUnwrap(LocalizedKey(rawValue: "aboutAuthorX"))
        let noteKey = try XCTUnwrap(LocalizedKey(rawValue: "aboutAuthorXNote"))

        XCTAssertEqual(LocalizationCatalog.text(titleKey, language: .zhHans), "作者 X")
        XCTAssertEqual(LocalizationCatalog.text(noteKey, language: .zhHans), "打开作者的 X 主页，关注更新和反馈。")

        XCTAssertEqual(LocalizationCatalog.text(titleKey, language: .en), "Author X")
        XCTAssertEqual(LocalizationCatalog.text(noteKey, language: .en), "Open the author's X profile for updates and feedback.")
    }

    func testKoreanSettingsCopyDoesNotFallBackToEnglishOrChineseUnits() {
        XCTAssertEqual(LocalizationCatalog.text(.overview, language: .ko), "개요")
        XCTAssertEqual(LocalizationCatalog.text(.settings, language: .ko), "설정")
        XCTAssertEqual(LocalizationCatalog.text(.notifications, language: .ko), "알림")
        XCTAssertEqual(LocalizationCatalog.text(.about, language: .ko), "정보")
        XCTAssertEqual(LocalizationCatalog.text(.account, language: .ko), "계정")
        XCTAssertEqual(LocalizationCatalog.text(.appearance, language: .ko), "모양")
        XCTAssertEqual(LocalizationCatalog.text(.refreshInterval, language: .ko), "새로고침 간격")
        XCTAssertEqual(LocalizationCatalog.text(.dailyAverageAlgorithm, language: .ko), "일일 평균 계산식")
        XCTAssertEqual(LocalizationCatalog.text(.appControls, language: .ko), "앱")
        XCTAssertEqual(LocalizationCatalog.text(.perDaySuffix, language: .ko), "/일")
        XCTAssertEqual(LocalizationCatalog.text(.perWeekSuffix, language: .ko), "/주")

        let formula = String(
            format: LocalizationCatalog.text(.dailyAverageFormula, language: .ko),
            "94%",
            7,
            "13%"
        )
        XCTAssertEqual(formula, "94% ÷ 7일 = 13%/일")
        XCTAssertEqual(
            String(format: LocalizationCatalog.text(.usedPercentLabel, language: .ko), "0%"),
            "0% 사용"
        )
    }
}
