import Foundation

struct CodexCredentials: Equatable {
    var accessToken: String
    var refreshToken: String
    var idToken: String
    var accountID: String
    var displayName: String?
    var email: String?

    var accountLabel: String {
        if let displayName, !displayName.isEmpty {
            return displayName
        }
        if let email, !email.isEmpty {
            return email
        }
        if accountID.count > 9 {
            return "\(accountID.prefix(9))..."
        }
        return accountID
    }
}

enum AuthStoreError: LocalizedError {
    case missingAuthFile
    case malformedAuthFile
    case missingAccountID

    var errorDescription: String? {
        switch self {
        case .missingAuthFile:
            return "尚未授权 ChatGPT，请先登录。"
        case .malformedAuthFile:
            return "授权文件存在，但缺少必要的 token 字段。"
        case .missingAccountID:
            return "授权成功，但没有拿到账号 ID。"
        }
    }
}

struct CodexAuthStore {
    static var defaultAuthURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("QuotaCalendar", isDirectory: true)
            .appendingPathComponent("auth.json")
    }

    var authURL: URL = Self.defaultAuthURL

    func loadCredentials() throws -> CodexCredentials {
        guard FileManager.default.fileExists(atPath: authURL.path) else {
            throw AuthStoreError.missingAuthFile
        }

        let data = try Data(contentsOf: authURL)
        let auth = try JSONDecoder().decode(CodexAuthFile.self, from: data)
        guard !auth.tokens.accessToken.isEmpty,
              !auth.tokens.refreshToken.isEmpty,
              !auth.tokens.idToken.isEmpty,
              !auth.tokens.accountID.isEmpty else {
            throw AuthStoreError.malformedAuthFile
        }
        let profile = Self.profile(fromIDToken: auth.tokens.idToken)
        return CodexCredentials(
            accessToken: auth.tokens.accessToken,
            refreshToken: auth.tokens.refreshToken,
            idToken: auth.tokens.idToken,
            accountID: auth.tokens.accountID,
            displayName: profile?.name,
            email: profile?.email
        )
    }

    func saveCredentials(
        accessToken: String,
        refreshToken: String,
        idToken: String
    ) throws {
        let profile = Self.profile(fromIDToken: idToken)
        guard let accountID = profile?.chatGPTAccountID, !accountID.isEmpty else {
            throw AuthStoreError.missingAccountID
        }

        let file = CodexAuthFile(
            authMode: "chatgpt",
            lastRefresh: ISO8601DateFormatter().string(from: Date()),
            tokens: TokenBlock(
                accessToken: accessToken,
                refreshToken: refreshToken,
                idToken: idToken,
                accountID: accountID
            )
        )
        let directory = authURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder.prettyPrinted.encode(file)
        try data.write(to: authURL, options: .atomic)
    }

    func deleteCredentials() throws {
        guard FileManager.default.fileExists(atPath: authURL.path) else { return }
        try FileManager.default.removeItem(at: authURL)
    }

    static func profile(fromIDToken idToken: String) -> TokenProfile? {
        let parts = idToken.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 {
            payload.append("=")
        }
        guard let data = Data(base64Encoded: payload) else { return nil }
        return try? JSONDecoder().decode(TokenProfile.self, from: data)
    }
}

private struct CodexAuthFile: Codable {
    var authMode: String?
    var lastRefresh: String?
    var tokens: TokenBlock

    enum CodingKeys: String, CodingKey {
        case authMode = "auth_mode"
        case lastRefresh = "last_refresh"
        case tokens
    }
}

private struct TokenBlock: Codable {
    var accessToken: String
    var refreshToken: String
    var idToken: String
    var accountID: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case accountID = "account_id"
    }
}

struct TokenProfile: Decodable, Equatable {
    var name: String?
    var email: String?
    var openAIAuth: OpenAIAuthClaims?

    var chatGPTAccountID: String? {
        openAIAuth?.chatGPTAccountID
    }

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case openAIAuth = "https://api.openai.com/auth"
    }
}

struct OpenAIAuthClaims: Decodable, Equatable {
    var chatGPTAccountID: String?

    enum CodingKeys: String, CodingKey {
        case chatGPTAccountID = "chatgpt_account_id"
    }
}

private extension JSONEncoder {
    static var prettyPrinted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
