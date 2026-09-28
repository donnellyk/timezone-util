import SwiftUI
import ZonesKit

/// One zone's day as a bar: the workday with its elapsed part filled in and a tick at
/// the current time, over the zone's local hours.
struct TimelineTrack: View {
    let work: [ClosedRange<Double>]
    let elapsed: [ClosedRange<Double>]
    let ticks: [TimelineTick]
    let now: Double
    let use24Hour: Bool

    @Environment(\.colorScheme) private var colorScheme

    private let barHeight: CGFloat = 14
    private let cornerRadius: CGFloat = 4
    private let labelHeight: CGFloat = 11

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            VStack(spacing: 3) {
                bar(width: width)
                labels(width: width)
            }
        }
        .frame(height: barHeight + 3 + labelHeight)
    }

    private func bar(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.primary.opacity(0.08))
            bands(work, width: width, fill: Theme.work.opacity(0.3))
            bands(elapsed, width: width, fill: Theme.work)
            RoundedRectangle(cornerRadius: 1)
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 2, height: barHeight + 4)
                .offset(x: min(max(width * now - 1, 0), width - 2))
        }
        .frame(width: width, height: barHeight)
    }

    private func labels(width: CGFloat) -> some View {
        ZStack {
            ForEach(ticks, id: \.fraction) { tick in
                Text(ClockText.hourLabel(tick.hour, use24Hour: use24Hour))
                    .font(.system(size: 9, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .position(
                        x: min(max(width * tick.fraction, 10), width - 10), y: labelHeight / 2)
            }
        }
        .frame(width: width, height: labelHeight)
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
