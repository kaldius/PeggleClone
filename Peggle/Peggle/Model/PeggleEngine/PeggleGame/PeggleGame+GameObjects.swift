import CoreGraphics

extension PeggleGame {
    func turnPegIntoBall(id: ObjectIdentifier) {
        guard var peg = removePeg(id: id) else { return }
        peg.center += CGVector(dx: 1, dy: 1)
        let ball = Ball(center: peg.center.asCGPoint, radius: peg.radius)
        let ballPhysicsBody = CircularPhysicsBody(circle: ball.internalShape, isStatic: false)
        try? add(ball: ball, ballPhysicsBody: ballPhysicsBody)
    }

    func forcefullyRemove(id: ObjectIdentifier) {
        if let removedPeg = idToPegMap.removeValue(forKey: id) {
            if removedPeg.type == PegType.kaboom {
                kaboom(id: id)
            }
            scoreThisRound += PegType.pegTypeToScoreMap[removedPeg.type] ?? 0
            physicsWorld.remove(physicsBodyId: id)
            postPegRemovedNotification(peg: removedPeg)
        }
        if let removedBlock = idToBlockMap.removeValue(forKey: id) {
            physicsWorld.remove(physicsBodyId: id)
            postBlockRemovedNotification(block: removedBlock)
        }
    }

    /// Creates a physics body to add to the physics engine,
    /// stores the peg in by its id,
    /// and posts a notification for the view controller that a peg has been added.
    func add(peg: Peg) throws {
        let pegPhysicsBody = try createPhysicsBody(forPeg: peg)
        let pegPhysicsBodyId = ObjectIdentifier(pegPhysicsBody)
        idToPegMap[pegPhysicsBodyId] = peg
        physicsWorld.add(physicsBody: pegPhysicsBody)
        postPegAddedNotification(peg: peg)
    }

    /// Adds `ballPhysicsBody` to the physics engine,
    /// stores the ball in by its id,
    /// and posts a notification for the view controller that a ball has been added.
    func add(ball: Ball, ballPhysicsBody: CircularPhysicsBody) throws {
        let ballPhysicsBodyId = ObjectIdentifier(ballPhysicsBody)
        idToBallMap[ballPhysicsBodyId] = ball
        physicsWorld.add(physicsBody: ballPhysicsBody)
        postBallAddedNotification(ball: ball)
    }

    func add(block: RectangularBlock) throws {
        let blockPhysicsBody = try createPhysicsBody(forBlock: block)
        let blockPhysicsBodyId = ObjectIdentifier(blockPhysicsBody)
        idToBlockMap[blockPhysicsBodyId] = block
        physicsWorld.add(physicsBody: blockPhysicsBody)
        postBlockAddedNotification(block: block)
    }

    func removeBlock(id: ObjectIdentifier) {
        physicsWorld.remove(physicsBodyId: id)
        guard let block = idToBlockMap.removeValue(forKey: id) else { return }
        postBlockRemovedNotification(block: block)
    }

    @discardableResult
    func removePeg(id: ObjectIdentifier) -> Peg? {
        physicsWorld.remove(physicsBodyId: id)
        guard let peg = idToPegMap.removeValue(forKey: id) else { return nil }
        postPegRemovedNotification(peg: peg)
        return peg
    }

    func removePegsThatGotHit() {
        for (id, peg) in idToPegMap where peg.gotHit {
            scoreThisRound += PegType.pegTypeToScoreMap[peg.type] ?? 0
            numPegsHitThisRound += 1
            removePeg(id: id)
        }
    }

    func removeAllBalls() {
        for (id, _) in idToBallMap {
            removeBall(id: id)
        }
    }

    func removeBall(id: ObjectIdentifier) {
        guard var ball = idToBallMap[id] else { return }
        let deletedPhysicsBody = physicsWorld.remove(physicsBodyId: id)
        idToBallMap.removeValue(forKey: id)
        postBallRemovedNotification(ball: ball)
        guard let originalPB = deletedPhysicsBody else { return }
        if ball.extraLife > 0 {
            ball.extraLife -= 1
            ball.center.dy = area.yMin
            let ballPhysicsBody = CircularPhysicsBody(circle: ball.internalShape,
                                                      mass: originalPB.mass,
                                                      restitution: originalPB.restitution,
                                                      isStatic: false,
                                                      isPushable: true,
                                                      isAcceleratable: true)
            let velocity = originalPB.center - originalPB.previousCenter
            ballPhysicsBody.moveCenter(to: ball.internalShape.center + velocity,
                                       from: ball.internalShape.center)
            try? add(ball: ball, ballPhysicsBody: ballPhysicsBody)
        }
    }

    /// Given a point to shoot the ball towards, finds the center of the ball to insert.
    func getBallCenter(towards point: CGVector) -> CGVector {
        let shootingVector = (point - cannon.position) * PeggleGame.BALLSPEEDSCALEFACTOR
        return cannon.position + shootingVector
    }
}
