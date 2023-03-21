/**
 The `BlockPlacingTool` represents the tool in the level designer that allows the user
 to put down a block.
 */

import CoreGraphics
import UIKit

struct BlockPlacingTool: GameObjectPlacingTool {

    weak var toolDelegate: (any ToolDelegate)?

    var panInitialLocation: CGPoint?
    var draggedObjectCurrentPosition: CGPoint?

    init(toolDelegate: ToolDelegate) {
        self.toolDelegate = toolDelegate
    }

    /// When a tap gesture is detected on the level view, delegate the task of adding a block at that location.
    func useOnLevelView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        guard let delegate = toolDelegate, gestureRecognizer.view != nil else { return }
        let gestureLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        guard let newBlock = try? RectangularBlock(center: gestureLocation.asCGVector) else { return }
        // Adding a block is allowed to fail if tap is on invalid area
        try? delegate.add(gameObject: newBlock)
    }

    /// When a pan gesture is detected on the level view, do nothing.
    func useOnLevelView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        return
    }

    /// When a tap gesture is detected on the block view, do nothing.
    func useOnGameObjectView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        return
    }

    /// When a long-press gesture is detected on the block view, delegate the task of
    /// erasing the `Block` at that location, if it exists.
    func useOnGameObjectView(withGesture gestureRecognizer: UILongPressGestureRecognizer) {
        let toolLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        eraseGameObject(toolLocation: toolLocation)
    }

    static func == (lhs: BlockPlacingTool, rhs: BlockPlacingTool) -> Bool {
        return type(of: lhs) == type(of: rhs)
    }
}
