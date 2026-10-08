import AppKit
import SwiftUI
import ZonesKit

struct MenuContent: View {
    let state: AppState

    @State private var hovered: Date?

    private var settings: SettingsStore { state.settings }

    var body: some View {
        TimelineView(.everyMinute) { context in
            VStack(alignment: .leading, spacing: 14) {
                MenuHeader(
                    shown: hovered ?? context.date, isHovering: hovered != nil,
                    use24Hour: settings.use24Hour)
                if settings.zones.isEmpty {
                    EmptyZones(openSettings: openSettings)
                } else {
                    ZoneTimeline(
                        zones: settings.zones, use24Hour: settings.use24Hour, now: context.date,
                        hovered: $hovered)
                }
                Divider()
                MenuFooter(openSettings: openSettings)
            }
            .padding(16)
            .frame(width: 380)
        }
    }

    private func openSettings() {
        state.settingsPresented = true
    }
}

private struct MenuHeader: View {
    let shown: Date
    let isHovering: Bool
    let use24Hour: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(shown.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Text(
                "\(ClockText.time(shown, in: .current, use24Hour: use24Hour)) \(TimeZone.current.abbreviation(for: shown) ?? "")"
            )
            .font(.system(size: 11))
            .monospacedDigit()
            .foregroundStyle(isHovering ? AnyShapeStyle(Theme.work) : AnyShapeStyle(.secondary))
        }
    }
}

private struct EmptyZones: View {
    let openSettings: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("No time zones yet")
                .foregroundStyle(.secondary)
            Button("Add Time Zones…", action: openSettings)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct MenuFooter: View {
    let openSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Spacer()
            Button(action: openSettings) { Image(systemName: "gearshape") }
                .help("Settings")
                .keyboardShortcut(",")
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .help("Quit Zones")
            .keyboardShortcut("q")
        }
        .buttonStyle(.borderless)
        .focusEffectDisabled()
        .font(.system(size: 11))
    }
}
