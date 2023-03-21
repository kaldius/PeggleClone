/**
 A `TrackedSetChange` holds the information for each change that occured in its `TrackedSet`, where
 1. `nil` -> `Element` represents an `addition`,
 2. `Element` -> `nil` represents a `removal` and
 3. `Element` -> `Element` represents a `swap`.
 The last case of `nil` -> `nil`, while considered valid, will not add much value.
 */

struct TrackedSetChange<Element>: Equatable where Element: Equatable & Hashable {
    var before: Element?
    var after: Element?

    init(before: Element?, after: Element?) {
        self.before = before
        self.after = after
    }

    var isAddition: Bool {
        before == nil && after != nil
    }

    var isRemoval: Bool {
        before != nil && after == nil
    }

    var isSwap: Bool {
        before != nil && after != nil
    }
}
