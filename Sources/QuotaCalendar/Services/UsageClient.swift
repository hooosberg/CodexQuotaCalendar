import Foundation

enum UsageClientError: LocalizedError {
    case noEndpointSucceeded([String])
    case badStatus(Int, String)
    case emptyUsage

    var errorDescription: String? {
        switch self {
        case .noEndpointSucceeded(let messages):
            return messages.prefix(2).joined(separator: " | ")
        case .badStatus(let status, let body):
            return "Usage request failed with HTTP \(status): \(body.prefix(160))"
        case .emptyUsage:
            return "Usage response did not contain a weekly or 5-hour window."
        }
    }
}

struct UsageClient {
    var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 18
        configuration.httpCookieStorage = nil
        configuration.httpShouldSetCookies = false
        return URLSession(configuration: configuration)
    }()

    func fetchUsage(credentials: CodexCredentials) async throws -> UsageSnapshot {
        var failures: [String] = []
        for endpoint in usageEndpoints {
            do {
                return try await fetchUsage(from: endpoint, credentials: credentials)
            } catch {
                failures.append("\(endpoint.host ?? endpoint.absoluteString): \(error.localizedDescription)")
            }
        }
        throw UsageClientError.noEndpointSucceeded(failures)
    }

    private var usageEndpoints: [URL] {
        [
            URL(string: "https://chatgpt.com/backend-api/wham/usage"),
            URL(string: "https://chatgpt.com/api/codex/usage")
        ].compactMap { $0 }
    }

    private func fetchUsage(from endpoint: URL, credentials: CodexCredentials) async throws -> UsageSnapshot {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(credentials.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(credentials.accountID, forHTTPHeaderField: "ChatGPT-Account-Id")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("quota-calendar/0.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageClientError.badStatus(-1, "No HTTP response")
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "<\(data.count) bytes>"
            throw UsageClientError.badStatus(httpResponse.statusCode, body)
        }

        let payload = try JSONDecoder().decode(UsageAPIResponse.self, from: data)
        let snapshot = mapPayload(payload)
        guard snapshot.fiveHour != nil || snapshot.oneWeek != nil else {
            throw UsageClientError.emptyUsage
        }
        return snapshot
    }

    private func mapPayload(_ payload: UsageAPIResponse) -> UsageSnapshot {
        var windows: [UsageWindowRaw] = []
        if let rateLimit = payload.rateLimit {
            if let primary = rateLimit.primaryWindow { windows.append(primary) }
            if let secondary = rateLimit.secondaryWindow { windows.append(secondary) }
        }
        for item in payload.additionalRateLimits ?? [] {
            if let primary = item.rateLimit?.primaryWindow { windows.append(primary) }
            if let secondary = item.rateLimit?.secondaryWindow { windows.append(secondary) }
        }

        let fiveHour = pickNearestWindow(windows, targetSeconds: 5 * 60 * 60)
        let oneWeek = pickNearestWindow(windows, targetSeconds: 7 * 24 * 60 * 60)

        return UsageSnapshot(
            fetchedAt: Int64(Date().timeIntervalSince1970),
            planType: payload.planType,
            fiveHour: fiveHour.map(toUsageWindow),
            oneWeek: oneWeek.map(toUsageWindow),
            credits: payload.credits.map {
                CreditSnapshot(hasCredits: $0.hasCredits, unlimited: $0.unlimited, balance: $0.balance)
            }
        )
    }

    private func pickNearestWindow(_ windows: [UsageWindowRaw], targetSeconds: Int64) -> UsageWindowRaw? {
        windows.min { left, right in
            abs(left.limitWindowSeconds - targetSeconds) < abs(right.limitWindowSeconds - targetSeconds)
        }
    }

    private func toUsageWindow(_ raw: UsageWindowRaw) -> UsageWindow {
        UsageWindow(
            usedPercent: raw.usedPercent,
            windowSeconds: raw.limitWindowSeconds,
            resetAt: raw.resetAt
        )
    }
}

private struct UsageAPIResponse: Decodable {
    var planType: String?
    var rateLimit: RateLimitDetails?
    var additionalRateLimits: [AdditionalRateLimitDetails]?
    var credits: CreditDetails?

    enum CodingKeys: String, CodingKey {
        case planType = "plan_type"
        case rateLimit = "rate_limit"
        case additionalRateLimits = "additional_rate_limits"
        case credits
    }
}

private struct RateLimitDetails: Decodable {
    var primaryWindow: UsageWindowRaw?
    var secondaryWindow: UsageWindowRaw?

    enum CodingKeys: String, CodingKey {
        case primaryWindow = "primary_window"
        case secondaryWindow = "secondary_window"
    }
}

private struct AdditionalRateLimitDetails: Decodable {
    var rateLimit: RateLimitDetails?

    enum CodingKeys: String, CodingKey {
        case rateLimit = "rate_limit"
    }
}

private struct UsageWindowRaw: Decodable {
    var usedPercent: Double
    var limitWindowSeconds: Int64
    var resetAt: Int64

    enum CodingKeys: String, CodingKey {
        case usedPercent = "used_percent"
        case limitWindowSeconds = "limit_window_seconds"
        case resetAt = "reset_at"
    }
}

private struct CreditDetails: Decodable {
    var hasCredits: Bool
    var unlimited: Bool
    var balance: String?

    enum CodingKeys: String, CodingKey {
        case hasCredits = "has_credits"
        case unlimited
        case balance
    }
}
