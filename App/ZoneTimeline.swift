import SwiftUI
import ZonesKit

/// Every zone on one shared axis: the viewer's local day. Each bar labels its own
/// local hours, so the shift between zones reads at a glance.
struct ZoneTimeline: View {
    let zones: [Zone]
    let use24Hour: Bool
    let now: Date

    private var axis: TimelineAxis { .day(containing: now, in: .current) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(zones) { zone in
                ZoneRow(zone: zone, axis: axis, now: now, use24Hour: use24Hour)
            }
        }
    }
}
