import Foundation

public enum WorkdayStatus: Equatable, Sendable {
    case working
    /// Today's workday has not started yet.
    case startsLater(in: TimeInterval)
    /// Today's workday is over.
    case finished
    /// Today is not a workday.
    case dayOff
}

extension DailyWindow {
    /// Where `date` falls relative to this window, judged by the calendar day in
    /// `timeZone`.
    public func status(at date: Date, in timeZone: TimeZone) -> WorkdayStatus {
        let calendar = Calendar.gregorian(in: timeZone)
        guard let today = calendar.dateInterval(of: .day, for: date) else { return .dayOff }
        let nearby = intervals(
            overlapping: DateInterval(
                start: today.start.addingTimeInterval(-86_400), end: today.end),
            in: timeZone)

        if nearby.contains(where: { $0.start <= date && date < $0.end }) {
            return .working
        }
        if let next = nearby.first(where: { $0.start > date && $0.start < today.end }) {
            return .startsLater(in: next.start.timeIntervalSince(date))
        }
        return weekdays.contains(calendar.component(.weekday, from: date)) ? .finished : .dayOff
    }
}
