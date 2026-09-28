import Foundation

extension Calendar {
    /// A Gregorian calendar that reads and builds wall-clock times in `timeZone`.
    public static func gregorian(in timeZone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
