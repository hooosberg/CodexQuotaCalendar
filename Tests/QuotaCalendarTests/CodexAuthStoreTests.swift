import Foundation
import XCTest
@testable import QuotaCalendar

final class CodexAuthStoreTests: XCTestCase {
    func testLoadsAccountDisplayNameFromIDToken() throws {
        let url = try writeAuthFile(
            accountID: "acct_1234567890",
            idTokenPayload: [
                "name": "Maohuhu",
                "email": "maohuhu@example.com",
                "https://api.openai.com/auth": [
                    "chatgpt_account_id": "acct_1234567890"
                ]
            ]
        )

        let credentials = try CodexAuthStore(authURL: url).loadCredentials()

        XCTAssertEqual(credentials.accessToken, "access-token")
        XCTAssertEqual(credentials.refreshToken, "refresh-token")
        XCTAssertEqual(credentials.displayName, "Maohuhu")
        XCTAssertEqual(credentials.email, "maohuhu@example.com")
        XCTAssertEqual(credentials.accountLabel, "Maohuhu")
    }

    func testFallsBackToShortAccountIDWhenIDTokenHasNoName() throws {
        let url = try writeAuthFile(
            accountID: "acct_1234567890abcdef",
            idTokenPayload: [:]
        )

        let credentials = try CodexAuthStore(authURL: url).loadCredentials()

        XCTAssertEqual(credentials.accountLabel, "acct_1234...")
    }

    func testDefaultAuthPathUsesQuotaCalendarAppSupport() {
        let path = CodexAuthStore.defaultAuthURL.path

        XCTAssertTrue(path.contains("Application Support/QuotaCalendar/auth.json"), path)
        XCTAssertFalse(path.hasSuffix(".codex/auth.json"), path)
    }

    func testSaveCredentialsWritesStandardLocalAuthFile() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("auth.json")
        let store = CodexAuthStore(authURL: url)
        let idToken = makeJWT(payload: [
            "email": "new@example.com",
            "https://api.openai.com/auth": [
                "chatgpt_account_id": "acct_new_user"
            ]
        ])

        try store.saveCredentials(
            accessToken: "access-new",
            refreshToken: "refresh-new",
            idToken: idToken
        )

        let credentials = try store.loadCredentials()
        XCTAssertEqual(credentials.accessToken, "access-new")
        XCTAssertEqual(credentials.refreshToken, "refresh-new")
        XCTAssertEqual(credentials.accountID, "acct_new_user")
        XCTAssertEqual(credentials.email, "new@example.com")
    }

    private func writeAuthFile(accountID: String, idTokenPayload: [String: Any]) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("auth.json")
        let json = """
        {
          "tokens": {
            "access_token": "access-token",
            "account_id": "\(accountID)",
            "refresh_token": "refresh-token",
            "id_token": "\(makeJWT(payload: idTokenPayload))"
          }
        }
        """
        try json.data(using: .utf8)?.write(to: url)
        return url
    }

    private func makeJWT(payload: [String: Any]) -> String {
        let header = base64URL(Data(#"{"alg":"none"}"#.utf8))
        let payloadData = try! JSONSerialization.data(withJSONObject: payload)
        return "\(header).\(base64URL(payloadData)).signature"
    }

    private func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
