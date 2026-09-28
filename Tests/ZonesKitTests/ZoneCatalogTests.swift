import Testing
import ZonesKit

@Suite struct ZoneCatalogTests {
    @Test func cityNames() {
        #expect(ZoneCatalog.cityName(for: "America/Los_Angeles") == "Los Angeles")
        #expect(ZoneCatalog.cityName(for: "America/Argentina/Buenos_Aires") == "Buenos Aires")
    }

    @Test func cityPrefixRanksFirst() {
        #expect(ZoneCatalog.search("mexico").first?.identifier == "America/Mexico_City")
        #expect(ZoneCatalog.search("new york").first?.identifier == "America/New_York")
    }

    @Test func matchesIgnoreAccentsAndCase() {
        #expect(ZoneCatalog.search("SAO PAULO").map(\.identifier).contains("America/Sao_Paulo"))
    }

    @Test func matchesGenericName() {
        let candidates = [
            ZoneCandidate(
                identifier: "America/Los_Angeles", genericName: "Pacific Time", abbreviation: "PDT"),
            ZoneCandidate(
                identifier: "Europe/Paris", genericName: "Central European Time",
                abbreviation: "CEST"),
        ]
        #expect(
            ZoneCatalog.search("pacific", in: candidates).map(\.identifier) == [
                "America/Los_Angeles"
            ])
    }

    @Test func emptyQueryFindsNothing() {
        #expect(ZoneCatalog.search("  ").isEmpty)
    }
}
