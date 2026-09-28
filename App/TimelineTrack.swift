import SwiftUI
import ZonesKit

/// One zone's day as a bar: the workday with its elapsed part filled in, the zone's
/// local hours along it, and a tick at the current time.
struct TimelineTrack: View {
    let work: [ClosedRange<Double>]
    let elapsed: [ClosedRange<Double>]
    let ticks: [TimelineTick]
    let now: Double
    let use24Hour: Bool

    @Environment(\.colorScheme) private var colorScheme

    private let barHeight: CGFloat = 18
    private let cornerRadius: CGFloat = 5

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.primary.opacity(0.08))
                bands(work, width: width, fill: Theme.work.opacity(0.3))
                bands(elapsed, width: width, fill: Theme.work)
                ForEach(ticks, id: \.fraction) { tick in
                    Text(ClockText.hourLabel(tick.hour, use24Hour: use24Hour))
                        .font(.system(size: 9, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(
                            isElapsed(tick) ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary)
                        )
                        .fixedSize()
                        .position(
                            x: min(max(width * tick.fraction, 10), width - 10), y: barHeight / 2)
                }
                RoundedRectangle(cornerRadius: 1)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
                    .frame(width: 2, height: barHeight + 4)
                    .offset(x: min(max(width * now - 1, 0), width - 2))
            }
            .frame(width: width, height: barHeight)
        }
        .frame(height: barHeight)
    }

    private func isElapsed(_ tick: TimelineTick) -> Bool {
        elapsed.contains { $0.contains(tick.fraction) }
    }

    private func bands(
        _ segments: [ClosedRange<Double>], width: CGFloat, fill: some ShapeStyle
    )
        -> some View
    {
        ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fill)
                .frame(width: width * (segment.upperBound - segment.lowerBound), height: barHeight)
                .offset(x: width * segment.lowerBound)
        }
    }
}
