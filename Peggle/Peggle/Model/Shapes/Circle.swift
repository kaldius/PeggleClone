/**
 A `Circle` is primarily used to repsesent the shape of the `Ball` and `Peg` in the game.
 */

import CoreGraphics

struct Circle: Shape {

    var center: CGVector
    var radius: CGFloat

    init(center: CGVector, radius: CGFloat) {
        self.center = center
        self.radius = max(radius, 0)
    }
}
