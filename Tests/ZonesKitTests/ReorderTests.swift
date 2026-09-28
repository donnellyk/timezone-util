import Testing
import ZonesKit

@Suite struct ReorderTests {
    struct Item: Identifiable, Equatable {
        let id: String
    }

    let items = ["a", "b", "c"].map(Item.init)

    @Test func movingDownPlacesAfterTheTarget() {
        #expect(items.moving("a", to: "c").map(\.id) == ["b", "c", "a"])
    }

    @Test func movingUpPlacesBeforeTheTarget() {
        #expect(items.moving("c", to: "a").map(\.id) == ["c", "a", "b"])
    }

    @Test func unknownOrSameIDsLeaveTheOrder() {
        #expect(items.moving("x", to: "a") == items)
        #expect(items.moving("a", to: "x") == items)
        #expect(items.moving("b", to: "b") == items)
    }
}
