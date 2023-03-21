/**
The `PhysicsWorld` consists of several `PhysicsBody`s. It updates all its `PhysicsBody`s with each step.
 */

import Foundation
import CoreGraphics

class PhysicsWorld {
    private var gravitationalAcceleration = CGVector(dx: 0, dy: 800)

    private let notificationCenter = NotificationCenter.default
    private var idToPhysicsBodyMap: [ObjectIdentifier: any PhysicsBody]
    private var physicsBodyArray: [any PhysicsBody] {
        Array(idToPhysicsBodyMap.values)
    }
    private var bodyIdsToRemove: [ObjectIdentifier]
    var counter: Int

    init() {
        self.idToPhysicsBodyMap = [:]
        counter = 0
        bodyIdsToRemove = []
    }

    func setGravity(vector: CGVector) {
        self.gravitationalAcceleration = vector
    }

    /// Progresses the time in the `PhysicsWorld` by one`deltaTime`.
    func step(deltaTime: CGFloat, passes: Int = 1) {
        let deltaTimePerPass = deltaTime / Double(passes)
        for _ in 1...passes {
            for index in 0..<physicsBodyArray.count {
                let body = physicsBodyArray[index]
                body.step(deltaTime: deltaTimePerPass)
                postBodyMovedNotification(body: body)
                body.apply(acceleration: gravitationalAcceleration)
            }
            resolveCollisions()
        }
        clearTrash()
    }

    /// Adds a new `PhysicsBody` and stores a mapping to it.
    func add(physicsBody: any PhysicsBody) {
        let id = ObjectIdentifier(physicsBody)
        applyAllAccelerations(to: physicsBody)
        idToPhysicsBodyMap[id] = physicsBody
    }

    /// Prepares to remove the `PhysicsBody` with the specified `ObjectIdentifier`.
    @discardableResult
    func remove(physicsBodyId: ObjectIdentifier) -> (any PhysicsBody)? {
        bodyIdsToRemove.append(physicsBodyId)
        return idToPhysicsBodyMap[physicsBodyId]
    }

    /// Reverses the direction of travel of a `PhysicsBody`.
    func flipVelocity(physicsBodyId: ObjectIdentifier) {
        idToPhysicsBodyMap[physicsBodyId]?.flipVelocity()
    }

    /// Does pairwise checks of all `PhysicsBody`s for collisions, then applies
    /// the appropriate resolution.
    private func resolveCollisions() {
        for index1 in 0..<physicsBodyArray.count {
            let body1 = physicsBodyArray[index1]
            for index2 in 0..<physicsBodyArray.count where index1 != index2 {
                let body2 = physicsBodyArray[index2]
                resolveCollision(between: body1, and: body2)
            }
        }
    }

    /// Removes all `PhysicsBody`s specified by `remove`.
    /// This is used because `PhysicsBody`s cannot be removed halfway through a `step`.
    private func clearTrash() {
        for id in bodyIdsToRemove {
            idToPhysicsBodyMap.removeValue(forKey: id)
        }
        bodyIdsToRemove = []
    }

    /// Finds the collision vector between two `PhysicsBody`s and applies
    /// the appropriate resolution depending on their `mass`es and `restitution`s.
    private func resolveCollision(between body1: any PhysicsBody, and body2: any PhysicsBody) {
        guard let collisionResolution = CollisionResolver.getCollisionResolution(between: body1, and: body2) else {
            return
        }

        let pushScalingFactors = calculatePushScalingFactor(body1: body1, body2: body2)
        let overallRestitution = (body1.restitution + body2.restitution) / 2
        let body1Delta = collisionResolution.deltaFirstBody * pushScalingFactors.body1 * overallRestitution
        let body2Delta = collisionResolution.deltaSecondBody * pushScalingFactors.body2 * overallRestitution
        body1.applyCollisionForce(force: body1Delta, overallRestitution: overallRestitution)
        body2.applyCollisionForce(force: body2Delta, overallRestitution: overallRestitution)

        postBodyMovedNotification(body: body1)
        postBodyMovedNotification(body: body2)
        postCollisionNotification(body1: body1, body2: body2)
    }

    /// Calculates how much to scale a collision force depending on the `PhysicsBody`s
    /// `mass` and `restitution`.
    private func calculatePushScalingFactor(body1: any PhysicsBody,
                                            body2: any PhysicsBody) -> (body1: CGFloat, body2: CGFloat) {
        var body1ScaleFactor: CGFloat = 1
        var body2ScaleFactor: CGFloat = 1
        if !body1.isStatic && !body2.isStatic {
            let totalMass = body1.mass + body2.mass
            body1ScaleFactor = body2.mass / totalMass
            body2ScaleFactor = body1.mass / totalMass
        } else if body1.isStatic && !body2.isStatic {
            body1ScaleFactor = 0
            body2ScaleFactor = 1
        } else if !body1.isStatic && body2.isStatic {
            body1ScaleFactor = 1
            body2ScaleFactor = 0
        }
        return (body1ScaleFactor, body2ScaleFactor)
    }

    /// Posts to the NotificationCenter that a body was moved.
    private func postBodyMovedNotification(body: any PhysicsBody) {
        let notification = PhysicsBodyUpdateNotification(body: body)
        notificationCenter.post(name: .bodyMoved, object: notification)
    }

    /// Posts to the NotificationCeter about the collision between two bodies.
    private func postCollisionNotification(body1: any PhysicsBody, body2: any PhysicsBody) {
        let notification = PhysicsBodyCollisionNotification(body1: body1, body2: body2)
        notificationCenter.post(name: .bodiesCollided, object: notification)
    }

    private func applyAllAccelerations(to body: any PhysicsBody) {
        body.apply(acceleration: gravitationalAcceleration)
    }
}
