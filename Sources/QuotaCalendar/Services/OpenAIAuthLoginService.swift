import AppKit
import CryptoKit
import Foundation
import Network

struct OpenAIAuthTokens: Equatable {
    var accessToken: String
    var refreshToken: String
    var idToken: String
}

enum OpenAIAuthError: LocalizedError {
    case browserOpenFailed
    case callbackTimedOut
    case callbackStateMismatch
    case callbackMissingCode
    case callbackServerFailed
    case tokenExchangeFailed(String)

    var errorDescription: String? {
        switch self {
        case .browserOpenFailed:
            return "无法打开浏览器，请手动打开登录链接。"
        case .callbackTimedOut:
            return "登录超时，请重新开始授权。"
        case .callbackStateMismatch:
            return "登录回调校验失败，请重新开始授权。"
        case .callbackMissingCode:
            return "登录回调缺少授权码。"
        case .callbackServerFailed:
            return "无法启动本机授权回调服务。"
        case .tokenExchangeFailed(let message):
            return "登录换取 token 失败：\(message)"
        }
    }
}

struct OpenAIAuthLoginService {
    private enum Configuration {
        static let issuer = URL(string: "https://auth.openai.com")!
        static let clientID = "app_EMoamEEZ73f0CkXaXp7hrann"
        static let originator = "codex_cli_rs"
        static let callbackPath = "/auth/callback"
        static let preferredCallbackPort: UInt16 = 1455
        static let maxPortScanOffset: UInt16 = 12
        static let scopes = "openid profile email offline_access api.connectors.read api.connectors.invoke"
    }

    var session: URLSession = .shared

    func signIn(timeoutSeconds: TimeInterval = 180) async throws -> OpenAIAuthTokens {
        let pkce = PKCECodes.make()
        let state = Self.randomBase64URL(byteCount: 32)
        let callback = OAuthValueBox<OpenAIAuthTokens>()
        let (server, port) = try makeCallbackServer(
            callback: callback,
            pkce: pkce,
            state: state
        )
        let redirectURI = Self.redirectURI(for: port)
        let authorizationURL = try Self.authorizationURL(
            redirectURI: redirectURI,
            codeChallenge: pkce.codeChallenge,
            state: state
        )

        try await server.start()
        defer { server.stop() }

        guard NSWorkspace.shared.open(authorizationURL) else {
            throw OpenAIAuthError.browserOpenFailed
        }

        return try await callback.wait(timeoutSeconds: timeoutSeconds)
    }

    func refresh(credentials: CodexCredentials) async throws -> OpenAIAuthTokens {
        var request = URLRequest(url: Self.endpointURL("/oauth/token"))
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.formEncodedBody([
            ("grant_type", "refresh_token"),
            ("refresh_token", credentials.refreshToken),
            ("client_id", Configuration.clientID)
        ])

        let response = try await Self.tokenResponse(for: request, session: session)
        return OpenAIAuthTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken ?? credentials.refreshToken,
            idToken: response.idToken
        )
    }

    static func authorizationURL(
        redirectURI: String,
        codeChallenge: String,
        state: String
    ) throws -> URL {
        var components = URLComponents(url: endpointURL("/oauth/authorize"), resolvingAgainstBaseURL: false)
        components?.percentEncodedQuery = percentEncodedPairs([
            ("response_type", "code"),
            ("client_id", Configuration.clientID),
            ("redirect_uri", redirectURI),
            ("scope", Configuration.scopes),
            ("code_challenge", codeChallenge),
            ("code_challenge_method", "S256"),
            ("id_token_add_organizations", "true"),
            ("codex_cli_simplified_flow", "true"),
            ("state", state),
            ("originator", Configuration.originator)
        ])
        guard let url = components?.url else {
            throw OpenAIAuthError.callbackServerFailed
        }
        return url
    }

    private static func exchangeCodeForTokens(
        session: URLSession,
        code: String,
        redirectURI: String,
        codeVerifier: String
    ) async throws -> OpenAIAuthTokens {
        var request = URLRequest(url: endpointURL("/oauth/token"))
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = formEncodedBody([
            ("grant_type", "authorization_code"),
            ("code", code),
            ("redirect_uri", redirectURI),
            ("client_id", Self.Configuration.clientID),
            ("code_verifier", codeVerifier)
        ])

        let response = try await tokenResponse(for: request, session: session)
        guard let refreshToken = response.refreshToken, !refreshToken.isEmpty else {
            throw OpenAIAuthError.tokenExchangeFailed("missing refresh_token")
        }
        return OpenAIAuthTokens(
            accessToken: response.accessToken,
            refreshToken: refreshToken,
            idToken: response.idToken
        )
    }

    private static func tokenResponse(for request: URLRequest, session: URLSession) async throws -> OAuthTokenResponse {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIAuthError.tokenExchangeFailed("invalid response")
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw OpenAIAuthError.tokenExchangeFailed(Self.bestHTTPErrorMessage(from: data, statusCode: httpResponse.statusCode))
        }
        return try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
    }

    private func makeCallbackServer(
        callback: OAuthValueBox<OpenAIAuthTokens>,
        pkce: PKCECodes,
        state: String,
    ) throws -> (LocalOAuthCallbackServer, UInt16) {
        var candidatePort = Configuration.preferredCallbackPort
        let maxPort = Configuration.preferredCallbackPort + Configuration.maxPortScanOffset
        var lastError: Error?

        while candidatePort <= maxPort {
            do {
                let redirectURI = Self.redirectURI(for: candidatePort)
                let server = try LocalOAuthCallbackServer(port: candidatePort) { [session] request in
                    Self.handleCallback(
                        request: request,
                        session: session,
                        redirectURI: redirectURI,
                        codeVerifier: pkce.codeVerifier,
                        expectedState: state,
                        callback: callback
                    )
                }
                return (server, candidatePort)
            } catch {
                lastError = error
                candidatePort += 1
            }
        }

        throw lastError ?? OpenAIAuthError.callbackServerFailed
    }

    private static func handleCallback(
        request: LocalOAuthRequest,
        session: URLSession,
        redirectURI: String,
        codeVerifier: String,
        expectedState: String,
        callback: OAuthValueBox<OpenAIAuthTokens>
    ) -> LocalOAuthResponse {
        guard request.method == "GET" else {
            return .text(statusCode: 405, text: "Method Not Allowed")
        }

        guard request.path == Configuration.callbackPath else {
            return .text(statusCode: 404, text: "Not Found")
        }
        guard request.query["state"] == expectedState else {
            callback.fail(OpenAIAuthError.callbackStateMismatch)
            return .html(statusCode: 400, body: errorPage("登录校验失败，请回到额度日历重新登录。"))
        }
        if let code = request.query["code"], !code.isEmpty {
            Task { @MainActor in NSApp.activate(ignoringOtherApps: true) }
            Task {
                do {
                    let tokens = try await exchangeCodeForTokens(
                        session: session,
                        code: code,
                        redirectURI: redirectURI,
                        codeVerifier: codeVerifier
                    )
                    callback.succeed(tokens)
                } catch {
                    callback.fail(error)
                }
            }
            return .html(statusCode: 200, body: successPage())
        }
        let message = request.query["error_description"] ?? request.query["error"] ?? "missing code"
        callback.fail(OpenAIAuthError.callbackMissingCode)
        return .html(statusCode: 401, body: errorPage(message))
    }

    private static func endpointURL(_ path: String) -> URL {
        URL(string: path, relativeTo: Configuration.issuer)?.absoluteURL ?? Configuration.issuer
    }

    private static func redirectURI(for port: UInt16) -> String {
        "http://localhost:\(port)\(Configuration.callbackPath)"
    }

    static func formEncodedBody(_ items: [(String, String)]) -> Data {
        Data(percentEncodedPairs(items).utf8)
    }

    private static func percentEncodedPairs(_ items: [(String, String)]) -> String {
        items
            .map { key, value in
                "\(percentEncode(key))=\(percentEncode(value))"
            }
            .joined(separator: "&")
    }

    private static func percentEncode(_ value: String) -> String {
        value.addingPercentEncoding(withAllowedCharacters: .oauthFormAllowed) ?? value
    }

    private static func randomBase64URL(byteCount: Int) -> String {
        let bytes = (0..<byteCount).map { _ in UInt8.random(in: .min ... .max) }
        return Data(bytes).base64URLEncodedString()
    }

    private static func successPage() -> Data {
        Data("""
        <html><head><meta charset="utf-8"><title>额度日历</title></head>
        <body style="font-family:-apple-system,BlinkMacSystemFont,sans-serif;padding:32px;">
        <h2>登录完成</h2><p>可以回到额度日历了。</p>
        <script>setTimeout(function(){ window.open('', '_self'); window.close(); }, 180);</script>
        </body></html>
        """.utf8)
    }

    private static func errorPage(_ message: String) -> Data {
        Data("""
        <html><head><meta charset="utf-8"><title>额度日历</title></head>
        <body style="font-family:-apple-system,BlinkMacSystemFont,sans-serif;padding:32px;">
        <h2>登录失败</h2><p>\(htmlEscape(message))</p>
        </body></html>
        """.utf8)
    }

    private static func bestHTTPErrorMessage(from data: Data, statusCode: Int) -> String {
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let description = object["error_description"] as? String, !description.isEmpty {
                return description
            }
            if let error = object["error"] as? String, !error.isEmpty {
                return error
            }
        }
        if let body = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !body.isEmpty {
            return String(body.prefix(200))
        }
        return "HTTP \(statusCode)"
    }

    private static func htmlEscape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

private struct OAuthTokenResponse: Decodable {
    var idToken: String
    var accessToken: String
    var refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private struct PKCECodes {
    var codeVerifier: String
    var codeChallenge: String

    static func make() -> PKCECodes {
        let verifier = OpenAIAuthLoginService.randomBase64URLForPKCE()
        let digest = SHA256.hash(data: Data(verifier.utf8))
        return PKCECodes(
            codeVerifier: verifier,
            codeChallenge: Data(digest).base64URLEncodedString()
        )
    }
}

private final class OAuthValueBox<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Value, Error>?
    private var result: Result<Value, Error>?

    func wait(timeoutSeconds: TimeInterval) async throws -> Value {
        let timeoutTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(timeoutSeconds * 1_000_000_000))
            self?.fail(OpenAIAuthError.callbackTimedOut)
        }
        defer { timeoutTask.cancel() }

        return try await withCheckedThrowingContinuation { continuation in
            lock.lock()
            if let result {
                lock.unlock()
                continuation.resume(with: result)
                return
            }
            self.continuation = continuation
            lock.unlock()
        }
    }

    func succeed(_ value: Value) {
        resolve(.success(value))
    }

    func fail(_ error: Error) {
        resolve(.failure(error))
    }

    private func resolve(_ result: Result<Value, Error>) {
        lock.lock()
        guard self.result == nil else {
            lock.unlock()
            return
        }
        self.result = result
        let continuation = self.continuation
        self.continuation = nil
        lock.unlock()
        continuation?.resume(with: result)
    }
}

private struct LocalOAuthRequest {
    var method: String
    var path: String
    var query: [String: String]
}

private struct LocalOAuthResponse {
    var statusCode: Int
    var contentType: String
    var body: Data

    static func html(statusCode: Int, body: Data) -> LocalOAuthResponse {
        LocalOAuthResponse(statusCode: statusCode, contentType: "text/html; charset=utf-8", body: body)
    }

    static func text(statusCode: Int, text: String) -> LocalOAuthResponse {
        LocalOAuthResponse(statusCode: statusCode, contentType: "text/plain; charset=utf-8", body: Data(text.utf8))
    }
}

private final class LocalOAuthCallbackServer: @unchecked Sendable {
    let port: UInt16
    private let listener: NWListener
    private let handler: @Sendable (LocalOAuthRequest) -> LocalOAuthResponse
    private let queue = DispatchQueue(label: "QuotaCalendar.OAuthCallbackServer")
    private let stateLock = NSLock()
    private var isStarted = false

    init(port: UInt16, handler: @escaping @Sendable (LocalOAuthRequest) -> LocalOAuthResponse) throws {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            throw OpenAIAuthError.callbackServerFailed
        }
        self.port = port
        let parameters = NWParameters.tcp
        parameters.allowLocalEndpointReuse = true
        self.listener = try NWListener(using: parameters, on: nwPort)
        self.handler = handler
    }

    func start() async throws {
        listener.newConnectionHandler = { [weak self] connection in
            self?.handle(connection)
        }

        let shouldStart = stateLock.withOAuthLock {
            if isStarted {
                return false
            }
            isStarted = true
            return true
        }
        guard shouldStart else { return }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let resumeState = OAuthServerResumeState()
            listener.stateUpdateHandler = { state in
                switch resumeState.consume(state: state) {
                case .resume:
                    continuation.resume()
                case .throwError(let error):
                    continuation.resume(throwing: error)
                case .none:
                    break
                }
            }
            listener.start(queue: queue)
        }
    }

    func stop() {
        listener.cancel()
        stateLock.withOAuthLock {
            isStarted = false
        }
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        readRequest(on: connection, buffer: Data())
    }

    private func readRequest(on connection: NWConnection, buffer: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
            guard let self else {
                connection.cancel()
                return
            }

            if error != nil {
                connection.cancel()
                return
            }

            var working = buffer
            if let data, !data.isEmpty {
                working.append(data)
            }

            if working.count > 64 * 1024 {
                self.send(.text(statusCode: 413, text: "Payload Too Large"), on: connection)
                return
            }

            if let request = Self.parseRequest(working) {
                let response = self.handler(request)
                self.send(response, on: connection)
                return
            }

            if isComplete {
                self.send(.text(statusCode: 400, text: "Bad Request"), on: connection)
                return
            }

            self.readRequest(on: connection, buffer: working)
        }
    }

    private func send(_ response: LocalOAuthResponse, on connection: NWConnection) {
        let payload = Self.httpPayload(for: response)
        connection.send(content: payload, completion: .contentProcessed { _ in
            connection.cancel()
        })
    }

    private static func parseRequest(_ data: Data?) -> LocalOAuthRequest? {
        guard let data else { return nil }
        guard let headerRange = data.range(of: Data("\r\n\r\n".utf8)) else {
            return nil
        }
        let headerData = data.subdata(in: 0..<headerRange.lowerBound)
        guard let headerText = String(data: headerData, encoding: .utf8) else { return nil }
        guard let requestLine = headerText.split(separator: "\r\n", omittingEmptySubsequences: false).first else { return nil }
        let pieces = requestLine.split(separator: " ")
        guard pieces.count >= 2 else { return nil }
        guard let components = URLComponents(string: String(pieces[1])) else { return nil }
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })
        return LocalOAuthRequest(method: String(pieces[0]).uppercased(), path: components.path, query: query)
    }

    private static func httpPayload(for response: LocalOAuthResponse) -> Data {
        let lines = [
            "HTTP/1.1 \(response.statusCode) \(reasonPhrase(for: response.statusCode))",
            "Connection: close",
            "Content-Length: \(response.body.count)",
            "Content-Type: \(response.contentType)",
            "\r\n"
        ]
        var output = Data(lines.joined(separator: "\r\n").utf8)
        output.append(response.body)
        return output
    }

    private static func reasonPhrase(for statusCode: Int) -> String {
        switch statusCode {
        case 200: return "OK"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 404: return "Not Found"
        case 405: return "Method Not Allowed"
        case 413: return "Payload Too Large"
        default: return "HTTP"
        }
    }
}

private extension NSLock {
    func withOAuthLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}

private final class OAuthServerResumeState: @unchecked Sendable {
    enum Action {
        case none
        case resume
        case throwError(Error)
    }

    private let lock = NSLock()
    private var hasResumed = false

    func consume(state: NWListener.State) -> Action {
        lock.withOAuthLock {
            guard !hasResumed else { return .none }
            switch state {
            case .ready:
                hasResumed = true
                return .resume
            case .failed(let error):
                hasResumed = true
                return .throwError(error)
            case .cancelled:
                hasResumed = true
                return .throwError(OpenAIAuthError.callbackServerFailed)
            default:
                return .none
            }
        }
    }
}

private extension OpenAIAuthLoginService {
    static func randomBase64URLForPKCE() -> String {
        randomBase64URL(byteCount: 64)
    }
}

private extension Data {
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

private extension CharacterSet {
    static let oauthFormAllowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}
