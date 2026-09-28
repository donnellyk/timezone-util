import Foundation

/// A span of wall-clock time that repeats on chosen weekdays, such as a 9–5 workday.
/// An end at or before the start runs past midnight into the next day.
public struct DailyWindow: Codable, Hashable, Sendable {
    public var start: TimeOfDay
    public var end: TimeOfDay
    /// `Calendar` weekday numbers; 1 is Sunday.
    public var weekdays: Set<Int>

    public static let everyDay: Set<Int> = Set(1...7)
    public static let mondayToFriday: Set<Int> = Set(2...6)
    public static let standardWorkday = DailyWindow(
        start: TimeOfDay(hour: 9), end: TimeOfDay(hour: 17), weekdays: mondayToFriday)

    public init(start: TimeOfDay, end: TimeOfDay, weekdays: Set<Int>) {
        self.start = start
        self.end = end
        self.weekdays = weekdays
    }

    public var crossesMidnight: Bool { end <= start }

    /// Every occurrence in `timeZone` that overlaps `range`, in order. Occurrences
    /// start on one of `weekdays` in that zone's calendar.
    public func intervals(overlapping range: DateInterval, in timeZone: TimeZone) -> [DateInterval]
    {
        let calendar = Calendar.gregorian(in: timeZone)
        let firstDay = calendar.startOfDay(for: range.start)
        let dayCount = calendar.dateComponents([.day], from: firstDay, to: range.end).day ?? 0
        return (-1...dayCount)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: firstDay) }
            .filter { weekdays.contains(calendar.component(.weekday, from: $0)) }
            .compactMap { occurrence(on: $0, calendar: calendar) }
            .filter { $0.end > range.start && $0.start < range.end }
    }

    private func occurrence(on day: Date, calendar: Calendar) -> DateInterval? {
        guard
            let startDate = calendar.date(
                bySettingHour: start.hour, minute: start.minute, second: 0, of: day),
            let endDay = calendar.date(byAdding: .day, value: crossesMidnight ? 1 : 0, to: day),
            let endDate = calendar.date(
                bySettingHour: end.hour, minute: end.minute, second: 0, of: endDay)
        else { return nil }
        return DateInterval(start: startDate, end: max(startDate, endDate))
    }
}
