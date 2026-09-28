import SwiftUI
import ZonesKit

struct ZoneEditorRow: View {
    @Binding var zone: Zone
    let use24Hour: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                TextField("Name", text: $zone.name, prompt: Text(zone.cityName))
                    .labelsHidden()
                    .textFieldStyle(.plain)
                    .font(.body.weight(.semibold))
                Text("\(zone.cityName) · \(zone.timeZone.abbreviation() ?? zone.timeZoneID)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .help("Remove \(zone.displayName)")
            }
            HStack(spacing: 6) {
                Text("Workday")
                    .foregroundStyle(.secondary)
                Spacer()
                TimeOfDayPicker(selection: $zone.workday.start, use24Hour: use24Hour)
                Text("to")
                    .foregroundStyle(.secondary)
                TimeOfDayPicker(selection: $zone.workday.end, use24Hour: use24Hour)
            }
            .font(.callout)
        }
        .padding(.vertical, 2)
    }
}
