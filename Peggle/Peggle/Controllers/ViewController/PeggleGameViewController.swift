/**
 The ViewController for the game screen.
 */

import UIKit
import QuartzCore

class PeggleGameViewController: UIViewController {
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var paletteStackView: UIStackView!

    @IBOutlet weak var ballCounterText: UILabel!
    @IBOutlet weak var compulsaryPegCountText: UILabel!
    @IBOutlet weak var totalPegCountText: UILabel!
    @IBOutlet weak var scoreCounter: UILabel!

    private let notificationCenter = NotificationCenter.default

    private var ballViewRenderer: BallViewRenderer!
    private var pegViewRenderer: PegViewRenderer!
    private var blockViewRenderer: BlockViewRenderer!
    private var bucketViewRenderer: BucketViewRenderer!
    private var cannonViewRenderer: CannonViewRenderer!

    private var displayLink: CADisplayLink!
    private var peggleGame: PeggleGame!

    let levelDataManager = LevelDataManager()

    weak var levelDataSource: LevelDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        ballViewRenderer = BallViewRenderer(superView: levelView)
        pegViewRenderer = PegViewRenderer(superView: levelView)
        blockViewRenderer = BlockViewRenderer(superView: levelView)
        bucketViewRenderer = BucketViewRenderer(superView: levelView)
        cannonViewRenderer = CannonViewRenderer(superView: levelView)

        notificationCenter.addObserver(self, selector: #selector(addBallView), name: .ballAdded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(moveBallView), name: .ballMoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(removeBallView), name: .ballRemoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addPegView), name: .pegAdded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(removePegView), name: .pegRemoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(markPegViewAsHit), name: .pegHit, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addBlockView), name: .blockAdded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(removeBlockView), name: .blockRemoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addBucketView), name: .bucketAdded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(moveBucketView), name: .bucketMoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(addCannonView), name: .cannonAdded, object: nil)
        notificationCenter.addObserver(self, selector: #selector(moveCannonView), name: .cannonMoved, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateCompulsaryPegCount),
                                       name: .compulsaryPegCount, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateTotalPegCount),
                                       name: .totalPegCount, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateBallCount), name: .ballCount, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showWinNotification), name: .win, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showLossNotification), name: .loss, object: nil)
        notificationCenter.addObserver(self, selector: #selector(showScore), name: .scoreUpdate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(updateGameTimer), name: .gameTimerUpdate, object: nil)

        let levelViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPannedLevelView))
        levelView.addGestureRecognizer(levelViewPanGestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let levelName = levelDataSource?.getLevelName() {
            loadLevel(levelName: levelName)
        } else {
            presentAlert(message: "No levelName provided by LevelDataSource. Empty game level will be created.")
            self.peggleGame = createBlankPeggleGame()
        }

        displayLink = CADisplayLink(target: self, selector: #selector(step))
        self.displayLink.add(to: .current, forMode: RunLoop.Mode.default)
    }

    @IBAction func quitButtonPressed(_ sender: Any) {
        dismiss(animated: true)
        displayLink.invalidate()
        displayLink = nil
        peggleGame = nil
    }

    @objc func step() {
        let deltaTime = displayLink.targetTimestamp - displayLink.timestamp
        peggleGame.step(deltaTime: deltaTime)
    }

    @objc func userPannedLevelView(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            let location = sender.location(in: sender.view?.superview)
            executeThrowable(closure: { try peggleGame.shootBall(towards: $0)}, argument: location.asCGVector)
        default:
            let location = sender.location(in: sender.view?.superview)
            pointCannonTowards(direction: location.asCGVector)
        }
    }

    private func pointCannonTowards(direction: CGVector) {
        peggleGame.pointCannonTowards(direction: direction)
    }

    /// NotificationCenter callback for each time a ball is added to the `PeggleGame`.
    @objc func addBallView(_ notification: Notification) {
        guard let addedBall = notification.object as? Ball else { return }
        executeThrowable(closure: { try ballViewRenderer.addBallView(forBall: $0) }, argument: addedBall)
    }

    /// NotificationCenter callback for each time a ball is moved in the `PeggleGame`.
    @objc func moveBallView(_ notification: Notification) {
        guard let movementNotification = notification.object as? PeggleEngineBallMovedNotification else { return }
        ballViewRenderer.moveBallView(beforeBall: movementNotification.beforeBall,
                                      afterBall: movementNotification.afterBall)
    }

    /// NotificationCenter callback for each time a ball is removed from the `PeggleGame`.
    @objc func removeBallView(_ notification: Notification) {
        guard let removedBall = notification.object as? Ball else { return }
        ballViewRenderer.removeBallView(ball: removedBall)
    }

    /// NotificationCenter callback for each time a peg is added to the `PeggleGame`.
    @objc func addPegView(_ notification: Notification) {
        guard let addedPeg = notification.object as? Peg else { return }
        executeThrowable(closure: { try pegViewRenderer.addPegView(forPeg: $0) }, argument: addedPeg)
    }

    /// NotificationCenter callback for each time a peg is removed from the `PeggleGame`.
    @objc func removePegView(_ notification: Notification) {
        guard let removedPeg = notification.object as? Peg else { return }
        pegViewRenderer.fadeOutPegView(forPeg: removedPeg)
    }

    /// NotificationCenter callback for each time a peg is hit by the ball.
    @objc func markPegViewAsHit(_ notification: Notification) {
        guard let hitPeg = notification.object as? Peg else { return }
        executeThrowable(closure: { try pegViewRenderer.markPegViewAsHit(forPeg: $0) }, argument: hitPeg)
    }

    /// NotificationCenter callback for each time a block is added to the `PeggleGame`.
    @objc func addBlockView(_ notification: Notification) {
        guard let addedBlock = notification.object as? RectangularBlock else { return }
        blockViewRenderer.addBlockView(forBlock: addedBlock)
    }

    /// NotificationCenter callback for each time a block is removed from the `PeggleGame`.
    @objc func removeBlockView(_ notification: Notification) {
        guard let removedBlock = notification.object as? RectangularBlock else { return }
        blockViewRenderer.removeBlockView(block: removedBlock)
    }

    /// NotificationCenter callback for each time a bucket is added to the `PeggleGame`.
    @objc func addBucketView(_ notification: Notification) {
        guard let addedBucket = notification.object as? Bucket else { return }
        bucketViewRenderer.addBucketView(forBucket: addedBucket)
    }

    /// NotificationCenter callback for each time a bucket is added to the `PeggleGame`.
    @objc func moveBucketView(_ notification: Notification) {
        guard let movementNotification = notification.object as? PeggleEngineBucketMovedNotification else { return }
        let beforeBucket = movementNotification.beforeBucket
        let afterBucket = movementNotification.afterBucket
        bucketViewRenderer.moveBucketView(beforeBucket: beforeBucket, afterBucket: afterBucket)
    }

    /// NotificationCenter callback for each time a cannon is added to the `PeggleGame`.
    @objc func addCannonView(_ notification: Notification) {
        guard let addedCannon = notification.object as? Cannon else { return }
        executeThrowable(closure: { try cannonViewRenderer.addCannonView(forCannon: $0) }, argument: addedCannon)
    }

    /// NotificationCenter callback for each time a cannon is added to the `PeggleGame`.
    @objc func moveCannonView(_ notification: Notification) {
        guard let movementNotification = notification.object as? PeggleEngineCannonMovedNotification else { return }
        let beforeCannon = movementNotification.beforeCannon
        let afterCannon = movementNotification.afterCannon
        cannonViewRenderer.moveCannonView(beforeCannon: beforeCannon, afterCannon: afterCannon)
    }

    @objc func updateCompulsaryPegCount(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        compulsaryPegCountText.text = "Compulsary pegs left: \(count)"
    }

    @objc func updateTotalPegCount(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        totalPegCountText.text = "Total pegs left: \(count)"
    }

    @objc func updateBallCount(_ notification: Notification) {
        guard let count = notification.object as? Int else { return }
        ballCounterText.text = "Balls left: \(count)"
    }

    @objc func showWinNotification(_ notification: Notification) {
        presentAlert(title: "Congratulations!", message: "YOU WON!")
    }

    @objc func showLossNotification(_ notification: Notification) {
        presentAlert(title: "Oh no!", message: "You lost! Better luck next time!")
    }

    @objc func showScore(_ notification: Notification) {
        guard let score = notification.object as? Int else { return }
        scoreCounter.text = "Score: \(score)"
    }

    @objc func updateGameTimer(_ notification: Notification) {
        guard let time = notification.object as? (min: Int, sec: Int),
              peggleGame.level?.gameMode == GameMode.timeAttack else { return }
        ballCounterText.text = "Time left: \(time.min)min \(time.sec)s"
    }

    private func createBlankPeggleGame() -> PeggleGame? {
        let bounds = levelView.bounds
        do {
            let gameArea = try Area(xMin: bounds.minX,
                                    xMax: bounds.minX + bounds.width,
                                    yMin: bounds.minY,
                                    yMax: bounds.minY + bounds.height)
            return try PeggleGame(area: gameArea)
        } catch let error as PeggleError {
            presentAlert(message: "Error: \(error.errorMsg). Blank PeggleGame could not be created.")
        } catch {
            presentAlert(message: "Unexpected error: \(error.localizedDescription).")
        }
        return nil
    }

    private func executeThrowable<T>(closure: ((T) throws -> Void), argument: T) {
        do {
            try closure(argument)
        } catch let error as PeggleError {
            presentAlert(message: "Error: \(error.errorMsg).")
        } catch {
            presentAlert(message: "Unexpected error: \(error.localizedDescription).")
        }
    }

    private func presentAlert(title: String = "Error", message: String) {
        let alertMessage = message
        let alert = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    private func loadLevel(levelName: String) {
        do {
            let levelData = try levelDataManager.fetchLevelData(levelName: levelName)
            pegViewRenderer.removeAllPegViews()
            blockViewRenderer.removeAllBlockViews()
            let level = try Level(data: levelData, withWalls: false)
            self.peggleGame = try PeggleGame(level: level)
        } catch let error as PeggleError {
            presentAlert(message: "Error: \(error.errorMsg). Empty game level will be created.")
            self.peggleGame = createBlankPeggleGame()
        } catch {
            presentAlert(message: "Unexpected error: \(error.localizedDescription). Empty game level will be created.")
            self.peggleGame = createBlankPeggleGame()
        }
    }
}
