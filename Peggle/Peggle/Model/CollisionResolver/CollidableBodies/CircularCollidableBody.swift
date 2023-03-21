/**
 A `CircleCollidableBody` is a concrete implementation of a `CollidableBody` for the `Circle` shape.
 */

import CoreGraphics

protocol CircularCollidableBody: CircularBody & CollidableBody {
    var radius: CGFloat { get }
}

extension CircularCollidableBody {
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

    // MARK: ConvexPolygonCollidableBody
    func resolveCollision(with polygonBody: any ConvexPolygonalCollidableBody) -> CollisionResolution? {
        CollisionResolver.getCollisionResolution(between: self, and: polygonBody)
    }
}
