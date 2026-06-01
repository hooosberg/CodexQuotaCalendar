import SwiftUI

@main
struct QuotaCalendarApp: App {
    @StateObject private var model = DashboardModel()
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue

    var body: some Scene {
        MenuBarExtra {
            DashboardView(model: model)
                .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme)
                .frame(width: 500)
                .task {
                    await model.refresh()
                }
        } label: {
            Label {
                Text(model.text(.appName))
            } icon: {
                Image(systemName: model.menuBarSymbolName)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
