/**
 `CollidableBody` specifies a set of attributes and methods to be used by the `CollisionDetector`.
 */

import CoreGraphics

protocol CollidableBody: Body {
    var center: CGVector { get }
    var candidateAxes: AxisSet { get }

    func extremePointsAlong(axis: CGVector) -> (min: CGFloat, max: CGFloat)
    func resolveCollision(with collidableBody: any CollidableBody) -> CollisionResolution?
    func resolveCollision(with circleBody: any CircularCollidableBody) -> CollisionResolution?
    func resolveCollision(with polygonBody: any RegularPolygonalCollidableBody) -> CollisionResolution?
    func resolveCollision(with polygonBody: any ConvexPolygonalCollidableBody) -> CollisionResolution?
}
