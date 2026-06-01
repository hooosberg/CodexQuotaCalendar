import Foundation
import SwiftUI

struct UsageSnapshot: Codable, Equatable {
    var fetchedAt: Int64
    var planType: String?
    var fiveHour: UsageWindow?
    var oneWeek: UsageWindow?
    var credits: CreditSnapshot?
}

struct UsageWindow: Codable, Equatable {
    var usedPercent: Double
    var windowSeconds: Int64
    var resetAt: Int64?
}

struct CreditSnapshot: Codable, Equatable {
    var hasCredits: Bool
    var unlimited: Bool
    var balance: String?
}

struct UsageSample: Codable, Equatable {
    var capturedAt: Date
    var weeklyUsedPercent: Double
}

enum RiskLevel: String, Codable, Equatable {
    case good
    case watch
    case limit
    case critical

    var color: Color {
        switch self {
        case .good:
            return .green
        case .watch:
            return .yellow
        case .limit:
            return .orange
        case .critical:
            return .red
        }
    }

    var symbolName: String {
        switch self {
        case .good:
            return "checkmark.circle.fill"
        case .watch:
            return "speedometer"
        case .limit:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "xmark.octagon.fill"
        }
    }
}

struct DailyPacingPoint: Identifiable, Equatable {
    var id: Date { date }
    var date: Date
    var dailyUsedPercent: Double
    var budgetUsagePercent: Double
}

struct BudgetDayPlan: Identifiable, Equatable {
    var id: String { dayID }
    var dayID: String
    var date: Date
    var isToday: Bool
    var isExcluded: Bool
    var dailyBudgetPercent: Double
    var usedPercent: Double
    var budgetUsagePercent: Double
}

struct CalendarHeatmapDay: Identifiable, Equatable {
    var id: Date { date }
    var date: Date
    var intensity: Double
    var isInCurrentMonth: Bool
}

struct BudgetPlan: Equatable {
    var now: Date
    var resetAt: Date
    var weeklyUsedPercent: Double
    var fiveHourUsedPercent: Double
    var weeklyRemainingPercent: Double
    var fiveHourRemainingPercent: Double
    var baseDailyAllowancePercent: Double
    var dailyAllowancePercent: Double
    var pacingBalancePercent: Double
    var todayBaselineWeeklyUsedPercent: Double
    var todayUsedPercent: Double
    var todayRemainingAllowancePercent: Double
    var todayBudgetUsedPercent: Double
    var todayBudgetRemainingPercent: Double
    var workHoursPerDay: Double
    var hourlyBudgetPercent: Double
    var hourlyBudgetSharePercent: Double
    var halfHourUsagePercentPerHour: Double
    var halfHourBudgetSpeedPercentPerHour: Double
    var recentUsagePercentPerDay: Double
    var predictedDailyAllowanceExhaustionAt: Date?
    var predictedExhaustionAt: Date?
    var risk: RiskLevel
    var activeBudgetDayCount: Int
    var budgetDays: [BudgetDayPlan]
    var monthHeatmap: [CalendarHeatmapDay]
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case day
    case night

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .day:
            return .light
        case .night:
            return .dark
        }
    }
}

enum RefreshInterval: Int, CaseIterable, Identifiable {
    case fiveMinutes = 300
    case tenMinutes = 600
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    case oneHour = 3600

    var id: Int { rawValue }
}
