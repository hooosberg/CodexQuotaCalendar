import XCTest
@testable import QuotaCalendar

final class OpenAIAuthLoginServiceTests: XCTestCase {
    func testAuthorizationURLUsesOpenAIChatGPTPKCEFlow() throws {
        let url = try OpenAIAuthLoginService.authorizationURL(
            redirectURI: "http://localhost:1455/auth/callback",
            codeChallenge: "challenge-value",
            state: "state-value"
        )
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "auth.openai.com")
        XCTAssertEqual(components.path, "/oauth/authorize")
        XCTAssertEqual(query["response_type"], "code")
        XCTAssertEqual(query["client_id"], "app_EMoamEEZ73f0CkXaXp7hrann")
        XCTAssertEqual(query["redirect_uri"], "http://localhost:1455/auth/callback")
        XCTAssertEqual(query["code_challenge"], "challenge-value")
        XCTAssertEqual(query["code_challenge_method"], "S256")
        XCTAssertEqual(query["state"], "state-value")
        XCTAssertEqual(query["originator"], "codex_cli_rs")
        XCTAssertEqual(query["id_token_add_organizations"], "true")
        XCTAssertEqual(query["codex_cli_simplified_flow"], "true")
        XCTAssertTrue(query["scope"]?.contains("offline_access") == true)
        XCTAssertTrue(url.absoluteString.contains("redirect_uri=http%3A%2F%2Flocalhost%3A1455%2Fauth%2Fcallback"))
    }

    func testFormEncodedBodyMatchesOAuthEncoding() throws {
        let body = OpenAIAuthLoginService.formEncodedBody([
            ("grant_type", "authorization_code"),
            ("redirect_uri", "http://localhost:1455/auth/callback"),
            ("code", "a+b/c=")
        ])
        let text = try XCTUnwrap(String(data: body, encoding: .utf8))

        XCTAssertEqual(
            text,
            "grant_type=authorization_code&redirect_uri=http%3A%2F%2Flocalhost%3A1455%2Fauth%2Fcallback&code=a%2Bb%2Fc%3D"
        )
    }
}
