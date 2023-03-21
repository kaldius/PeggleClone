/**
 A `PhysicsBody` represnts a body in the Physics Engine that follows the laws of physics.
 Verlet Integration is used for calculating kinematics.
 */

import CoreGraphics

protocol PhysicsBody: AnyObject & CollidableBody {
    var center: CGVector { get }
    var previousCenter: CGVector { get set }
    var mass: CGFloat { get }
    var restitution: CGFloat { get }
    var acceleration: CGVector { get set }
    var isStatic: Bool { get }
    var isPushable: Bool { get }
    var isAcceleratable: Bool { get }

    func moveCenter(by vector: CGVector)
    func moveCenter(to newCenter: CGVector)
    func moveCenter(to newCenter: CGVector, from previousCenter: CGVector)
}

extension PhysicsBody {
    func apply(acceleration: CGVector) {
        if !isAcceleratable {
            self.acceleration = CGVector.zero
        } else {
            self.acceleration = acceleration
        }
    }

    func updateCenter(deltaTime: CGFloat) {
        if isStatic { return }
        // verlet integration step
        // x(t + dt) = 2x(t) - x(t - dt) + a(dt)^2
        moveCenter(to: 2 * center - previousCenter + acceleration * pow(deltaTime, 2))
    }

    func step(deltaTime: CGFloat) {
        if isStatic { return }
        let temp = center
        updateCenter(deltaTime: deltaTime)
        previousCenter = temp
    }

    func applyCollisionForce(force: CGVector, overallRestitution: CGFloat) {
        if isStatic || !isPushable { return }
        let newPreviousCenter = center + force
        let velocity = newPreviousCenter - previousCenter
        let newVelocity = -velocity.mirrorAlong(axis: force)
        moveCenter(to: newVelocity + newPreviousCenter, from: newPreviousCenter)
    }

    func flipVelocity() {
        moveCenter(to: previousCenter, from: center)
    }
}
