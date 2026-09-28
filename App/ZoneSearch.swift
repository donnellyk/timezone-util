import SwiftUI
import ZonesKit

/// A search field over the system's time zones; each match adds a zone on click.
/// Return adds the top match.
struct ZoneSearch: View {
    let use24Hour: Bool
    let onAdd: (ZoneCandidate) -> Void

    @State private var query = ""

    private var matches: [ZoneCandidate] { ZoneCatalog.search(query) }

    var body: some View {
        TextField("Add", text: $query, prompt: Text("Search cities or regions"))
            .onSubmit { matches.first.map(add) }
        ForEach(matches) { candidate in
            Button {
                add(candidate)
            } label: {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(candidate.city)
                        Text(
                            [candidate.region, candidate.genericName].filter { !$0.isEmpty }.joined(
                                separator: " · ")
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(ClockText.time(.now, in: candidate.timeZone, use24Hour: use24Hour))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.tint)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private func add(_ candidate: ZoneCandidate) {
        onAdd(candidate)
        query = ""
    }
}
