import AppKit
import SwiftUI

struct TodayRingCard: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan

    private var pressure: Double {
        min(1.35, plan.todayBudgetUsedPercent / 100)
    }

    private var rawPressure: Double {
        plan.todayBudgetUsedPercent / 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(model.text(.todayUsage), systemImage: plan.risk.symbolName)
                    .font(.headline)
                    .foregroundStyle(plan.risk.color)
                Spacer()
                Text(riskTitle)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(plan.risk.color)
            }

            HStack(alignment: .bottom, spacing: 18) {
                VStack(spacing: 9) {
                    ZStack {
                        Circle()
                            .stroke(.secondary.opacity(0.18), lineWidth: 10)
                        Circle()
                            .trim(from: 0, to: min(pressure, 1))
                            .stroke(plan.risk.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text(percent(rawPressure * 100))
                            .font(.title2.weight(.bold))
                    }
                    .frame(width: 84, height: 84)

                    Text(model.text(.todayBudgetUsage))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .frame(width: 106, alignment: .bottom)
                        .frame(height: 24, alignment: .bottom)
                }
                .frame(width: 116, alignment: .center)

                VStack(alignment: .trailing, spacing: 9) {
                    metricRow(model.text(.todayBudget), "\(percent(plan.dailyAllowancePercent))\(model.text(.perWeekSuffix))")
                    metricRow(model.text(.expectedTodayRunout), dailyAllowanceExhaustionText)
                }
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var riskTitle: String {
        switch plan.risk {
        case .good: return model.text(.comfortablePace)
        case .watch: return model.text(.watchPace)
        case .limit: return model.text(.pastDailyLine)
        case .critical: return model.text(.mayRunOutEarly)
        }
    }

    private var dailyAllowanceExhaustionText: String {
        if plan.todayRemainingAllowancePercent <= 0 {
            return model.text(.todayBudgetDepleted)
        }
        guard let date = plan.predictedDailyAllowanceExhaustionAt else {
            return model.text(.noActiveBurnRate)
        }
        return String(
            format: model.text(.runsOutAt),
            date.formatted(date: .omitted, time: .shortened)
        )
    }

    private func metricRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Text("\(title)\(metricColon)")
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.64)
                .fixedSize(horizontal: false, vertical: true)
            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .layoutPriority(2)
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var metricColon: String {
        switch model.language {
        case .zhHans, .zhHant, .ja, .ko:
            return "："
        default:
            return ":"
        }
    }
}

struct SystemQuotaStatsCard: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan
    var snapshot: UsageSnapshot?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(model.text(.systemQuotaStats), systemImage: "server.rack")
                .font(.headline)

            UsageBar(
                title: model.text(.fiveHourWindow),
                usedPercent: plan.fiveHourUsedPercent,
                resetText: resetText(snapshot?.fiveHour?.resetAt, includeWeekday: false),
                color: .purple
            )
            UsageBar(
                title: model.text(.weeklyWindow),
                usedPercent: plan.weeklyUsedPercent,
                resetText: resetText(snapshot?.oneWeek?.resetAt, includeWeekday: true),
                color: plan.risk.color
            )
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func resetText(_ unixSeconds: Int64?, includeWeekday: Bool) -> String {
        guard let unixSeconds else { return "" }
        let date = Date(timeIntervalSince1970: TimeInterval(unixSeconds))
        return QuotaTextFormatter.resetSummary(
            resetAt: date,
            now: plan.now,
            language: model.language,
            includeWeekday: includeWeekday
        )
    }
}

struct ResourceLinksCard: View {
    @ObservedObject var model: DashboardModel

    private let officialURL = URL(string: "https://chatgpt.com/codex/cloud/settings/analytics")!
    private let resetWatcherURL = URL(string: "https://x.com/thsottiaux")!

    var body: some View {
        VStack(spacing: 0) {
            ResourceLinkRow(
                systemImage: "safari",
                tint: .blue,
                title: model.text(.officialQuotaPage),
                subtitle: model.text(.officialQuotaPageNote),
                url: officialURL
            )
            Divider()
                .padding(.leading, 38)
            ResourceLinkRow(
                systemImage: "sparkles",
                tint: .yellow,
                title: model.text(.resetWatcherTitle),
                subtitle: model.text(.resetWatcherNote),
                url: resetWatcherURL
            )
        }
        .padding(.vertical, 4)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ResourceLinkRow: View {
    var systemImage: String
    var tint: Color
    var title: String
    var subtitle: String
    var url: URL

    var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct RemainingBudgetDaysCard: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(model.text(.sevenDayPacing), systemImage: "calendar.badge.clock")
                .font(.headline)

            HStack(spacing: 6) {
                ForEach(plan.budgetDays) { day in
                    BudgetDayTile(model: model, plan: plan, day: day)
                }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct BudgetDayTile: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan
    var day: BudgetDayPlan

    var body: some View {
        Button {
            model.toggleBudgetDay(day)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(dateText)
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)
                    Text(weekdayText)
                        .font(.caption2.weight(day.isToday ? .semibold : .regular))
                        .foregroundStyle(day.isToday ? plan.risk.color : .secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                VStack(alignment: .leading, spacing: 5) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.secondary.opacity(day.isExcluded ? 0.08 : 0.14))
                            Capsule()
                                .fill(progressColor.gradient)
                                .frame(width: proxy.size.width * CGFloat(progress))
                        }
                    }
                    .frame(height: 5)

                    Text(footerText)
                        .font(.caption2.weight(.semibold).monospacedDigit())
                        .foregroundStyle(day.isExcluded ? .secondary : .primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 7)
            .padding(.vertical, 6)
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .background(tileBackground, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: day.isToday ? 1.2 : 1)
            }
            .opacity(day.isExcluded ? 0.72 : 1)
        }
        .buttonStyle(.plain)
        .help(day.isExcluded ? model.text(.restoreDay) : model.text(.skipDay))
    }

    private var progress: Double {
        guard !day.isExcluded else { return 0 }
        return min(1, max(0, day.budgetUsagePercent / 100))
    }

    private var progressColor: Color {
        if day.budgetUsagePercent >= 100 {
            return plan.risk.color
        }
        if day.isToday {
            return .blue
        }
        return .green
    }

    private var tileBackground: some ShapeStyle {
        if day.isExcluded {
            return AnyShapeStyle(.secondary.opacity(0.07))
        }
        if day.isToday {
            return AnyShapeStyle(plan.risk.color.opacity(0.12))
        }
        return AnyShapeStyle(.secondary.opacity(0.08))
    }

    private var borderColor: Color {
        if day.isToday {
            return plan.risk.color.opacity(0.50)
        }
        if day.isExcluded {
            return .secondary.opacity(0.12)
        }
        return .clear
    }

    private var footerText: String {
        if day.isExcluded {
            return model.text(.skippedDay)
        }
        return usedText
    }

    private var usedText: String {
        String(format: model.text(.usedPercentLabel), percent(day.budgetUsagePercent))
    }

    private var dateText: String {
        let components = Calendar.current.dateComponents([.month, .day], from: day.date)
        return "\(components.month ?? 0)/\(components.day ?? 0)"
    }

    private var weekdayText: String {
        if day.isToday {
            return model.text(.todayLabel)
        }
        return QuotaTextFormatter.weekdayText(for: day.date, language: model.language)
    }
}

struct MonthHeatmapView: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(model.text(.monthlyHeatmap), systemImage: "calendar")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(plan.monthHeatmap) { day in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color(for: day))
                        .overlay(alignment: .center) {
                            Text("\(Calendar.current.component(.day, from: day.date))")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(day.isInCurrentMonth ? Color.primary.opacity(0.75) : Color.secondary.opacity(0.35))
                        }
                        .frame(height: 20)
                }
            }
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private func color(for day: CalendarHeatmapDay) -> Color {
        guard day.isInCurrentMonth else { return .secondary.opacity(0.08) }
        switch day.intensity {
        case 0..<0.35: return .green.opacity(0.22)
        case 0.35..<0.6: return .yellow.opacity(0.34)
        case 0.6..<0.85: return .orange.opacity(0.46)
        default: return .red.opacity(0.58)
        }
    }
}

struct NotificationStatusRow: View {
    @ObservedObject var model: DashboardModel

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.badge")
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.text(.notifications))
                    .font(.headline)
                Text(model.text(.notificationSummary))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct UsageBar: View {
    var title: String
    var usedPercent: Double
    var resetText: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(.callout.weight(.medium))
                Spacer()
                Text(detailText)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.secondary.opacity(0.14))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.gradient)
                        .frame(width: proxy.size.width * CGFloat(min(1, max(0, usedPercent / 100))))
                }
            }
            .frame(height: 9)
        }
    }

    private var detailText: String {
        if resetText.isEmpty {
            return percent(usedPercent)
        }
        return "\(percent(usedPercent)) · \(resetText)"
    }
}

func percent(_ value: Double) -> String {
    QuotaTextFormatter.percent(value)
}
