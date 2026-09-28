import ServiceManagement
import SwiftUI

/// "Start at Login", backed by the app's login item. The user can also change it in
/// System Settings, so the toggle reads the live status instead of a stored preference.
struct LaunchAtLoginToggle: View {
    @State private var status = SMAppService.mainApp.status
    @State private var error = ""
    @Environment(\.appearsActive) private var appearsActive

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(
                "Start at login",
                isOn: Binding(get: { status == .enabled }, set: { setEnabled($0) }))
            if status == .requiresApproval {
                Button("Approve in System Settings…") {
                    SMAppService.openSystemSettingsLoginItems()
                }
                .buttonStyle(.link)
                .font(.caption)
            }
            if !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
            }
        }
        .onChange(of: appearsActive) { refresh() }
        .onAppear(perform: refresh)
    }

    private func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            error = ""
        } catch {
            self.error = error.localizedDescription
        }
        refresh()
    }

    private func refresh() {
        status = SMAppService.mainApp.status
    }
}
