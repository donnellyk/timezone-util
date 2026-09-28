import Foundation

/// A wall-clock time with minute precision, independent of any date or time zone.
public struct TimeOfDay: Codable, Hashable, Comparable, Sendable {
    public let minutes: Int

    public init(minutes: Int) {
        self.minutes = ((minutes % 1440) + 1440) % 1440
    }

    public init(hour: Int, minute: Int = 0) {
        self.init(minutes: hour * 60 + minute)
    }

    public var hour: Int { minutes / 60 }
    public var minute: Int { minutes % 60 }

    public static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool { lhs.minutes < rhs.minutes }

    public static func steps(every step: Int) -> [TimeOfDay] {
        stride(from: 0, to: 1440, by: step).map(TimeOfDay.init(minutes:))
    }
}
