/**
 The `CollisionResolver` class has methods to resolve collisions between
 two `CollidableBody`s.
 */

import CoreGraphics

class CollisionResolver {

    static func getCollisionResolution(between body1: any CollidableBody,
                                       and body2: any CollidableBody) -> CollisionResolution? {
        body1.resolveCollision(with: body2)
    }

    /// Returns a vector along which both objects should be pushed, and nil if there is no collision.
    static func getCollisionResolution(between circle1: any CircularCollidableBody,
                                       and circle2: any CircularCollidableBody) -> CollisionResolution? {
        let distanceBetweenCenters = CGVector.euclideanDistance(between: circle1.center, and: circle2.center)
        let minimumDistance = circle1.radius + circle2.radius
        if distanceBetweenCenters < minimumDistance {
            // unit vector from circle1.center to circle2.center
            let normalizedCollisionVector = (circle2.center - circle1.center).unitVector
            // how far apart to push the two circles
            let pushDistance = (minimumDistance - distanceBetweenCenters)
            let pushVector = normalizedCollisionVector * pushDistance
            let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                          deltaSecondBody: pushVector)
            return collisionResolution
        }
        return nil
    }

    static func getCollisionResolution(between polygon1: any RegularPolygonalCollidableBody,
                                       and polygon2: any RegularPolygonalCollidableBody) -> CollisionResolution? {
        guard var pushVector = findPushVector(body1: polygon1, body2: polygon2) else {
            return nil
        }
        pushVector = adjustNormalDirection(body1: polygon1, body2: polygon2, normal: pushVector)
        let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                      deltaSecondBody: pushVector)
        return collisionResolution
    }

    static func getCollisionResolution(between polygon1: any ConvexPolygonalCollidableBody,
                                       and polygon2: any ConvexPolygonalCollidableBody) -> CollisionResolution? {
        guard var pushVector = findPushVector(body1: polygon1, body2: polygon2) else {
            return nil
        }
        pushVector = adjustNormalDirection(body1: polygon1, body2: polygon2, normal: pushVector)
        let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                      deltaSecondBody: pushVector)
        return collisionResolution
    }

    static func getCollisionResolution(between circle: any CircularCollidableBody,
                                       and polygon: any RegularPolygonalCollidableBody) -> CollisionResolution? {
        guard var pushVector = findPushVector(body1: circle, body2: polygon) else {
            return nil
        }
        pushVector = adjustNormalDirection(body1: circle, body2: polygon, normal: pushVector)
        let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                      deltaSecondBody: pushVector)
        return collisionResolution
    }

    static func getCollisionResolution(between circle: any CircularCollidableBody,
                                       and polygon: any ConvexPolygonalCollidableBody) -> CollisionResolution? {
        guard var pushVector = findPushVector(body1: circle, body2: polygon) else {
            return nil
        }
        pushVector = adjustNormalDirection(body1: circle, body2: polygon, normal: pushVector)
        let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                      deltaSecondBody: pushVector)
        return collisionResolution
    }

    static func getCollisionResolution(between polygon1: any RegularPolygonalCollidableBody,
                                       and polygon2: any ConvexPolygonalCollidableBody) -> CollisionResolution? {
        guard var pushVector = findPushVector(body1: polygon1, body2: polygon2) else {
            return nil
        }
        pushVector = adjustNormalDirection(body1: polygon1, body2: polygon2, normal: pushVector)
        let collisionResolution = CollisionResolution(deltaFirstBody: -pushVector,
                                                      deltaSecondBody: pushVector)
        return collisionResolution
    }

    /// Combines the possible axes from both polygons
    private static func getAllPossibleAxes(body1: any CollidableBody, body2: any CollidableBody) -> AxisSet {
        var axes = AxisSet()
        axes.insert(body1.candidateAxes)
        axes.insert(body2.candidateAxes)
        return axes
    }

    /// Loops through all provided `axes` to find a valid separating axis, then
    /// returns the shortest collision resolution vector.
    private static func findPushVector(body1: any CollidableBody, body2: any CollidableBody) -> CGVector? {
        let allPossibleAxes = getAllPossibleAxes(body1: body1, body2: body2)
        // keeping track of the collision vector and minimum depth of collision
        var pushVector = CGVector.zero
        var minDepth = CGFloat.infinity
        for axis in allPossibleAxes.asSet {
            let collision = hasCollisionAlongAxis(body1: body1, body2: body2, axis: axis)
            let collisionDepth = calculateCollisionDepth(body1: body1, body2: body2, axis: axis)
            if collision && collisionDepth < minDepth {
                pushVector = axis
                minDepth = collisionDepth
            }
            // if there exists an axis with no collision,
            // there is no collision between the bodies and
            // there will also be no collision vector
            if !collision { return nil }
        }
        return pushVector.unitVector * minDepth
    }

    /// Corrects the normal vector such that it is pointing from `body1` to `body2`.
    private static func adjustNormalDirection(body1: any CollidableBody,
                                              body2: any CollidableBody,
                                              normal: CGVector) -> CGVector {
        let vectorFromBody1ToBody2 = body2.center - body1.center
        if vectorFromBody1ToBody2.dot(normal) < 0 {
            return -normal
        }
        return normal
    }

    private static func hasCollisionAlongAxis(body1: any CollidableBody,
                                              body2: any CollidableBody,
                                              axis: CGVector) -> Bool {
        let body1ExtremePoints = body1.extremePointsAlong(axis: axis)
        let body2ExtremePoints = body2.extremePointsAlong(axis: axis)
        return body1ExtremePoints.min < body2ExtremePoints.max
        && body2ExtremePoints.min < body1ExtremePoints.max
    }

    private static func calculateCollisionDepth(body1: any CollidableBody,
                                                body2: any CollidableBody,
                                                axis: CGVector) -> CGFloat {
        let body1ExtremePoints = body1.extremePointsAlong(axis: axis)
        let body2ExtremePoints = body2.extremePointsAlong(axis: axis)
        return min(abs(body1ExtremePoints.max - body2ExtremePoints.min),
                   abs(body2ExtremePoints.max - body1ExtremePoints.min))
    }
}
