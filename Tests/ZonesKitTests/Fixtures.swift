import Foundation
import ZonesKit

func zone(_ identifier: String) -> TimeZone {
    TimeZone(identifier: identifier)!
}

/// A wall-clock moment in `identifier`'s time zone.
func date(
    _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0,
    in identifier: String
) -> Date {
    Calendar.gregorian(in: zone(identifier))
        .date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

let nineToFive = DailyWindow.standardWorkday
