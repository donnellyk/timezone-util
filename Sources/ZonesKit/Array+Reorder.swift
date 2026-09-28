extension Array where Element: Identifiable {
    /// The element with `id` moved to where `target` sits: after it when moving
    /// down, before it when moving up. Unknown IDs leave the order unchanged.
    public func moving(_ id: Element.ID, to target: Element.ID) -> [Element] {
        guard
            let from = firstIndex(where: { $0.id == id }),
            let to = firstIndex(where: { $0.id == target })
        else { return self }
        var result = self
        result.insert(result.remove(at: from), at: to)
        return result
    }
}
