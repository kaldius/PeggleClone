/**
 The `ToolDelegate` protocol defines a set of methods that a `Tool`'s delegate class must have.
 */

import CoreGraphics

protocol ToolDelegate: AnyObject {
    func add(gameObject: any GameObject) throws
    func remove(gameObject: any GameObject)
    func move(objectAt point: CGPoint, to newCenter: CGPoint) throws -> CGPoint?
    func gameObject(at point: CGPoint) -> (any GameObject)?
    func scale(objectAt point: CGVector, by scaleFactor: CGFloat)
    func adjust(objectAt location: CGVector, to point: CGVector)
    func scale(objectAt location: CGVector, to point: CGVector)
}
