import Foundation

/// A time zone the menu shows, under the name the user gave it.
public struct Zone: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var timeZoneID: String
    public var workday: DailyWindow

    public init(
        id: UUID = UUID(), name: String, timeZoneID: String,
        workday: DailyWindow = .standardWorkday
    ) {
        self.id = id
        self.name = name
        self.timeZoneID = timeZoneID
        self.workday = workday
    }

    public var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .gmt }
    public var cityName: String { ZoneCatalog.cityName(for: timeZoneID) }

    /// The user's name, or the city when the name is blank.
    public var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? cityName : trimmed
    }

    public static let defaults: [Zone] = [
        Zone(name: "New York", timeZoneID: "America/New_York"),
        Zone(name: "West Coast", timeZoneID: "America/Los_Angeles"),
        Zone(name: "Mexico City", timeZoneID: "America/Mexico_City"),
    ]
}
