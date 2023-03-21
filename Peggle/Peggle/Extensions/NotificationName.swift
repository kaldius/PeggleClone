/**
 Contains all notifications used to implement the oberserver pattern.
 */

import Foundation

extension Notification.Name {

    // MARK: PhysicsWorld
    static var bodyAdded: Notification.Name {
        return .init(rawValue: "PhysicsWorld.bodyAdded")
    }

    static var bodyMoved: Notification.Name {
        return .init(rawValue: "PhysicsWorld.bodyMoved")
    }

    static var bodyRemoved: Notification.Name {
        return .init(rawValue: "PhysicsWorld.bodyRemoved")
    }

    static var bodiesCollided: Notification.Name {
        return .init(rawValue: "PhysicsWorld.bodiesCollided")
    }

    // MARK: PeggleGame
    static var ballAdded: Notification.Name {
        return .init(rawValue: "PeggleGame.ballAdded")
    }

    static var ballMoved: Notification.Name {
        return .init(rawValue: "PeggleGame.ballMoved")
    }

    static var ballRemoved: Notification.Name {
        return .init(rawValue: "PeggleGame.ballRemoved")
    }

    static var pegAdded: Notification.Name {
        return .init(rawValue: "PeggleGame.pegAded")
    }

    static var pegMoved: Notification.Name {
        return .init(rawValue: "PeggleGame.pegMoved")
    }

    static var pegRemoved: Notification.Name {
        return .init(rawValue: "PeggleGame.pegRemoved")
    }

    static var pegHit: Notification.Name {
        return .init(rawValue: "PeggleGame.pegHit")
    }

    static var blockAdded: Notification.Name {
        return .init(rawValue: "PeggleGame.blockAdded")
    }

    static var blockRemoved: Notification.Name {
        return .init(rawValue: "PeggleGame.blockRemoved")
    }

    static var bucketMoved: Notification.Name {
        return .init(rawValue: "PeggleGame.bucketMoved")
    }

    static var bucketAdded: Notification.Name {
        return .init(rawValue: "PeggleGame.bucketAdded")
    }

    static var cannonMoved: Notification.Name {
        return .init(rawValue: "PeggleGame.cannonMoved")
    }

    static var cannonAdded: Notification.Name {
        return .init(rawValue: "PeggleGame.cannonAdded")
    }

    static var compulsaryPegCount: Notification.Name {
        return .init(rawValue: "PeggleGame.compulsaryPegCount")
    }

    static var totalPegCount: Notification.Name {
        return .init(rawValue: "PeggleGame.totalPegCount")
    }

    static var ballCount: Notification.Name {
        return .init(rawValue: "PeggleGame.ballCount")
    }

    static var win: Notification.Name {
        return .init(rawValue: "PeggleGame.win")
    }

    static var loss: Notification.Name {
        return .init(rawValue: "PeggleGame.loss")
    }

    static var scoreUpdate: Notification.Name {
        return .init(rawValue: "PeggleGame.scoreUpdate")
    }

    static var numPegsHit: Notification.Name {
        return .init(rawValue: "PeggleGame.numPegsHit")
    }

    static var timerUpdate: Notification.Name {
        return .init(rawValue: "PeggleGame.timerUpdate")
    }

    static var gameTimerUpdate: Notification.Name {
        return .init(rawValue: "PeggleGame.gameTimerUpdate")
    }
}
