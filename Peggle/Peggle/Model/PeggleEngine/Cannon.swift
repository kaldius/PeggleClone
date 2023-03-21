import CoreGraphics

struct Cannon: Hashable {
    static let cannonStatetoAssetNameMap = ["loaded": "cannon-loaded",
                                            "unloaded": "cannon-unloaded"]
    var radius: CGFloat
    var position: CGVector
    var direction: CGVector
    var loaded: Bool

    init(radius: CGFloat, position: CGVector, direction: CGVector, loaded: Bool = true) {
        self.radius = radius
        self.position = position
        self.direction = direction
        self.loaded = loaded
    }
}
