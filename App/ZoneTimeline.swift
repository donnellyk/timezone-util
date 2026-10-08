import SwiftUI
import ZonesKit

/// Every zone on one shared axis: the viewer's local day. Each bar labels its own
/// local hours, so the shift between zones reads at a glance. Hovering anywhere over
/// the rows picks one moment on that axis and shows it in every zone.
struct ZoneTimeline: View {
    let zones: [Zone]
    let use24Hour: Bool
    let now: Date
    @Binding var hovered: Date?

    @State private var width: CGFloat = 1

    private var axis: TimelineAxis { .day(containing: now, in: .current) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(zones) { zone in
                ZoneRow(
                    zone: zone, axis: axis, now: now, hovered: hovered, use24Hour: use24Hour)
            }
        }
        .contentShape(Rectangle())
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: {
            width = $0
        }
        .onContinuousHover { phase in
            hovered =
                switch phase {
                case .active(let location): axis.date(at: location.x / width, roundedTo: 15 * 60)
                case .ended: nil
                }
        }
    }
}
