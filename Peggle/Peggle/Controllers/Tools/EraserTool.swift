/**
 The `EraserTool` represents the tool in the level designer that allows the user to erase a peg.
 */

import CoreGraphics
import UIKit

struct EraserTool: Tool {
    weak var toolDelegate: (any ToolDelegate)?

    init(toolDelegate: ToolDelegate) {
        self.toolDelegate = toolDelegate
    }

    /// Variables used for handling pan gestures
    var panInitialLocation: CGPoint?
    var draggedPegCurrentPosition: CGPoint?

    /// When a tap gesture is detected on the level view, do nothing.
    func useOnLevelView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        return
    }

    /// When a pan gesture is detected on the level view, delegate the task of
    /// erasing the `Peg` at all locations covered by the pan gesture.
    func useOnLevelView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        eraseGameObject(toolLocation: toolLocation)
    }

    /// When a tap gesture is detected on the peg view, delegate the task of
    /// erasing the `Peg` at that location, if it exists.
    func useOnGameObjectView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        eraseGameObject(toolLocation: toolLocation)
    }

    /// When a long-press gesture is detected on the peg view, delegate the task
    /// of erasing the `Peg` at that location, if it exists.
    func useOnGameObjectView(withGesture gestureRecognizer: UILongPressGestureRecognizer) {
        let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        eraseGameObject(toolLocation: toolLocation)
    }

    /// When a pan gesture is detected on the peg view, delegate the task of erasing the `Peg` at every
    /// location panned to, if it exists.
    mutating func useOnGameObjectView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
            panInitialLocation = toolLocation
            eraseGameObject(toolLocation: toolLocation)
        case .changed:
            guard let toolLocation = getToolLocation(panGestureRecognizer: gestureRecognizer) else {
                return
            }
            eraseGameObject(toolLocation: toolLocation)
        default:
            return
        }
    }

    /// Given a panGestureRecognizer, returns the current location of the tool.
    func getToolLocation(panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint? {
        guard let initialLocation = panInitialLocation else { return nil }
        let translation = getTranslationOf(panGestureRecognizer: panGestureRecognizer)
        let fingerLocation = CGPoint(x: initialLocation.x + translation.x,
                                     y: initialLocation.y + translation.y)
        return fingerLocation
    }

    static func == (lhs: EraserTool, rhs: EraserTool) -> Bool {
        return true
    }
}
