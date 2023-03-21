/**
 A `TrackedSet` behaves like the regular `Set`, with the exception that it contains
 a queue of `TrackedSetChanges` which represent the changes made to the `TrackedSet`
 with order maintained.
 */

struct TrackedSet<Element>: Equatable where Element: Equatable & Hashable {
    private var internalSet: Set<Element>
    private var trackedChanges: Queue<TrackedSetChange<Element>>
    var asSet: Set<Element> {
        internalSet
    }

    init() {
        self.internalSet = Set()
        self.trackedChanges = Queue()
    }

    init(_ set: Set<Element>) {
        self.init()
        for item in set {
            self.insert(item)
        }
    }

    mutating func insert(_ newMember: Element) {
        internalSet.insert(newMember)
        let trackedSetChange = TrackedSetChange(before: nil, after: newMember)
        trackedChanges.enqueue(trackedSetChange)
    }

    @discardableResult
    mutating func remove(_ member: Element) -> Element? {
        let removedMember = internalSet.remove(member)
        if let changedMember = removedMember {
            let trackedSetChange = TrackedSetChange(before: changedMember, after: nil)
            trackedChanges.enqueue(trackedSetChange)
        }
        return removedMember
    }

    @discardableResult
    mutating func swap(toRemove member: Element, toAdd newMember: Element) -> Element? {
        let removedMember = internalSet.remove(member)
        internalSet.insert(newMember)
        let trackedSetChange = TrackedSetChange(before: removedMember, after: newMember)
        trackedChanges.enqueue(trackedSetChange)
        return removedMember
    }

    func first(where closure: (Element) -> Bool) -> Element? {
        return internalSet.first(where: closure)
    }

    func contains(_ member: Element) -> Bool {
        return internalSet.contains(member)
    }

    func contains(where closure: (Element) -> Bool) -> Bool {
        return internalSet.contains(where: closure)
    }

    mutating func removeAll() {
        for member in internalSet {
            let trackedSetChange = TrackedSetChange(before: member, after: nil)
            trackedChanges.enqueue(trackedSetChange)
        }
        internalSet.removeAll()
    }

    mutating func removeAll(where closure: (Element) -> Bool) {
        for item in internalSet where closure(item) {
            remove(item)
        }
    }

    mutating func retrieveOldestChange() -> TrackedSetChange<Element>? {
        return trackedChanges.dequeue()
    }

    mutating func clearCache() {
        trackedChanges.removeAll()
    }

    var isEmpty: Bool {
        internalSet.isEmpty
    }

    var isCacheEmpty: Bool {
        trackedChanges.isEmpty
    }
}
