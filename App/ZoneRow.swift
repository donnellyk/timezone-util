import SwiftUI
import ZonesKit

struct ZoneRow: View {
    let zone: Zone
    let axis: TimelineAxis
    let now: Date
    let use24Hour: Bool

    private var details: String {
        [
            zone.timeZone.abbreviation(for: now),
            ClockText.offset(of: zone.timeZone, from: axis.timeZone, at: now),
            ClockText.dayRelation(of: now, in: zone.timeZone, relativeTo: axis.timeZone),
        ]
        .compactMap(\.self)
        .joined(separator: " · ")
    }

    var body: some View {
        let workdays = zone.workday.intervals(overlapping: axis.span, in: zone.timeZone)
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline) {
                    Text(zone.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    Text(ClockText.time(now, in: zone.timeZone, use24Hour: use24Hour))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .monospacedDigit()
                }
                HStack(alignment: .firstTextBaseline) {
                    Text(details)
                    Spacer(minLength: 12)
                    if let status = ClockText.status(
                        zone.workday.status(at: now, in: zone.timeZone))
                    {
                        Text(status)
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            }
            TimelineTrack(
                work: axis.segments(for: workdays),
                elapsed: axis.segments(for: workdays, before: now),
                ticks: axis.ticks(everyHours: 3, in: zone.timeZone),
                now: axis.fraction(of: now),
                use24Hour: use24Hour)
        }
        .help(
            "Workday \(ClockText.range(zone.workday, use24Hour: use24Hour)) \(zone.cityName) time")
    }
}
