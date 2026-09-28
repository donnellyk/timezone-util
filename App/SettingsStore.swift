import Foundation
import Observation
import ZonesKit

/// User settings, persisted in `UserDefaults`. Zones are stored as JSON.
@MainActor
@Observable
final class SettingsStore {
    private let defaults: UserDefaults

    var zones: [Zone] { didSet { store(zones, forKey: "zones") } }
    var use24Hour: Bool { didSet { defaults.set(use24Hour, forKey: "use24Hour") } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        zones = Self.load([Zone].self, forKey: "zones", from: defaults) ?? Zone.defaults
        use24Hour = defaults.bool(forKey: "use24Hour")
    }

    func add(_ candidate: ZoneCandidate) {
        zones.append(Zone(name: candidate.city, timeZoneID: candidate.identifier))
    }

    func move(_ id: Zone.ID, to target: Zone.ID) {
        zones = zones.moving(id, to: target)
    }

    func remove(_ id: Zone.ID) {
        zones.removeAll { $0.id == id }
    }

    private func store(_ value: some Encodable, forKey key: String) {
        defaults.set(try? JSONEncoder().encode(value), forKey: key)
    }

    private static func load<T: Decodable>(
        _ type: T.Type, forKey key: String, from defaults: UserDefaults
    )
        -> T?
    {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }
}
