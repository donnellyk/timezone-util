import SwiftUI

@main
struct ZonesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var state = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContent(state: state)
        } label: {
            // The menu-bar icon is a persistent view, so it hosts the other windows.
            Image(systemName: "globe.americas.fill")
                .zonesPanel(isPresented: $state.panelPresented) {
                    MenuContent(state: state)
                }
                .settingsWindow(
                    isPresented: $state.settingsPresented, size: CGSize(width: 500, height: 560)
                ) {
                    SettingsView(settings: state.settings)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
