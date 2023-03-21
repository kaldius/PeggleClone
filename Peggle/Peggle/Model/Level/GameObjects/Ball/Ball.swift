/**
 `Ball` represents a ball in the `Level`.
 */

import CoreGraphics

struct Ball {

    static let DEFAULTBALLRADIUS: CGFloat = 20

    var extraLife: Int

    var internalShape: Circle
    var radius: CGFloat {
        internalShape.radius
    }
    let type: BallType

    var leftMostPoint: CGPoint {
        CGPoint(x: center.dx - radius, y: center.dy)
    }
    var rightMostPoint: CGPoint {
        CGPoint(x: center.dx + radius, y: center.dy)
    }
    var topMostPoint: CGPoint {
        CGPoint(x: center.dx, y: center.dy - radius)
    }
    var bottomMostPoint: CGPoint {
        CGPoint(x: center.dx, y: center.dy + radius)
    }

    init(center: CGPoint, radius: CGFloat = DEFAULTBALLRADIUS, type: BallType = .regular) {
        var correctedRadius = radius
        if radius < 0 {
            correctedRadius = Ball.DEFAULTBALLRADIUS
        }
        self.internalShape = Circle(center: center.asCGVector, radius: correctedRadius)
        self.type = type
        self.extraLife = 0
    }

    func isInside(area: Area) -> Bool {
        return area.encloses(leftMostPoint)
            || area.encloses(rightMostPoint)
            || area.encloses(topMostPoint)
            || area.encloses(bottomMostPoint)
    }
}

// MARK: +GameObject
extension Ball: GameObject {
    func covers(point: CGVector) -> Bool {
        let distanceToPoint = CGVector.euclideanDistance(between: center, and: point)
        return distanceToPoint < radius
    }

    var center: CGVector {
        get {
            internalShape.center
        }
        set(newCenter) {
            internalShape.center = newCenter
        }
    }

    mutating func translate(by translation: CGVector) {
        internalShape.center += translation
    }

    mutating func translate(to newCenter: CGVector) {
        internalShape.center = newCenter
    }

    mutating func rotate(byRadians: CGFloat) {
        return
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        internalShape.radius *= scaleFactor
    }

    mutating func adjust(to point: CGVector) {
        return
    }

    mutating func scale(to point: CGVector) {
        let scaleFactor = (point - center).length / radius
        scale(byFactor: scaleFactor)
    }

}

// MARK: +CircularCollidableBody
extension Ball: CircularCollidableBody {}
