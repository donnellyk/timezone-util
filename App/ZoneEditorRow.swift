import SwiftUI
import ZonesKit

struct ZoneEditorRow: View {
    @Binding var zone: Zone
    let use24Hour: Bool
    let onDelete: () -> Void
    let onDrop: (Zone.ID) -> Void

    @State private var isDropTarget = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.tertiary)
                .frame(width: 16, height: 32)
                .contentShape(Rectangle())
                .pointerStyle(.grabIdle)
                .help("Drag to reorder")
                .draggable(ZoneDrag(id: zone.id)) {
                    Text(zone.displayName)
                        .font(.body.weight(.semibold))
                        .padding(8)
                }
            fields
        }
        .padding(.vertical, 2)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.accentColor.opacity(isDropTarget ? 0.15 : 0))
                .padding(-4)
        }
        .dropDestination(for: ZoneDrag.self) { drags, _ in
            drags.first.map { onDrop($0.id) } != nil
        } isTargeted: {
            isDropTarget = $0
        }
    }

    private var fields: some View {
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
    }
}
