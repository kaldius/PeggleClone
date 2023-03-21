/**
 `CirclePhysicsBody` is a concrete implementation of `PhysicsBody` with the shape of a `Circle`.
 */

import CoreGraphics

class CircularPhysicsBody: CircularBody & PhysicsBody {

    var internalShape: Circle

    var previousCenter: CGVector
    var mass: CGFloat
    var restitution: CGFloat
    var acceleration: CGVector
    var isStatic: Bool
    var isPushable: Bool
    var isAcceleratable: Bool

    var center: CGVector {
        internalShape.center
    }

    var radius: CGFloat {
        internalShape.radius
    }

    init(circle: Circle,
         mass: CGFloat = 1,
         restitution: CGFloat = 1,
         acceleration: CGVector = CGVector.zero,
         isStatic: Bool,
         isPushable: Bool = true,
         isAcceleratable: Bool = true) {
        self.previousCenter = circle.center
        self.mass = mass
        self.restitution = restitution
        self.acceleration = acceleration
        self.isStatic = isStatic
        self.internalShape = circle
        self.isPushable = isPushable
        self.isAcceleratable = isAcceleratable
    }

    init(circle: Circle,
         movingFrom previousCenter: CGVector,
         mass: CGFloat = 1,
         restitution: CGFloat = 0.5) {
        self.previousCenter = previousCenter
        self.mass = mass
        self.restitution = restitution
        self.acceleration = CGVector.zero
        self.isStatic = false
        self.internalShape = circle
        self.isPushable = true
        self.isAcceleratable = true
    }

    func moveCenter(by vector: CGVector) {
        if isStatic { return }
        previousCenter = center
        internalShape.center += vector
    }

    func moveCenter(to newCenter: CGVector) {
        if isStatic { return }
        previousCenter = center
        internalShape.center = newCenter
    }

    func moveCenter(to newCenter: CGVector, from previousCenter: CGVector) {
        if isStatic { return }
        self.previousCenter = previousCenter
        internalShape.center = newCenter
    }
}

extension CircularPhysicsBody: CircularCollidableBody {
    var candidateAxes: AxisSet {
        AxisSet()
    }

    func extremePointsAlong(axis: CGVector) -> (min: CGFloat, max: CGFloat) {
        let minPoint = center - radius * axis.unitVector
        let maxPoint = center + radius * axis.unitVector
        let minDist = CGVector.lengthOfProjection(of: minPoint, onto: axis)
        let maxDist = CGVector.lengthOfProjection(of: maxPoint, onto: axis)
        return (minDist, maxDist)
    }

    // MARK: CollidableBody
    func resolveCollision(with collidableBody: any CollidableBody) -> CollisionResolution? {
        collidableBody.resolveCollision(with: self)?.flipped()
    }

    // MARK: CircleCollidableBody
    func resolveCollision(with circleBody: any CircularCollidableBody) -> CollisionResolution? {
        CollisionResolver.getCollisionResolution(between: self, and: circleBody)
    }

    // MARK: RegularPolygonCollidableBody
    func resolveCollision(with polygonBody: any RegularPolygonalCollidableBody) -> CollisionResolution? {
        CollisionResolver.getCollisionResolution(between: self, and: polygonBody)
    }
}
