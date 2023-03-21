import CoreGraphics
import UIKit

protocol GameObjectPlacingTool: Tool {

    /// Variables used for handling pan gestures
    var panInitialLocation: CGPoint? { get set }
    var draggedObjectCurrentPosition: CGPoint? { get set }
}

extension GameObjectPlacingTool {
    /// When a pan gesture is detected on the game object view, delegate the task of moving
    /// the `GameObject` to the current `translation` of the gesture.
    mutating func useOnGameObjectView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            let panLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
            guard toolDelegate?.gameObject(at: panLocation) != nil else { return }
            panInitialLocation = panLocation
            draggedObjectCurrentPosition = panLocation
        case .changed:
            guard let toolLocation = getToolLocation(panGestureRecognizer: gestureRecognizer) else {
                return
            }
            moveDraggedGameObject(to: toolLocation)
        case .ended:
            resetPanGestureVariables()
        default:
            // In unexpected cases, undo the pan gesture
            guard let initialLocation = panInitialLocation else { return }
            moveDraggedGameObject(to: initialLocation)
            resetPanGestureVariables()
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

    /// Delegates the task of moving the dragged game object from `draggedPegCurrentPosition` to
    /// a new position based on the `point` provided.
    private mutating func moveDraggedGameObject(to point: CGPoint) {
        guard let objectCurrentPosition = draggedObjectCurrentPosition else { return }
        draggedObjectCurrentPosition = try? toolDelegate?.move(objectAt: objectCurrentPosition, to: point)
    }

    private mutating func resetPanGestureVariables() {
        panInitialLocation = nil
        draggedObjectCurrentPosition = nil
    }
}
