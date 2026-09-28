import Foundation

/// Short text for clocks, durations, and offsets. The 12-hour forms are fixed
/// English ("2:41 PM") so they stay compact in the menu.
public enum ClockText {
    public static func time(_ date: Date, in timeZone: TimeZone, use24Hour: Bool) -> String {
        let parts = Calendar.gregorian(in: timeZone).dateComponents([.hour, .minute], from: date)
        return time(
            TimeOfDay(hour: parts.hour ?? 0, minute: parts.minute ?? 0), use24Hour: use24Hour)
    }

    public static func time(_ time: TimeOfDay, use24Hour: Bool) -> String {
        use24Hour
            ? String(format: "%02d:%02d", time.hour, time.minute)
            : String(
                format: "%d:%02d %@", time.hour % 12 == 0 ? 12 : time.hour % 12, time.minute,
                time.hour < 12 ? "AM" : "PM")
    }

    public static func range(_ window: DailyWindow, use24Hour: Bool) -> String {
        "\(time(window.start, use24Hour: use24Hour)) – \(time(window.end, use24Hour: use24Hour))"
    }

    /// Whole minutes, rounded up, as "3h 12m", "45m", or "2h".
    public static func duration(_ interval: TimeInterval) -> String {
        let (hours, minutes) = max(0, Int((interval / 60).rounded(.up))).quotientAndRemainder(
            dividingBy: 60)
        return switch (hours, minutes) {
        case (0, _): "\(minutes)m"
        case (_, 0): "\(hours)h"
        default: "\(hours)h \(minutes)m"
        }
    }

    /// How far `timeZone` is ahead of (+) or behind (−) `reference` at `date`.
    public static func offset(
        of timeZone: TimeZone, from reference: TimeZone, at date: Date
    ) -> String {
        let seconds = timeZone.secondsFromGMT(for: date) - reference.secondsFromGMT(for: date)
        return seconds == 0
            ? "Same time"
            : (seconds > 0 ? "+" : "−") + duration(TimeInterval(abs(seconds)))
    }

    /// "Tomorrow" or "Yesterday" when `date` falls on a different calendar day in
    /// `timeZone` than in `reference`.
    public static func dayRelation(
        of date: Date, in timeZone: TimeZone, relativeTo reference: TimeZone
    )
        -> String?
    {
        switch dayNumber(of: date, in: timeZone) - dayNumber(of: date, in: reference) {
        case 1...: "Tomorrow"
        case ..<0: "Yesterday"
        default: nil
        }
    }

    public static func hourLabel(_ hour: Int, use24Hour: Bool) -> String {
        use24Hour
            ? String(format: "%02d", hour)
            : "\(hour % 12 == 0 ? 12 : hour % 12)\(hour % 24 < 12 ? "a" : "p")"
    }

    /// Nothing while working; the bar already shows it.
    public static func status(_ status: WorkdayStatus) -> String? {
        switch status {
        case .working: nil
        case .startsLater(let interval): "Starts in \(duration(interval))"
        case .finished: "Done for the day"
        case .dayOff: "Day off"
        }
    }

    private static func dayNumber(of date: Date, in timeZone: TimeZone) -> Int {
        let parts = Calendar.gregorian(in: timeZone).dateComponents(
            [.year, .month, .day], from: date)
        let utc = Calendar.gregorian(in: .gmt)
        return utc.date(from: parts).map { Int($0.timeIntervalSinceReferenceDate / 86_400) } ?? 0
    }
}
