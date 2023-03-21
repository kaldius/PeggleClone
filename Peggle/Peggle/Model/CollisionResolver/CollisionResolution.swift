import CoreGraphics

struct CollisionResolution {
    var deltaFirstBody: CGVector
    var deltaSecondBody: CGVector

    func flipped() -> CollisionResolution {
        CollisionResolution(deltaFirstBody: deltaSecondBody, deltaSecondBody: deltaFirstBody)
    }
}
