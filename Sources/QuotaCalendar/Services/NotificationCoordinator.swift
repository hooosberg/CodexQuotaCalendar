import Foundation
import UserNotifications

struct NotificationPreferences {
    var dailyLine: Bool
    var overLine: Bool
    var resetApproaching: Bool
}

struct NotificationCoordinator {
    func requestAuthorizationIfNeeded() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }

    func notifyIfNeeded(plan: BudgetPlan, preferences: NotificationPreferences) async {
        guard preferences.dailyLine, plan.risk == .limit else { return }
        await requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Codex Quota Calendar"
        content.body = "Today's Codex budget is used. Slow down or rebalance your remaining days."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "quota-calendar-daily-line-\(Int(plan.now.timeIntervalSince1970))",
            content: content,
            trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
