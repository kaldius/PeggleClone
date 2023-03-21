/**
 `PolygonalPhysicsBody` is a concrete implementation of `PhysicsBody` with the shape of a `RegularPolygon`.
 */

import CoreGraphics

class RegularPolygonalPhysicsBody: RegularPolygonalBody & PhysicsBody {

    var internalShape: RegularPolygon

    var center: CGVector {
        internalShape.center
    }

    var vertices: [CGVector] {
        internalShape.vertices
    }

    var previousCenter: CGVector
    var mass: CGFloat
    var restitution: CGFloat
    var acceleration: CGVector
    var isStatic: Bool
    var isPushable: Bool
    var isAcceleratable: Bool

    init(polygon: RegularPolygon,
         mass: CGFloat,
         restitution: CGFloat = 0.5,
         acceleration: CGVector = CGVector.zero,
         isStatic: Bool,
         isPushable: Bool = true,
         isAcceleratable: Bool = true) {
        self.previousCenter = polygon.center
        self.mass = mass
        self.restitution = restitution
        self.acceleration = acceleration
        self.isStatic = isStatic
        self.internalShape = polygon
        self.isPushable = isPushable
        self.isAcceleratable = isAcceleratable
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

extension RegularPolygonalPhysicsBody: RegularPolygonalCollidableBody {}
