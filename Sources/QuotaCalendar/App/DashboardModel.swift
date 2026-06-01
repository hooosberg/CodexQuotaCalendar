import Combine
import Foundation

@MainActor
final class DashboardModel: ObservableObject {
    @Published var snapshot: UsageSnapshot?
    @Published var plan: BudgetPlan?
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    @Published var isSigningIn = false
    @Published var needsAuthorization = false
    @Published var lastRefreshDate: Date?
    @Published var accountLabel: String?
    @Published var language: AppLanguage
    @Published var appearanceMode: AppearanceMode
    @Published var refreshInterval: RefreshInterval
    @Published var dailyLineNotifications: Bool
    @Published var overLineNotifications: Bool
    @Published var resetApproachingNotifications: Bool
    @Published var excludedBudgetDayIDs: Set<String>

    private let authStore = CodexAuthStore()
    private let authLoginService = OpenAIAuthLoginService()
    private let usageClient = UsageClient()
    private let historyStore = UsageHistoryStore()
    private let notifications = NotificationCoordinator()
    private let speedWindowStartedAt = Date()
    private var autoRefreshTask: Task<Void, Never>?

    init(defaults: UserDefaults = .standard) {
        language = AppLanguage(rawValue: defaults.string(forKey: "language") ?? "") ?? .zhHans
        appearanceMode = AppearanceMode(rawValue: defaults.string(forKey: "appearanceMode") ?? "") ?? .system
        refreshInterval = RefreshInterval(rawValue: defaults.integer(forKey: "refreshInterval")) ?? .tenMinutes
        dailyLineNotifications = defaults.object(forKey: "dailyLineNotifications") as? Bool ?? true
        overLineNotifications = defaults.object(forKey: "overLineNotifications") as? Bool ?? true
        resetApproachingNotifications = defaults.object(forKey: "resetApproachingNotifications") as? Bool ?? true
        excludedBudgetDayIDs = Set(defaults.stringArray(forKey: "excludedBudgetDayIDs") ?? [])

        autoRefreshTask = Task { [weak self] in
            await self?.runAutoRefreshLoop()
        }
    }

    deinit {
        autoRefreshTask?.cancel()
    }

    var menuBarSymbolName: String {
        switch plan?.risk {
        case .critical:
            return "gauge.with.dots.needle.bottom.100percent"
        case .limit:
            return "gauge.with.dots.needle.67percent"
        case .watch:
            return "gauge.with.dots.needle.50percent"
        default:
            return "calendar.badge.clock"
        }
    }

    func text(_ key: LocalizedKey) -> String {
        LocalizationCatalog.text(key, language: language)
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let credentials = try authStore.loadCredentials()
            accountLabel = credentials.accountLabel
            let usage = try await fetchUsageRefreshingAuthIfNeeded(credentials: credentials)
            applyUsage(usage)
        } catch {
            errorMessage = error.localizedDescription
            if error is AuthStoreError {
                accountLabel = nil
                needsAuthorization = true
            }
            if plan == nil {
                plan = nil
            }
        }
    }

    func signIn() async {
        guard !isSigningIn else { return }
        isSigningIn = true
        errorMessage = nil
        defer { isSigningIn = false }

        do {
            let tokens = try await authLoginService.signIn()
            try authStore.saveCredentials(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                idToken: tokens.idToken
            )
            needsAuthorization = false
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
            needsAuthorization = true
        }
    }

    func signOut() {
        try? authStore.deleteCredentials()
        snapshot = nil
        plan = nil
        accountLabel = nil
        lastRefreshDate = nil
        errorMessage = nil
        needsAuthorization = true
    }

    func toggleBudgetDay(_ day: BudgetDayPlan) {
        if day.isExcluded {
            excludedBudgetDayIDs.remove(day.dayID)
        } else {
            let activeCount = plan?.budgetDays.filter { !$0.isExcluded }.count ?? 1
            guard activeCount > 1 else { return }
            excludedBudgetDayIDs.insert(day.dayID)
        }
        UserDefaults.standard.set(Array(excludedBudgetDayIDs).sorted(), forKey: "excludedBudgetDayIDs")
        recalculateCurrentPlan()
    }

    func savePreferences() {
        UserDefaults.standard.set(language.rawValue, forKey: "language")
        UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        UserDefaults.standard.set(refreshInterval.rawValue, forKey: "refreshInterval")
        UserDefaults.standard.set(dailyLineNotifications, forKey: "dailyLineNotifications")
        UserDefaults.standard.set(overLineNotifications, forKey: "overLineNotifications")
        UserDefaults.standard.set(resetApproachingNotifications, forKey: "resetApproachingNotifications")
        recalculateCurrentPlan()
    }

    private var notificationPreferences: NotificationPreferences {
        NotificationPreferences(
            dailyLine: dailyLineNotifications,
            overLine: overLineNotifications,
            resetApproaching: resetApproachingNotifications
        )
    }

    private func fetchUsageRefreshingAuthIfNeeded(credentials: CodexCredentials) async throws -> UsageSnapshot {
        do {
            return try await usageClient.fetchUsage(credentials: credentials)
        } catch UsageClientError.badStatus(let status, _) where status == 401 || status == 403 {
            let tokens = try await authLoginService.refresh(credentials: credentials)
            try authStore.saveCredentials(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                idToken: tokens.idToken
            )
            let refreshedCredentials = try authStore.loadCredentials()
            accountLabel = refreshedCredentials.accountLabel
            return try await usageClient.fetchUsage(credentials: refreshedCredentials)
        }
    }

    private func applyUsage(_ usage: UsageSnapshot) {
        let now = Date()
        let samples = historyStore.appending(snapshot: usage, now: now)
        snapshot = usage
        lastRefreshDate = now
        errorMessage = nil
        needsAuthorization = false
        plan = makePlan(from: usage, samples: samples, now: now)
        pruneSkippedDays()
        if let plan {
            Task {
                await notifications.notifyIfNeeded(plan: plan, preferences: notificationPreferences)
            }
        }
    }

    private func recalculateCurrentPlan() {
        guard let snapshot else { return }
        let now = Date()
        let samples = historyStore.loadSamples()
        plan = makePlan(from: snapshot, samples: samples, now: now)
        pruneSkippedDays()
    }

    private func makePlan(from snapshot: UsageSnapshot, samples: [UsageSample], now: Date) -> BudgetPlan? {
        let weeklyWindow = snapshot.oneWeek
        let weeklyUsed = weeklyWindow?.usedPercent ?? 0
        let fiveHourUsed = snapshot.fiveHour?.usedPercent ?? 0
        let resetAt = weeklyWindow?.resetAt
            .map { Date(timeIntervalSince1970: TimeInterval($0)) }
            ?? now.addingTimeInterval(7 * 24 * 60 * 60)

        return BudgetPlanner.makePlan(
            now: now,
            resetAt: resetAt,
            weeklyUsedPercent: weeklyUsed,
            fiveHourUsedPercent: fiveHourUsed,
            samples: samples,
            excludedDayIDs: excludedBudgetDayIDs,
            speedWindowStartedAt: speedWindowStartedAt
        )
    }

    private func pruneSkippedDays() {
        guard let plan else { return }
        let pruned = Set(plan.budgetDays.filter(\.isExcluded).map(\.dayID))
        guard pruned != excludedBudgetDayIDs else { return }
        excludedBudgetDayIDs = pruned
        UserDefaults.standard.set(Array(pruned).sorted(), forKey: "excludedBudgetDayIDs")
    }

    private func runAutoRefreshLoop() async {
        while !Task.isCancelled {
            await refresh()
            let seconds = UInt64(max(refreshInterval.rawValue, 60))
            try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
        }
    }
}
