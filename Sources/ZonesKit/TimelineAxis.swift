import Foundation

/// A horizontal span of time that intervals and moments map onto as fractions from
/// 0 (the start) to 1 (the end).
public struct TimelineAxis: Equatable, Sendable {
    public let span: DateInterval
    public let timeZone: TimeZone

    public init(span: DateInterval, timeZone: TimeZone) {
        self.span = span
        self.timeZone = timeZone
    }

    /// The calendar day around `date` in `timeZone`, midnight to midnight.
    public static func day(containing date: Date, in timeZone: TimeZone) -> TimelineAxis {
        TimelineAxis(
            span: Calendar.gregorian(in: timeZone).dateInterval(of: .day, for: date)
                ?? DateInterval(start: date, duration: 86_400),
            timeZone: timeZone)
    }

    public func fraction(of date: Date) -> Double {
        min(max(date.timeIntervalSince(span.start) / span.duration, 0), 1)
    }

    /// `intervals` clipped to the axis, as fraction ranges. Intervals outside it drop out.
    public func segments(for intervals: [DateInterval]) -> [ClosedRange<Double>] {
        intervals
            .compactMap { $0.intersection(with: span) }
            .filter { $0.duration > 0 }
            .map { fraction(of: $0.start)...fraction(of: $0.end) }
    }

    /// The parts of `intervals` on the axis that come before `date`.
    public func segments(for intervals: [DateInterval], before date: Date) -> [ClosedRange<Double>]
    {
        let past = DateInterval(start: span.start, end: max(span.start, date))
        return segments(for: intervals.compactMap { $0.intersection(with: past) })
    }

    /// Marks at every `step`-th wall-clock hour in `timeZone` that falls on the axis,
    /// in time order. A zone offset from the axis gets its marks shifted to match.
    public func ticks(everyHours step: Int, in timeZone: TimeZone) -> [TimelineTick] {
        let calendar = Calendar.gregorian(in: timeZone)
        let firstDay = calendar.startOfDay(for: span.start)
        return (0...2)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: firstDay) }
            .flatMap { day in
                stride(from: 0, to: 24, by: step).compactMap { hour in
                    calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)
                        .map { (hour, $0) }
                }
            }
            .filter { span.start <= $0.1 && $0.1 < span.end }
            .map { TimelineTick(hour: $0.0, fraction: fraction(of: $0.1)) }
    }
}

public struct TimelineTick: Hashable, Sendable {
    public let hour: Int
    public let fraction: Double
}
