import CoreGraphics

extension CGPoint {
    var asCGVector: CGVector {
        CGVector(dx: self.x, dy: self.y)
    }
}
