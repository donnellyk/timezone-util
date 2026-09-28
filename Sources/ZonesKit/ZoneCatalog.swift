import Foundation

public struct ZoneCandidate: Hashable, Identifiable, Sendable {
    public let identifier: String
    public let genericName: String
    public let abbreviation: String

    public init(identifier: String, genericName: String, abbreviation: String) {
        self.identifier = identifier
        self.genericName = genericName
        self.abbreviation = abbreviation
    }

    public var id: String { identifier }
    public var city: String { ZoneCatalog.cityName(for: identifier) }
    public var timeZone: TimeZone { TimeZone(identifier: identifier) ?? .gmt }

    /// "America", or "America / Argentina" for nested identifiers.
    public var region: String {
        identifier.split(separator: "/").dropLast()
            .map { $0.replacingOccurrences(of: "_", with: " ") }
            .joined(separator: " / ")
    }
}

/// The system's known time zones, searchable by city, region, or zone name.
public enum ZoneCatalog {
    public static let all: [ZoneCandidate] = TimeZone.knownTimeZoneIdentifiers
        .filter { $0.contains("/") }
        .compactMap { identifier in
            TimeZone(identifier: identifier).map { zone in
                ZoneCandidate(
                    identifier: identifier,
                    genericName: zone.localizedName(for: .generic, locale: .current) ?? "",
                    abbreviation: zone.abbreviation() ?? "")
            }
        }

    public static func cityName(for identifier: String) -> String {
        (identifier.split(separator: "/").last.map(String.init) ?? identifier)
            .replacingOccurrences(of: "_", with: " ")
    }

    /// Matches ranked city-prefix first, then city substring, then any other field.
    public static func search(
        _ query: String, in candidates: [ZoneCandidate] = all, limit: Int = 8
    )
        -> [ZoneCandidate]
    {
        let needle = normalized(query.trimmingCharacters(in: .whitespaces))
        guard !needle.isEmpty else { return [] }
        return
            candidates
            .compactMap { candidate in rank(candidate, needle).map { (candidate, $0) } }
            .sorted { ($0.1, $0.0.city) < ($1.1, $1.0.city) }
            .prefix(limit)
            .map(\.0)
    }

    private static func rank(_ candidate: ZoneCandidate, _ needle: String) -> Int? {
        let city = normalized(candidate.city)
        let others = [
            candidate.genericName, candidate.region, candidate.identifier, candidate.abbreviation,
        ]
        .map(normalized)
        return city.hasPrefix(needle)
            ? 0
            : city.contains(needle) ? 1 : others.contains { $0.contains(needle) } ? 2 : nil
    }

    private static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .replacingOccurrences(of: "_", with: " ")
    }
}
