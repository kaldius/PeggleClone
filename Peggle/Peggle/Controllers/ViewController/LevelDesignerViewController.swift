/**
 ViewController for the Level Designer screen.
 */

import CoreData
import UIKit

class LevelDesignerViewController: UIViewController {

    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var levelNameField: UITextField!
    @IBOutlet weak var optionalPegToolButton: UIButton!
    @IBOutlet weak var compulsaryPegToolButton: UIButton!
    @IBOutlet weak var confusementPegToolButton: UIButton!
    @IBOutlet weak var zombiePegToolButton: UIButton!
    @IBOutlet weak var spookyPegToolButton: UIButton!
    @IBOutlet weak var kaboomPegToolButton: UIButton!
    @IBOutlet weak var eraserToolButton: UIButton!
    @IBOutlet weak var blockToolButton: UIButton!
    @IBOutlet weak var resizeRotateToolButton: UIButton!
    @IBOutlet weak var gameModePicker: UIPickerView!

    private var toolButtonToToolMap: [UIButton: any Tool] = [:]
    private lazy var pegViewRenderer: PegViewRenderer = PegViewRenderer(superView: levelView, delegate: self)
    private lazy var blockViewRenderer: BlockViewRenderer = BlockViewRenderer(superView: levelView, delegate: self)
    private var pickerData: [GameMode] = GameMode.allCases

    private var level: Level? {
        didSet {
            updateLevelView()
        }
    }

    private var selectedTool: (any Tool)? {
        willSet(newTool) {
            for (toolButton, tool) in toolButtonToToolMap {
                let buttonEnabled = !(newTool?.isEqualTo(tool) ?? false)
                toolButton.isEnabled = buttonEnabled
                toolButton.alpha = buttonEnabled ? 0.5 : 1.0
            }
        }
    }

    // Used to save and load from persistent storage
    var levelDataManager = LevelDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        let levelViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTappedLevelView))
        let levelViewPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPannedLevelView))
        levelView.addGestureRecognizer(levelViewTapGestureRecognizer)
        levelView.addGestureRecognizer(levelViewPanGestureRecognizer)
        toolButtonToToolMap = [
            compulsaryPegToolButton: CompulsaryPegPlacingTool(toolDelegate: self),
            optionalPegToolButton: OptionalPegPlacingTool(toolDelegate: self),
            confusementPegToolButton: ConfusementPegPlacingTool(toolDelegate: self),
            zombiePegToolButton: ZombiePegPlacingTool(toolDelegate: self),
            spookyPegToolButton: SpookyPegPlacingTool(toolDelegate: self),
            kaboomPegToolButton: KaboomPegPlacingTool(toolDelegate: self),
            eraserToolButton: EraserTool(toolDelegate: self),
            blockToolButton: BlockPlacingTool(toolDelegate: self),
            resizeRotateToolButton: ResizeRotateTool(toolDelegate: self)
        ]

        self.gameModePicker.delegate = self
        self.gameModePicker.dataSource = self

        // switch to optionalPegTool when view first loads
        switchToOptionalPegTool()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // self.level has to be initialized here because we need auto layout
        // to set the bounds on all views first before creating level
        do {
            let screenLevelArea = try getScreenLevelArea()
            self.level = try Level(area: screenLevelArea)
        } catch let peggleError as PeggleError {
            presentAlert(message: "Error: \(peggleError.errorMsg). This device might not be supported.")
        } catch {
            presentAlert(message: "Unexpected error \(error.localizedDescription).")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LevelSelectViewController {
            destination.loadLevelDelegate = self
        } else if let destination = segue.destination as? PeggleGameViewController {
            destination.levelDataSource = self
        }
    }

    @IBAction func userTappedLevelView(_ sender: UITapGestureRecognizer) {
        selectedTool?.useOnLevelView(withGesture: sender)
    }

    @IBAction func userPannedLevelView(_ sender: UIPanGestureRecognizer) {
        selectedTool?.useOnLevelView(withGesture: sender)
    }

    @IBAction func optionalPegToolButtonPressed(_ sender: Any) {
        switchToOptionalPegTool()
    }

    @IBAction func compulsaryPegToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[compulsaryPegToolButton]
    }

    @IBAction func confusementPegToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[confusementPegToolButton]
    }

    @IBAction func zombiePegToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[zombiePegToolButton]
    }

    @IBAction func spookyPegToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[spookyPegToolButton]
    }

    @IBAction func kaboomPegToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[kaboomPegToolButton]
    }

    @IBAction func eraserToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[eraserToolButton]
    }

    @IBAction func blockToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[blockToolButton]
    }

    @IBAction func resizeRotateToolButtonPressed(_ sender: Any) {
        selectedTool = toolButtonToToolMap[resizeRotateToolButton]
    }

    /// When the "SAVE" button is pressed, save the current level, setting its name
    /// to the text in the `levelNameField`
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let levelName = levelNameField.text, !levelName.isEmpty else {
            presentAlert(message: "Please provide a level name!")
            return
        }
        level?.name = levelName
        save(levelName: levelName)
    }

    @IBAction func resetButtonPressed(_ sender: Any) {
        level?.reset()
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        // This should start the game. Not implemented yet
    }

    @IBAction func quitButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }

    private func getScreenLevelArea() throws -> Area {
        let levelAreaBounds = levelView.bounds
        let levelArea = try Area(xMin: levelAreaBounds.minX,
                                 xMax: levelAreaBounds.width,
                                 yMin: levelAreaBounds.minY,
                                 yMax: levelAreaBounds.height)
        return levelArea
    }

    private func switchToOptionalPegTool() {
        selectedTool = toolButtonToToolMap[optionalPegToolButton]
    }

    /// Reloads all `Peg` views using data from `LevelDesigner`'s `Level`.
    private func updateLevelView() {
        updatePegs()
        updateBlocks()
    }

    private func updatePegs() {
        guard var setOfChanges = level?.gameObjectSet, setOfChanges.hasPegChanges else { return }
        while setOfChanges.hasPegChanges {
            guard let change = setOfChanges.retrieveOldestPegChange() else { continue }
            if change.isSwap {
                guard let beforePeg = change.before, let afterPeg = change.after else {
                    return
                }
                pegViewRenderer.movePegView(fromPeg: beforePeg, toPeg: afterPeg)
            } else if change.isAddition {
                guard let newPeg = change.after else { return }
                executeThrowable(closure: { try pegViewRenderer.addPegView(forPeg: $0) }, argument: newPeg)
            } else if change.isRemoval {
                guard let removedPeg = change.before else { return }
                pegViewRenderer.removePegView(forPeg: removedPeg)
            }
        }
        level?.gameObjectSet.clearPegCache()
    }

    private func updateBlocks() {
        guard var setOfChanges = level?.gameObjectSet, setOfChanges.hasBlockChanges else { return }
        while setOfChanges.hasBlockChanges {
            guard let change = setOfChanges.retrieveOldestBlockChange() else { continue }
            if change.isSwap {
                guard let beforeBlock = change.before, let afterBlock = change.after else {
                    return
                }
                blockViewRenderer.moveBlockView(beforeBlock: beforeBlock, afterBlock: afterBlock)
            } else if change.isAddition {
                guard let newBlock = change.after else { return }
                blockViewRenderer.addBlockView(forBlock: newBlock)
            } else if change.isRemoval {
                guard let removedBlock = change.before else { return }
                blockViewRenderer.removeBlockView(block: removedBlock)
            }
        }
        level?.gameObjectSet.clearBlockCache()
    }

    private func executeThrowable<T>(closure: ((T) throws -> Void), argument: T) {
        do {
            try closure(argument)
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

    /// Presents an alert to ask the user whether or not to overwrite an existing save file with the same name.
    private func getOverrideConfirmation(levelName: String) {
        let title = "Overwrite"
        let message = "Saved data exists under this name '\(levelName)'. Do you want to overwrite?"
        let confirmationAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (_: UIAlertAction) in
            self.save(levelName: levelName, overwrite: true)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        confirmationAlert.addAction(cancelAction)
        confirmationAlert.addAction(okayAction)
        present(confirmationAlert, animated: true, completion: nil)
    }

    /// Saves the current level. If there is another level with the same name, asks user if
    /// it should be overridden.
    ///   - Parameters:
    ///     - levelName: the name fo the level to save.
    ///     - overwrite: whether or not to overwrite an existing save file with the same name.
    private func save(levelName: String, overwrite: Bool = false) {
        guard var levelToSave = level else { return }
        do {
            levelToSave.name = levelName
            try levelDataManager.saveLevelData(level: levelToSave, overwrite: overwrite)
            presentAlert(title: "Success", message: "'\(levelName)' successfully saved!")
        } catch PeggleError.duplicateLevelNameError(levelName: levelName) {
            getOverrideConfirmation(levelName: levelName)
        } catch {
            presentAlert(message: "Unexpected error: \(error.localizedDescription).")
        }
    }
}

// MARK: +LoadLevelDelegate
extension LevelDesignerViewController: LoadLevelDelegate {
    func loadLevel(levelName: String) {
        do {
            let levelData = try levelDataManager.fetchLevelData(levelName: levelName)
            pegViewRenderer.removeAllPegViews()
            blockViewRenderer.removeAllBlockViews()
            var newLevel = try Level(data: levelData)
            let screenLevelArea = try getScreenLevelArea()
            newLevel.scale(toFit: screenLevelArea)
            self.level = newLevel
            self.levelNameField.text = levelName
        } catch let peggleError as PeggleError {
            presentAlert(message: peggleError.errorMsg)
        } catch {
            presentAlert(message: "Unexpected error: \(error.localizedDescription).")
        }
    }
}

// MARK: +GameObjectViewDelegate
extension LevelDesignerViewController: GameObjectViewDelegate {
    func userTappedGameObjectView(_ sender: UITapGestureRecognizer) {
        selectedTool?.useOnGameObjectView(withGesture: sender)
    }

    func userLongPressedGameObjectView(_ sender: UILongPressGestureRecognizer) {
        selectedTool?.useOnGameObjectView(withGesture: sender)
    }

    func userPannedGameObjectView(_ sender: UIPanGestureRecognizer) {
        selectedTool?.useOnGameObjectView(withGesture: sender)
    }
}

// MARK: +ToolDelegate
extension LevelDesignerViewController: ToolDelegate {
    func scale(objectAt point: CGVector, by scaleFactor: CGFloat) {
        level?.scale(objectAt: point, by: scaleFactor)
    }

    func add(gameObject: any GameObject) throws {
        try level?.add(gameObject)
    }

    func remove(gameObject: any GameObject) {
        level?.remove(gameObject)
    }

    func move(objectAt point: CGPoint, to newCenter: CGPoint) throws -> CGPoint? {
        level?.move(objectAt: point.asCGVector, to: newCenter.asCGVector)
    }

    func gameObject(at point: CGPoint) -> (any GameObject)? {
        level?.gameObject(at: point)
    }

    func adjust(objectAt location: CGVector, to point: CGVector) {
        level?.adjust(gameObjectAt: location, to: point)
    }

    func scale(objectAt location: CGVector, to point: CGVector) {
        level?.scale(objectAt: location, to: point)
    }
}

// MARK: +LevelDataSource
extension LevelDesignerViewController: LevelDataSource {
    func getLevelName() -> String? {
        level?.name
    }
}

// MARK: +UIPickerViewDelegate
extension LevelDesignerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        level?.gameMode = pickerData[row]
    }
}

// MARK: +UIPickerViewDataSource
extension LevelDesignerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        let gameModeName = GameMode.gameModeToModeNameMap[pickerData[row]]
        return gameModeName
    }
}
