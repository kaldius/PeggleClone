/**
 A `PeggleGame` is the game engine for Peggle. Internally, it has a `PhysicsWorld` that models objects in the game.
 */

import Foundation
import CoreGraphics

class PeggleGame {
    static let BALLSPEEDSCALEFACTOR = 0.04
    static let DEFAULTBUCKETSPEED = CGVector(dx: 2, dy: 0)
    static let DEFAULTBUCKETWIDTH = 150.0
    static let DEFAULTBUCKETHEIGHT = 50.0
    private static let DEFAULTCANNONRADIUS = 50.0
    private static let BALLSTATIONARYTHRESHOLD = 1.0
    private static let MAXSTATIONARYTICKS = 500
    private static let DEFAULTSTARTINGBALLS = 10
    static let DEFAULTKABOOMRADIUS = 100.0
    static let DEFAULTTIMERDURATION = 30
    static let DEFAULTTIMEATTACKPERCENTAGE = 0.7

    let notificationCenter = NotificationCenter.default
    let physicsWorld: PhysicsWorld
    let area: Area
    var cannon: Cannon
    var ballsLeft: Int? {
        didSet {
            guard let ballCount = ballsLeft else { return }
            postBallCountNotification(count: ballCount)
        }
    }
    var scoreCounter: Int
    var scoreThisRound: Int
    var numPegsHitThisRound: Int
    var gameTimer: GameTimer?

    /// The following 3 dictionaries map the respective `PhysicsBody` `ObjectIdentifier`s
    /// to the `PeggleGame` representation of the object.
    var idToPegMap: [ObjectIdentifier: Peg] {
        didSet {
            sendPegCountNotification()
        }
    }
    var idToBallMap: [ObjectIdentifier: Ball] {
        didSet {
            if idToBallMap.isEmpty {
                loadCannon()
            } else {
                unloadCannon()
            }
        }
    }
    var idToBlockMap: [ObjectIdentifier: RectangularBlock]
    var totalScoreOnBoard: Int
    private var wallIds: [ObjectIdentifier]
    var bucket: Bucket?

    private var ballStationaryTicks: Int

    var roundInProgress: Bool {
        idToBallMap.count > 0
    }
    var gameOver: Bool
    var level: Level?

    init(area: Area, ballCount: Int? = PeggleGame.DEFAULTSTARTINGBALLS) throws {
        self.physicsWorld = PhysicsWorld()
        self.area = area
        self.idToPegMap = [:]
        self.idToBallMap = [:]
        self.idToBlockMap = [:]
        self.wallIds = []
        self.ballStationaryTicks = 0
        self.ballsLeft = ballCount
        self.gameOver = false
        self.scoreCounter = 0
        self.scoreThisRound = 0
        self.numPegsHitThisRound = 0
        self.totalScoreOnBoard = 0
        self.cannon = Cannon(radius: PeggleGame.DEFAULTCANNONRADIUS,
                             position: CGVector(dx: (area.xMin + area.xMax) / 2,
                                                dy: Ball.DEFAULTBALLRADIUS),
                             direction: CGVector(dx: 0, dy: 1))
        postCannonAddedNotification(cannon: cannon)
        self.bucket = try createBucket()

        notificationCenter.addObserver(self, selector: #selector(bodyMoved), name: .bodyMoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(bodiesCollided), name: .bodiesCollided, object: nil)
        notificationCenter.addObserver(self, selector: #selector(timerUpdated), name: .timerUpdate, object: nil)

        insertWalls()
        if let addedBucket = bucket {
            postBucketAddedNotification(bucket: addedBucket)
        }
    }

    convenience init(level: Level) throws {
        if level.gameMode == GameMode.timeAttack {
            try self.init(area: level.area, ballCount: nil)
        } else {
            try self.init(area: level.area)
        }
        self.level = level
        // TODO: do smth
        if level.gameMode == GameMode.timeAttack {
            self.gameTimer = GameTimer()
            gameTimer?.start(timeInSeconds: PeggleGame.DEFAULTTIMERDURATION)
        }

        for peg in level.gameObjectSet.pegSet {
            try add(peg: peg)
        }
        for block in level.gameObjectSet.blockSet {
            try add(block: block)
        }
        self.totalScoreOnBoard = computeTotalScoreOnBoard()
    }

    func computeTotalScoreOnBoard() -> Int {
        var total = 0
        for peg in idToPegMap.values {
            total += PegType.pegTypeToScoreMap[peg.type] ?? 0
        }
        return total
    }

    func step(deltaTime: CGFloat, passes: Int = 1) {
        if gameOver { return }
        physicsWorld.step(deltaTime: deltaTime, passes: passes)
        if checkWin() {
            postWinNotification()
            gameOver = true
            gameTimer?.stop()
        }
        if !roundInProgress && checkLoss() {
            postLossNotification()
            gameOver = true
        }
    }

    private func checkWin() -> Bool {
        if !roundInProgress && level?.gameMode == GameMode.siam {
            if ballsLeft ?? 0 < 1 {
                return true
            }
        }
        if compulsaryPegCount > 0 {
            return false
        }
        return true
    }

    private func checkLoss() -> Bool {
        guard let ballCount = ballsLeft else {
            return false
        }
        return compulsaryPegCount > 0 && ballCount < 1
    }

    private func sendPegCountNotification() {
        postCompulsaryPegCountNotification(count: compulsaryPegCount)
        postTotalPegCountNotification(count: totalPegCount)
    }

    var compulsaryPegCount: Int {
        var count = 0
        for peg in idToPegMap.values where peg.type == PegType.compulsary {
            count += 1
        }
        return count
    }

    private var totalPegCount: Int {
        idToPegMap.count
    }

    func idOfPegsInRadius(center: CGVector,
                          radius: CGFloat) -> [ObjectIdentifier] {
        var outputArr = [ObjectIdentifier]()
        for (id, peg) in idToPegMap where CGVector.euclideanDistance(between: peg.center,
                                                                     and: center) < radius {
            outputArr.append(id)
        }
        return outputArr

    }

    func resolveStationaryBall(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        if ballStationaryTicks > PeggleGame.MAXSTATIONARYTICKS {
            if isBall(id: body1Id) {
                forcefullyRemove(id: body2Id)
            } else if isBall(id: body2Id) {
                forcefullyRemove(id: body1Id)
            }
        }
    }

    func isWall(id: ObjectIdentifier) -> Bool {
        wallIds.contains(id)
    }

    func isBall(id: ObjectIdentifier) -> Bool {
        idToBallMap.keys.contains(id)
    }

    func reverseBucketDirection() {
        guard let pieceIds = bucket?.getPieceIds() else { return }
        for pieceId in pieceIds {
            physicsWorld.flipVelocity(physicsBodyId: pieceId)
        }
    }

    func checkStationaryBall(beforeBall: Ball, afterBall: Ball) {
        let ballMovement = beforeBall.center - afterBall.center
        if abs(ballMovement.dx) < PeggleGame.BALLSTATIONARYTHRESHOLD
            && abs(ballMovement.dy) < PeggleGame.BALLSTATIONARYTHRESHOLD {
            ballStationaryTicks += 1
        } else {
            ballStationaryTicks = 0
        }
    }

    /// Takes in a `PhysicsBody` and if it is a `Peg`, marks the corresponding `Peg` as
    /// hit, then posts a notification to observers.
    func markHitPeg(body: any PhysicsBody) {
        let id = ObjectIdentifier(body)
        idToPegMap[id]?.gotHit = true
        guard let peg = idToPegMap[id] else { return }
        postPegHitNotification(peg: peg)
        if level?.gameMode == GameMode.siam {
            postLossNotification()
            gameOver = true
        }
    }

    /// Checks if the round has ended. If so, removes pegs that got hit and
    /// removes all balls.
    func checkRoundEnded() {
        guard ballsExittedArea() else { return }
        removePegsThatGotHit()
        removeAllBalls()
        computeScore()
    }

    private func computeScore() {
        scoreCounter += scoreThisRound * numPegsHitThisRound
        scoreThisRound = 0
        numPegsHitThisRound = 0
        postScoreUpdate(score: scoreCounter)
    }

    private func ballsExittedArea() -> Bool {
        for ball in Array(idToBallMap.values) where ball.isInside(area: area) {
            return false
        }
        return true
    }

    private func insertWalls() {
        for body in createAllBoundingBodies(area: area) {
            physicsWorld.add(physicsBody: body)
            wallIds.append(ObjectIdentifier(body))
        }
    }
}
