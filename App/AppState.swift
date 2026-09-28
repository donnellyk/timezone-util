import KeyboardShortcuts
import Observation

@MainActor
@Observable
final class AppState {
    static let shared = AppState()

    let settings = SettingsStore()
    var settingsPresented = false
    /// The shortcut panel; the menu-bar click keeps its own window.
    var panelPresented = false

    private init() {}

    func registerShortcut() {
        KeyboardShortcuts.onKeyUp(for: .toggleZones) {
            Task { @MainActor in AppState.shared.panelPresented.toggle() }
        }
    }
}
