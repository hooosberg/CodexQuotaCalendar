import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: DashboardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsGroupCard(title: model.text(.account)) {
                HStack {
                    Text(model.accountLabel ?? model.text(.signedOut))
                        .lineLimit(1)
                    Spacer()
                    if model.accountLabel == nil {
                        Button(model.text(.signInWithChatGPT)) {
                            Task { await model.signIn() }
                        }
                        .disabled(model.isSigningIn)
                    } else {
                        Button(model.text(.signOut), role: .destructive) {
                            model.signOut()
                        }
                    }
                }
                Divider()
                Text(model.text(.authPrivacy))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SettingsGroupCard {
                SettingsControlRow(title: model.text(.language)) {
                    Picker("", selection: $model.language) {
                        ForEach(AppLanguage.supported) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 128, alignment: .trailing)
                }
                Divider()

                SettingsControlRow(title: model.text(.appearance)) {
                    Picker("", selection: $model.appearanceMode) {
                        Text(model.text(.appearanceSystem)).tag(AppearanceMode.system)
                        Text(model.text(.appearanceDay)).tag(AppearanceMode.day)
                        Text(model.text(.appearanceNight)).tag(AppearanceMode.night)
                    }
                    .labelsHidden()
                    .frame(width: 128, alignment: .trailing)
                }
                Divider()

                SettingsControlRow(title: model.text(.refreshInterval)) {
                    Picker("", selection: $model.refreshInterval) {
                        Text(model.text(.fiveMinutes)).tag(RefreshInterval.fiveMinutes)
                        Text(model.text(.tenMinutes)).tag(RefreshInterval.tenMinutes)
                        Text(model.text(.fifteenMinutes)).tag(RefreshInterval.fifteenMinutes)
                        Text(model.text(.thirtyMinutes)).tag(RefreshInterval.thirtyMinutes)
                        Text(model.text(.oneHour)).tag(RefreshInterval.oneHour)
                    }
                    .labelsHidden()
                    .frame(width: 128, alignment: .trailing)
                }
            }

            if let plan = model.plan {
                SettingsGroupCard {
                    DailyAverageFormulaSettingsRow(model: model, plan: plan)
                }
            }

            SettingsGroupCard(title: model.text(.appControls)) {
                Button(role: .destructive) {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label(model.text(.quitApp), systemImage: "power")
                }

                Divider()
                Text(model.text(.quitAppNote))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: model.language) { _, _ in model.savePreferences() }
        .onChange(of: model.appearanceMode) { _, _ in model.savePreferences() }
        .onChange(of: model.refreshInterval) { _, _ in model.savePreferences() }
    }
}

private struct SettingsGroupCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline)
                    .padding(.horizontal, 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct SettingsControlRow<Control: View>: View {
    var title: String
    @ViewBuilder var control: Control

    init(title: String, @ViewBuilder control: () -> Control) {
        self.title = title
        self.control = control()
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            control
        }
    }
}

private struct DailyAverageFormulaSettingsRow: View {
    @ObservedObject var model: DashboardModel
    var plan: BudgetPlan
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formulaText)
                    .font(.callout.weight(.semibold).monospacedDigit())
                Text(activeDaysText)
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.green)
                Text(model.text(.dailyAverageFormulaNote))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 6)
        } label: {
            HStack {
                Label(model.text(.dailyAverageAlgorithm), systemImage: "divide.circle")
                Spacer()
                Text("\(percent(plan.dailyAllowancePercent))\(model.text(.perDaySuffix))")
                    .font(.callout.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var formulaText: String {
        String(
            format: model.text(.dailyAverageFormula),
            percent(plan.weeklyRemainingPercent),
            plan.activeBudgetDayCount,
            percent(plan.dailyAllowancePercent)
        )
    }

    private var activeDaysText: String {
        String(format: model.text(.activeDaysRebalanced), plan.activeBudgetDayCount)
    }
}

struct ReminderSettingsView: View {
    @ObservedObject var model: DashboardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsGroupCard {
                Toggle(model.text(.dailyLine), isOn: $model.dailyLineNotifications)
                Divider()
                Toggle(model.text(.overLine), isOn: $model.overLineNotifications)
                Divider()
                Toggle(model.text(.resetApproaching), isOn: $model.resetApproachingNotifications)
            }
        }
        .padding(18)
        .fixedSize(horizontal: false, vertical: true)
        .onChange(of: model.dailyLineNotifications) { _, _ in model.savePreferences() }
        .onChange(of: model.overLineNotifications) { _, _ in model.savePreferences() }
        .onChange(of: model.resetApproachingNotifications) { _, _ in model.savePreferences() }
    }
}

struct AboutView: View {
    @ObservedObject var model: DashboardModel

    private let githubURL = URL(string: "https://github.com/hooosberg")!
    private let authorXURL = URL(string: "https://x.com/mX1D109MHW29394")!
    private let landingPageURL = URL(string: "https://hooosberg.github.io/QuotaCalendar/")!
    private let releasesURL = URL(string: "https://github.com/hooosberg/QuotaCalendar/releases")!

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.secondary.opacity(0.12))
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 30, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 3) {
                    Text(model.text(.appName))
                        .font(.title2.weight(.bold))
                    Text(model.text(.aboutSubtitle))
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(model.text(.aboutTagline))
                .font(.callout.weight(.semibold))
                .foregroundStyle(.green)

            Text(model.text(.aboutBody))
                .font(.body)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text(model.text(.aboutLocalPromise))
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 0) {
                AboutInfoRow(
                    systemImage: "number",
                    title: model.text(.aboutVersion),
                    detail: AppVersion.displayString
                )
                Divider()
                    .padding(.leading, 38)
                AboutLinkRow(
                    systemImage: "arrow.down.circle",
                    title: model.text(.aboutUpdateSoftware),
                    detail: model.text(.aboutUpdateSoftwareNote),
                    value: "GitHub Releases",
                    url: releasesURL
                )
                Divider()
                    .padding(.leading, 38)
                AboutLinkRow(
                    systemImage: "chevron.left.forwardslash.chevron.right",
                    title: model.text(.aboutGithub),
                    detail: model.text(.aboutGithubNote),
                    value: "github.com/hooosberg",
                    url: githubURL
                )
                Divider()
                    .padding(.leading, 38)
                AboutLinkRow(
                    systemImage: "at",
                    title: model.text(.aboutAuthorX),
                    detail: model.text(.aboutAuthorXNote),
                    value: "x.com/mX1D109MHW29394",
                    url: authorXURL
                )
                Divider()
                    .padding(.leading, 38)
                AboutLinkRow(
                    systemImage: "envelope",
                    title: model.text(.aboutEmail),
                    detail: model.text(.aboutEmailNote),
                    value: model.text(.aboutSupportEmail),
                    url: supportEmailURL
                )
                Divider()
                    .padding(.leading, 38)
                AboutLinkRow(
                    systemImage: "globe",
                    title: model.text(.aboutLandingPage),
                    detail: model.text(.aboutLandingPageNote),
                    value: "hooosberg.github.io/QuotaCalendar",
                    url: landingPageURL
                )
            }
            .padding(.vertical, 2)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var supportEmailURL: URL {
        URL(string: "mailto:\(model.text(.aboutSupportEmail))")!
    }
}

private struct AboutInfoRow: View {
    var systemImage: String
    var title: String
    var detail: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption2.weight(.medium).monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct AboutLinkRow: View {
    var systemImage: String
    var title: String
    var detail: String
    var value: String
    var url: URL

    var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(value)
                            .font(.caption2.weight(.medium).monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Text(detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
