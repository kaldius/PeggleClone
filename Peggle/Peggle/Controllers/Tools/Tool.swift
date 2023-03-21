/**
 The `Tool` protocol defines a set of attributes and methods that all tools in the level designer must have.
 */

import CoreGraphics
import UIKit

protocol Tool: Equatable {
    var toolDelegate: (any ToolDelegate)? { get }

    func useOnLevelView(withGesture gestureRecognizer: UITapGestureRecognizer)
    func useOnLevelView(withGesture gestureRecognizer: UIPanGestureRecognizer)
    func useOnGameObjectView(withGesture gestureRecognizer: UITapGestureRecognizer)
    func useOnGameObjectView(withGesture gestureRecognizer: UILongPressGestureRecognizer)
    mutating func useOnGameObjectView(withGesture gestureRecognizer: UIPanGestureRecognizer)
}

extension Tool where Self: Equatable {
    func isEqualTo(_ other: any Tool) -> Bool {
        guard let otherTool = other as? Self else { return false }
        return self == otherTool
    }

    static func == (lhs: any Tool, rhs: any Tool) -> Bool {
        guard let left = lhs as? Self,
              let right = rhs as? Self else { return false }
        return left == right
    }
}

extension Tool {
    /// Factory method for creating `Tool`s.
    ///   - Parameters:
    ///     - toolType: a member of the `ToolType` enum to signify the type of `Tool` to create.
    ///     - toolDelegate: the object that the `Tool` can delegate it's tasks to.
    ///   - Returns: the initialized tool.
    static func factory(typeToCreate toolType: ToolType, delegate toolDelegate: ToolDelegate) -> any Tool {
        switch toolType {
        case .compulsaryPegPlacingTool:
            return CompulsaryPegPlacingTool(toolDelegate: toolDelegate)
        case .optionalPegPlacingTool:
            return OptionalPegPlacingTool(toolDelegate: toolDelegate)
        case .eraserTool:
            return EraserTool(toolDelegate: toolDelegate)
        }
    }

    /// Gets the coordinates of the location where the gesture was detected.
    ///   - Parameters:
    ///     - gestureRecognizer: a `UIGestureRecognizer`.
    ///   - Returns: the coordinates where the gesture was detected.
    func getLocationOf(gestureRecognizer: UIGestureRecognizer) -> CGPoint {
        return gestureRecognizer.location(in: gestureRecognizer.view?.superview)
    }

    /// Gets the relative coordinates of how far a **Pan** gesture has moved from its initial location.
    ///   - Parameters:
    ///     - panGestureRecognizer: a `UIPanGestureRecognizer`.
    ///   - Returns: the relative coordinates of the pan gesture.
    func getTranslationOf(panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint {
        return panGestureRecognizer.translation(in: panGestureRecognizer.view?.superview)
    }

    /// Delegates the task of erasing a `Peg` to the `ToolDelegate`.
    ///   - Parameters:
    ///     - gestureRecognizer: a `UIGestureRecognizer`.
    func eraseGameObject(toolLocation: CGPoint) {
        guard let delegate = toolDelegate else { return }
        guard let pegAtToolLocation = delegate.gameObject(at: toolLocation) else { return }
        delegate.remove(gameObject: pegAtToolLocation)
    }
}
