/**
 Heterogenous sets are not allowed, hence this struct is created to hold several `TrackedSet`s,
 each holding a different type of `GameObject`.
 */
import CoreGraphics

struct GameObjectSet: Equatable {

    var allObjects: [any GameObject] {
        return Array(pegSet) + Array(blockSet)
    }

    var hasChanges: Bool {
        hasPegChanges || hasBlockChanges
    }

    init() {
        self.internalPegSet = TrackedSet()
        self.internalBlockSet = TrackedSet()
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        internalPegSet = scaledPegs(scaleFactor: scaleFactor)
        internalBlockSet = scaledBlocks(scaleFactor: scaleFactor)
    }

    private func scaledPegs(scaleFactor: CGFloat) -> TrackedSet<Peg> {
        let unscaledPegs = internalPegSet.asSet
        var newPegs = TrackedSet<Peg>()
        for peg in unscaledPegs {
            var newPeg = peg
            newPeg.scale(byFactor: scaleFactor)
            newPegs.insert(newPeg)
        }
        return newPegs
    }

    private func scaledBlocks(scaleFactor: CGFloat) -> TrackedSet<RectangularBlock> {
        let unscaledBlocks = internalBlockSet.asSet
        var newBlocks = TrackedSet<RectangularBlock>()
        for block in unscaledBlocks {
            var newBlock = block
            newBlock.scale(byFactor: scaleFactor)
            newBlocks.insert(newBlock)
        }
        return newBlocks
    }

    func objectAt(point: CGVector) -> (any GameObject)? {
        if let pegAtPoint = firstPeg(where: { $0.covers(point: point) }) {
            return pegAtPoint
        }
        if let blockAtPoint = firstBlock(where: { $0.covers(point: point) }) {
            return blockAtPoint
        }
        return nil
    }

    mutating func adjust(objectAt location: CGVector, to point: CGVector) -> (any GameObject)? {
        guard var adjustedGameObject = objectAt(point: location) else { return nil }
        adjustedGameObject.adjust(to: point)
        return adjustedGameObject
    }

    mutating func scale(objectAt location: CGVector, to point: CGVector) -> (any GameObject)? {
        guard var adjustedGameObject = objectAt(point: location) else { return nil }
        adjustedGameObject.scale(to: point)
        return adjustedGameObject
    }

    mutating func swap(toRemove member: any GameObject, toAdd newMember: any GameObject) {
        if let newObject = newMember as? Peg, let oldObject = member as? Peg {
            swap(toRemove: oldObject, toAdd: newObject)
        }
        if let newObject = newMember as? RectangularBlock, let oldObject = member as? RectangularBlock {
            swap(toRemove: oldObject, toAdd: newObject)
        }
    }

    mutating func insert(_ gameObject: any GameObject) {
        if let peg = gameObject as? Peg {
            insert(peg: peg)
        }
        if let block = gameObject as? RectangularBlock {
            insert(block: block)
        }
    }

    @discardableResult
    mutating func remove(_ gameObject: any GameObject) -> (any GameObject)? {
        if let peg = gameObject as? Peg {
            return remove(peg: peg)
        }
        if let block = gameObject as? RectangularBlock {
            return remove(block: block)
        }
        return nil
    }

    mutating func removeAll() {
        removeAllPegs()
        removeAllBlocks()
    }

    // MARK: internalPegSet
    private var internalPegSet: TrackedSet<Peg>

    var pegSet: Set<Peg> {
        return internalPegSet.asSet
    }

    var hasPegs: Bool {
        return !internalPegSet.isEmpty
    }

    var hasPegChanges: Bool {
        return !internalPegSet.isCacheEmpty
    }

    mutating func insert(peg: Peg) {
        internalPegSet.insert(peg)
    }

    @discardableResult
    mutating func remove(peg: Peg) -> Peg? {
        return internalPegSet.remove(peg)
    }

    func contains(peg: Peg) -> Bool {
        return internalPegSet.contains(peg)
    }

    mutating func swap(toRemove member: Peg, toAdd newMember: Peg) {
        internalPegSet.swap(toRemove: member, toAdd: newMember)
    }

    mutating func removeAllPegs() {
        internalPegSet.removeAll()
    }

    func firstPeg(where closure: ((Peg) -> Bool)) -> Peg? {
        return internalPegSet.first(where: closure)
    }

    func containsPeg(where closure: ((Peg) -> Bool)) -> Bool {
        return internalPegSet.contains(where: closure)
    }

    mutating func retrieveOldestPegChange() -> TrackedSetChange<Peg>? {
        return internalPegSet.retrieveOldestChange()
    }

    mutating func clearPegCache() {
        internalPegSet.clearCache()
    }

    // MARK: internalBlockSet
    private var internalBlockSet: TrackedSet<RectangularBlock>

    var blockSet: Set<RectangularBlock> {
        return internalBlockSet.asSet
    }

    var hasBlocks: Bool {
        return !internalBlockSet.isEmpty
    }

    var hasBlockChanges: Bool {
        return !internalBlockSet.isCacheEmpty
    }

    mutating func insert(block: RectangularBlock) {
        internalBlockSet.insert(block)
    }

    @discardableResult
    mutating func remove(block: RectangularBlock) -> RectangularBlock? {
        return internalBlockSet.remove(block)
    }

    func contains(block: RectangularBlock) -> Bool {
        return internalBlockSet.contains(block)
    }

    mutating func swap(toRemove member: RectangularBlock, toAdd newMember: RectangularBlock) {
        internalBlockSet.swap(toRemove: member, toAdd: newMember)
    }

    mutating func removeAllBlocks() {
        internalBlockSet.removeAll()
    }

    func firstBlock(where closure: ((RectangularBlock) -> Bool)) -> RectangularBlock? {
        return internalBlockSet.first(where: closure)
    }

    func containsBlock(where closure: ((RectangularBlock) -> Bool)) -> Bool {
        return internalBlockSet.contains(where: closure)
    }

    mutating func retrieveOldestBlockChange() -> TrackedSetChange<RectangularBlock>? {
        return internalBlockSet.retrieveOldestChange()
    }

    mutating func clearBlockCache() {
        internalBlockSet.clearCache()
    }

}
