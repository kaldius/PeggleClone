/**
 The `ConfusementPegPlacingTool` represents the tool in the level designer that allows the user
 to put down an confusement peg.
 */

import CoreGraphics
import UIKit

struct ConfusementPegPlacingTool: GameObjectPlacingTool {

    weak var toolDelegate: (any ToolDelegate)?

    var panInitialLocation: CGPoint?
    var draggedObjectCurrentPosition: CGPoint?

    init(toolDelegate: ToolDelegate) {
        self.toolDelegate = toolDelegate
    }

    /// When a tap gesture is detected on the level view, delegate the task of adding a peg at that location.
    func useOnLevelView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        guard let delegate = toolDelegate, gestureRecognizer.view != nil else { return }
        let gestureLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        let newConfusementPeg = Peg(center: gestureLocation,
                                 radius: Peg.DEFAULTPEGRADIUS,
                                 type: .confusement)
        // Adding a peg is allowed to fail if tap is on invalid area
        try? delegate.add(gameObject: newConfusementPeg)
    }

    /// When a pan gesture is detected on the level view, do nothing.
    func useOnLevelView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        return
    }

    /// When a tap gesture is detected on the peg view, do nothing.
    func useOnGameObjectView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        return
    }

    /// When a long-press gesture is detected on the peg view, delegate the task of
    /// erasing the `Peg` at that location, if it exists.
    func useOnGameObjectView(withGesture gestureRecognizer: UILongPressGestureRecognizer) {
        let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        eraseGameObject(toolLocation: toolLocation)
    }

    static func == (lhs: ConfusementPegPlacingTool, rhs: ConfusementPegPlacingTool) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
}
