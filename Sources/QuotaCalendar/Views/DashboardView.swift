import SwiftUI

private enum MenuSection: String, CaseIterable, Identifiable {
    case overview
    case settings
    case notifications
    case about

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .overview: return "chart.pie"
        case .settings: return "gearshape"
        case .notifications: return "bell"
        case .about: return "info.circle"
        }
    }
}

struct DashboardView: View {
    @ObservedObject var model: DashboardModel
    @State private var section: MenuSection = .overview

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 8)

            Divider()

            content
        }
        .background(.regularMaterial)
    }

    @ViewBuilder
    private var content: some View {
        if section == .overview {
            overviewContent
        } else {
            VStack(spacing: 0) {
                sectionPicker
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                Divider()
                switch section {
                case .overview:
                    overviewContent
                case .settings:
                    SettingsView(model: model)
                case .notifications:
                    ReminderSettingsView(model: model)
                case .about:
                    AboutView(model: model)
                }
            }
        }
    }

    private var overviewContent: some View {
        VStack(spacing: 8) {
            if let plan = model.plan {
                TodayRingCard(model: model, plan: plan)
                RemainingBudgetDaysCard(model: model, plan: plan)
                SystemQuotaStatsCard(model: model, plan: plan, snapshot: model.snapshot)
                homepageFooterLinks
            } else {
                EmptyUsageView(model: model)
                homepageFooterLinks
            }
        }
        .padding(14)
    }

    @ViewBuilder
    private var homepageFooterLinks: some View {
        ResourceLinksCard(model: model)
    }

    private var sectionPicker: some View {
        Picker("", selection: $section) {
            Text(model.text(.overview)).tag(MenuSection.overview)
            Text(model.text(.settings)).tag(MenuSection.settings)
            Text(model.text(.notifications)).tag(MenuSection.notifications)
            Text(model.text(.about)).tag(MenuSection.about)
        }
        .pickerStyle(.segmented)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: model.menuBarSymbolName)
                .font(.system(size: 24, weight: .semibold))
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 2) {
                Text(model.text(.appName))
                    .font(.headline)
                Text(headerSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if section == .overview {
                Button {
                    Task { await model.refresh() }
                } label: {
                    Image(systemName: model.isRefreshing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help(model.text(.refreshNow))
                .disabled(model.isRefreshing)
            } else {
                Button {
                    section = .overview
                } label: {
                    Image(systemName: "chart.pie")
                }
                .buttonStyle(.borderless)
                .help(model.text(.overview))
            }

            Button {
                section = section == .settings ? .overview : .settings
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help(model.text(.settings))
        }
    }

    private var headerSubtitle: String {
        if let date = model.lastRefreshDate {
            let updated = String(format: model.text(.updatedAt), date.formatted(date: .omitted, time: .shortened))
            if let accountLabel = model.accountLabel {
                return "\(updated) · \(accountLabel)"
            }
            return updated
        }
        return model.errorMessage ?? model.text(.privacySummary)
    }
}

private struct EmptyUsageView: View {
    @ObservedObject var model: DashboardModel

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: model.needsAuthorization ? "person.crop.circle.badge.plus" : "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(model.needsAuthorization ? model.text(.signInWithChatGPT) : model.text(.waitingForUsage))
                .font(.title3.weight(.semibold))
            Text(emptyBody)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            if model.needsAuthorization {
                Button {
                    Task { await model.signIn() }
                } label: {
                    Label(model.isSigningIn ? model.text(.signingIn) : model.text(.signInWithChatGPT), systemImage: "person.badge.key")
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.isSigningIn)
            } else {
                Button {
                    Task { await model.refresh() }
                } label: {
                    Label(model.text(.refreshNow), systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }

            Text(model.text(.authPrivacy))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var emptyBody: String {
        if model.needsAuthorization {
            if model.isSigningIn {
                return model.text(.signingIn)
            }
            return model.errorMessage ?? model.text(.signInIntro)
        }
        return model.errorMessage ?? model.text(.waitingForUsageBody)
    }
}
