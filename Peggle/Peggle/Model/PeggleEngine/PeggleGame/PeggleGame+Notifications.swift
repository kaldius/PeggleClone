extension PeggleGame {
    func postBallAddedNotification(ball: Ball) {
        notificationCenter.post(name: .ballAdded, object: ball)
    }

    func postBallMovedNotification(beforeBall: Ball, afterBall: Ball) {
        let movementNotification = PeggleEngineBallMovedNotification(beforeBall: beforeBall,
                                                                     afterBall: afterBall)
        notificationCenter.post(name: .ballMoved, object: movementNotification)
    }

    func postBallRemovedNotification(ball: Ball) {
        notificationCenter.post(name: .ballRemoved, object: ball)
    }

    func postPegAddedNotification(peg: Peg) {
        notificationCenter.post(name: .pegAdded, object: peg)
    }

    func postPegRemovedNotification(peg: Peg) {
        notificationCenter.post(name: .pegRemoved, object: peg)
    }

    func postPegHitNotification(peg: Peg) {
        notificationCenter.post(name: .pegHit, object: peg)
    }

    func postBlockAddedNotification(block: RectangularBlock) {
        notificationCenter.post(name: .blockAdded, object: block)
    }

    func postBlockRemovedNotification(block: RectangularBlock) {
        notificationCenter.post(name: .blockRemoved, object: block)
    }

    func postBucketAddedNotification(bucket: Bucket) {
        notificationCenter.post(name: .bucketAdded, object: bucket)
    }

    func postBucketMovedNotification(beforeBucket: Bucket, afterBucket: Bucket) {
        let movementNotification = PeggleEngineBucketMovedNotification(beforeBucket: beforeBucket,
                                                                       afterBucket: afterBucket)
        notificationCenter.post(name: .bucketMoved, object: movementNotification)
    }

    func postCannonAddedNotification(cannon: Cannon) {
        notificationCenter.post(name: .cannonAdded, object: cannon)
    }

    func postCannonMovedNotification(beforeCannon: Cannon, afterCannon: Cannon) {
        let movementNotificaion = PeggleEngineCannonMovedNotification(beforeCannon: beforeCannon,
                                                                      afterCannon: afterCannon)
        notificationCenter.post(name: .cannonMoved, object: movementNotificaion)
    }

    func postCompulsaryPegCountNotification(count: Int) {
        notificationCenter.post(name: .compulsaryPegCount, object: count)
    }

    func postTotalPegCountNotification(count: Int) {
        notificationCenter.post(name: .totalPegCount, object: count)
    }

    func postBallCountNotification(count: Int) {
        notificationCenter.post(name: .ballCount, object: count)
    }

    func postWinNotification() {
        notificationCenter.post(name: .win, object: nil)
    }

    func postLossNotification() {
        notificationCenter.post(name: .loss, object: nil)
    }

    func postScoreUpdate(score: Int) {
        notificationCenter.post(name: .scoreUpdate, object: score)
    }

    func postNumPegsHit(num: Int) {
        notificationCenter.post(name: .numPegsHit, object: num)
    }

    func postGameTimerNotification(timeInMinSec: (min: Int, sec: Int)) {
        notificationCenter.post(name: .gameTimerUpdate, object: timeInMinSec)
    }
}
