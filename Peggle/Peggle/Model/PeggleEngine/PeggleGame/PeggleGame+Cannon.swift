import CoreGraphics

extension PeggleGame {
    func loadCannon() {
        let beforeCannon = cannon
        cannon.loaded = true
        postCannonMovedNotification(beforeCannon: beforeCannon, afterCannon: cannon)
    }

    func unloadCannon() {
        let beforeCannon = cannon
        cannon.loaded = false
        postCannonMovedNotification(beforeCannon: beforeCannon, afterCannon: cannon)
    }

    func pointCannonTowards(direction: CGVector) {
        let beforeCannon = cannon
        cannon.direction = (direction - cannon.position).unitVector
        postCannonMovedNotification(beforeCannon: beforeCannon, afterCannon: cannon)
    }

    /// Adds a ball with an initial velocity towards the given point.
    func shootBall(towards point: CGVector) throws {
        if roundInProgress { return }
        let ballCenter = getBallCenter(towards: point)
        let ball = Ball(center: ballCenter.asCGPoint)
        let ballPhysicsBody = try createPhysicsBody(forBall: ball, movingFrom: cannon.position)
        try add(ball: ball, ballPhysicsBody: ballPhysicsBody)
        guard let ballCount = ballsLeft else { return }
        ballsLeft = ballCount - 1
    }
}
