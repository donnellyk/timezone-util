import KeyboardShortcuts
import SwiftUI
import ZonesKit

struct SettingsView: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Form {
            Section {
                ForEach($settings.zones) { $zone in
                    ZoneEditorRow(zone: $zone, use24Hour: settings.use24Hour) {
                        settings.remove(zone.id)
                    }
                }
                .onMove { settings.zones.move(fromOffsets: $0, toOffset: $1) }
                ZoneSearch(use24Hour: settings.use24Hour, onAdd: settings.add)
            } header: {
                Text("Time Zones")
            } footer: {
                Text("Drag to reorder. The name is what the menu shows.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("General") {
                KeyboardShortcuts.Recorder("Show Zones", name: .toggleZones)
                Toggle("24-hour clock", isOn: $settings.use24Hour)
                LaunchAtLoginToggle()
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 460, minHeight: 480)
    }
}
