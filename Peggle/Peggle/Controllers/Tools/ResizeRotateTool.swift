/**
 The `ResizeRotateTool` allows resizing and rotating of `GameObjects` in the Level Designer.
 */
import UIKit

struct ResizeRotateTool: Tool {
    var toolDelegate: ToolDelegate?
    var panPreviousLocation: CGPoint?
    var panInitialLocation: CGPoint?

    func useOnLevelView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        return
    }

    func useOnLevelView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        return
    }

    func useOnGameObjectView(withGesture gestureRecognizer: UITapGestureRecognizer) {
        return
    }

    func useOnGameObjectView(withGesture gestureRecognizer: UILongPressGestureRecognizer) {
        return
    }

    mutating func useOnGameObjectView(withGesture gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            storePanCurrentLocation(gestureRecognizer)
            panInitialLocation = panPreviousLocation
        case .changed:
            rotateGameObject(gestureRecognizer)
            scaleGameObject(gestureRecognizer)
            storePanCurrentLocation(gestureRecognizer)
        case .ended:
            panPreviousLocation = nil
        default:
            // In unexpected cases, undo the pan gesture
            return
        }
    }

    private func rotateGameObject(_ gestureRecognizer: UIPanGestureRecognizer) {
        let toolCurrentLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        guard let panInitialPoint = panInitialLocation,
              let gameObject = toolDelegate?.gameObject(at: panInitialPoint) else { return }
        toolDelegate?.adjust(objectAt: gameObject.center, to: toolCurrentLocation.asCGVector)
    }

    private func scaleGameObject(_ gestureRecognizer: UIPanGestureRecognizer) {
        let toolCurrentLocation = getLocationOf(gestureRecognizer: gestureRecognizer)
        guard let panInitialPoint = panInitialLocation,
              let gameObject = toolDelegate?.gameObject(at: panInitialPoint) else { return }
        toolDelegate?.scale(objectAt: gameObject.center, to: toolCurrentLocation.asCGVector)
    }

    private mutating func storePanCurrentLocation(_ gestureRecognizer: UIPanGestureRecognizer) {
        let panLocation = gestureRecognizer.location(in: gestureRecognizer.view?.superview)
        panPreviousLocation = panLocation
    }

    static func == (lhs: ResizeRotateTool, rhs: ResizeRotateTool) -> Bool {
        return true
    }
}
