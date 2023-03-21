/**
 Extends `CGPoint` to be `Hashable` so that `Peg` can conform to `Hashable`.
 */

import CoreGraphics

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
