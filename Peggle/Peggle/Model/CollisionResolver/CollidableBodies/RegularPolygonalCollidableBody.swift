/**
 A `RegularPolygonalCollidableBody` is an implementation of a `CollidableBody` for the `RegularPolygon` shape.
 */

import CoreGraphics

protocol RegularPolygonalCollidableBody: RegularPolygonalBody & CollidableBody {}

extension RegularPolygonalCollidableBody {
    /// All possible axes to search for a separation.
    var candidateAxes: AxisSet {
        var axes = AxisSet()
        for cornerNumber in 0..<internalShape.vertices.count - 1 {
            let firstCorner = internalShape.vertices[cornerNumber]
            let secondCorner = internalShape.vertices[cornerNumber + 1]
            let sideVector = secondCorner - firstCorner
            let axis = sideVector.perpendicularUnitVector
            axes.insert(axis)
        }
        return axes
    }

    /// Loops throught all corners of the polygon, projects them onto the given `axis`
    /// and finds the two extreme distances along that axis.
    func extremePointsAlong(axis: CGVector) -> (min: CGFloat, max: CGFloat) {
        var minDist = CGFloat.infinity
        var maxDist = -CGFloat.infinity
        for corner in internalShape.vertices {
            let lengthOfProjection = CGVector.lengthOfProjection(of: corner, onto: axis)
            minDist = min(minDist, lengthOfProjection)
            maxDist = max(maxDist, lengthOfProjection)
        }
        return (minDist, maxDist)
    }

    // MARK: CollidableBody
    func resolveCollision(with collidableBody: any CollidableBody) -> CollisionResolution? {
        collidableBody.resolveCollision(with: self)?.flipped()
    }

    // MARK: CircleCollidableBody
    func resolveCollision(with circleBody: any CircularCollidableBody) -> CollisionResolution? {
        CollisionResolver.getCollisionResolution(between: circleBody, and: self)?.flipped()
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
