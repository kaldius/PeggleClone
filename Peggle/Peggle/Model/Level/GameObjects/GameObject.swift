import CoreGraphics

protocol GameObject: CollidableBody & Hashable & Equatable {
    var center: CGVector { get }

    func covers(point: CGVector) -> Bool
    mutating func translate(by translation: CGVector)
    mutating func translate(to newCenter: CGVector)
    mutating func rotate(byRadians: CGFloat)
    mutating func scale(byFactor scaleFactor: CGFloat)
    mutating func adjust(to point: CGVector)
    mutating func scale(to point: CGVector)
}

extension GameObject {
    func isEqualTo(_ otherGameObject: any GameObject) -> Bool {
        if let thisObject = self as? Peg, let thatObject = otherGameObject as? Peg {
            return thisObject == thatObject
        } else if let thisObject = self as? Ball, let thatObject = otherGameObject as? Ball {
            return thisObject == thatObject
        } else if let thisObject = self as? RectangularBlock, let thatObject = otherGameObject as? RectangularBlock {
            return thisObject == thatObject
        }
        return false
    }
}
