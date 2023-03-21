import CoreGraphics

extension PeggleGame {
    /// Creates a `CircularPhysicsBody` for a peg.
    func createPhysicsBody(forPeg peg: Peg) throws -> CircularPhysicsBody {
        let pegShape = Circle(center: peg.center, radius: peg.radius)
        let pegRestitution = peg.type == PegType.kaboom ? 2.0 : 1.0
        let pegPhysicsBody = CircularPhysicsBody(circle: pegShape,
                                                 restitution: pegRestitution,
                                                 acceleration: CGVector.zero,
                                                 isStatic: true)
        return pegPhysicsBody
    }

    /// Creates a `CircularPhysicsBody` for a ball, travelling from `previousCenter`.
    func createPhysicsBody(forBall ball: Ball,
                           movingFrom previousCenter: CGVector) throws -> CircularPhysicsBody {
        let ballShape = Circle(center: ball.center, radius: ball.radius + 1)
        let ballPhysicsBody = CircularPhysicsBody(circle: ballShape, movingFrom: previousCenter)
        return ballPhysicsBody
    }

    /// Creates a `CircularPhysicsBody` for a block.
    func createPhysicsBody(forBlock block: RectangularBlock) throws -> ConvexPolygonalPhysicsBody {
        let blockShape = block.internalShape
        let blockPhysicsBody = ConvexPolygonalPhysicsBody(polygon: blockShape,
                                                          acceleration: CGVector.zero,
                                                          isStatic: true)
        return blockPhysicsBody
    }
}
