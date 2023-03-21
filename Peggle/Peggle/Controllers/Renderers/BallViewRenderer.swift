/**
 Contains all the logic for adding, moving and removing `BallView`s.
 */

import UIKit

struct BallViewRenderer {
    let superView: UIView

    var ballToBallViewMap: [Ball: BallView]

    init(superView: UIView) {
        self.superView = superView
        self.ballToBallViewMap = [:]
    }

    mutating func addBallView(forBall ball: Ball) throws {
        let newBallView = try addToSuperView(ball: ball)
        ballToBallViewMap[ball] = newBallView
    }

    mutating func removeBallView(ball: Ball) {
        let ballViewToRemove = ballToBallViewMap.removeValue(forKey: ball)
        ballViewToRemove?.removeFromSuperview()
    }

    mutating func moveBallView(beforeBall: Ball, afterBall: Ball) {
        let ballViewToChange = ballToBallViewMap.removeValue(forKey: beforeBall)
        ballViewToChange?.setNewConstraints(center: afterBall.center.asCGPoint, radius: afterBall.radius)
        ballToBallViewMap[afterBall] = ballViewToChange
    }

    mutating func removeAllBallViews() {
        superView.subviews.forEach({ if $0 is BallView {$0.removeFromSuperview()} })
        ballToBallViewMap.removeAll()
    }

    private func addToSuperView(ball: Ball) throws -> BallView? {
        guard let assetName = BallType.ballTypeToAssetNameMap[ball.type] else {
            throw PeggleError.noAssetForBallError(ball: ball)
        }
        return BallView(center: ball.center.asCGPoint,
                        radius: ball.radius,
                        assetName: assetName,
                        superview: superView)
    }
}
