/**
 `AxisSet` is a `Set` data structure that holds unit vectors representing axes.
 Vectors pointing in exact opposite directions are considered to represent the same axis.
 */
import CoreGraphics

struct AxisSet {
    private var internalSet: Set<CGVector>
    var asSet: Set<CGVector> {
        internalSet
    }

    init() {
        internalSet = Set()
    }

    mutating func insert(_ newMember: CGVector) {
        let memberToInsert = newMember.unitVector
        guard !internalSet.contains(memberToInsert)
           && !internalSet.contains(-memberToInsert) else {
            return
        }
        internalSet.insert(memberToInsert)
    }

    mutating func insert(_ otherAxisSet: AxisSet) {
        for item in otherAxisSet.asSet {
            insert(item)
        }
    }

    @discardableResult
    mutating func remove(_ member: CGVector) -> CGVector? {
        internalSet.remove(member)
    }
}
