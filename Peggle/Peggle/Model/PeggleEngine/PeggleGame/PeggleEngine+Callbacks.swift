import Foundation
import CoreGraphics

extension PeggleGame {

    /// NotificaionCenter callback for every body update
    @objc func bodyMoved(_ notification: Notification) {
        guard let updateNotification = notification.object as? PhysicsBodyUpdateNotification else { return }
        let movedPhysicsBody = updateNotification.body
        if movedPhysicsBody as? CircularPhysicsBody != nil {
            ballMoved(notification)
        } else if let currBucket = bucket, currBucket.isBucketPiece(id: ObjectIdentifier(movedPhysicsBody)) {
            bucketMoved(notification)
        }
    }

    /// NotificaionCenter callback for every ball update
    @objc func ballMoved(_ notification: Notification) {
        guard let updateNotification = notification.object as? PhysicsBodyUpdateNotification else { return }
        let movedPhysicsBody = updateNotification.body
        let ballId = ObjectIdentifier(movedPhysicsBody)
        guard let movedBall = idToBallMap.removeValue(forKey: ballId) else {
            return
        }
        var newBall = movedBall
        newBall.center = movedPhysicsBody.center
        idToBallMap[ballId] = newBall
        postBallMovedNotification(beforeBall: movedBall, afterBall: newBall)
        checkRoundEnded()
        checkStationaryBall(beforeBall: movedBall, afterBall: newBall)
    }

    /// NotificaionCenter callback for every bucket update
    @objc func bucketMoved(_ notification: Notification) {
        guard let updateNotification = notification.object as? PhysicsBodyUpdateNotification,
              var currBucket = bucket else { return }
        let movedPhysicsBody = updateNotification.body
        let bucketPartId = ObjectIdentifier(movedPhysicsBody)
        let bucketBeforeMove = currBucket
        currBucket.movePart(withId: bucketPartId, to: movedPhysicsBody.center)
        bucket = currBucket
        postBucketMovedNotification(beforeBucket: bucketBeforeMove, afterBucket: currBucket)
    }

    /// NotificationCenter callback for every collision
    @objc func bodiesCollided(_ notification: Notification) {
        guard let collisionNotification = notification.object as? PhysicsBodyCollisionNotification else { return }
        let body1 = collisionNotification.body1
        let body2 = collisionNotification.body2
        let body1Id = ObjectIdentifier(body1)
        let body2Id = ObjectIdentifier(body2)
        markHitPeg(body: body1)
        markHitPeg(body: body2)
        checkBucketReachedWall(body1Id: body1Id, body2Id: body2Id)
        checkBallEnteredBucket(body1Id: body1Id, body2Id: body2Id)
        checkConfusementPeg(body1Id: body1Id, body2Id: body2Id)
        checkZombiePeg(body1Id: body1Id, body2Id: body2Id)
        checkSpookyPeg(body1Id: body1Id, body2Id: body2Id)
        checkKaboomPeg(body1Id: body1Id, body2Id: body2Id)
        resolveStationaryBall(body1Id: body1Id, body2Id: body2Id)
    }

    @objc func timerUpdated(_ notification: Notification) {
        guard let time = gameTimer?.timeInMinSec else { return }
        if time.min == 0 && time.sec == 0 {
            if Double(scoreCounter) < Double(totalScoreOnBoard) * PeggleGame.DEFAULTTIMEATTACKPERCENTAGE {
                postLossNotification()
                gameOver = true
            } else {
                postWinNotification()
                gameOver = true
            }
            gameTimer?.stop()
        }
        postGameTimerNotification(timeInMinSec: time)
    }
}
