import CoreTransferable
import UniformTypeIdentifiers
import ZonesKit

/// A zone row being dragged in Settings. A private type, so text fields don't
/// accept the drop as text.
struct ZoneDrag: Codable, Transferable {
    let id: Zone.ID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .zoneDrag)
    }
}

extension UTType {
    static let zoneDrag = UTType(exportedAs: "me.kvnd.Zones.zone")
}
