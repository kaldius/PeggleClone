/*
 Extension of `CGVector` to support typical vector operations. Took inspiration from:
 https://gist.github.com/fewlinesofcode/ef88362186cc955cfb7119c2602607a3
 */

import CoreGraphics

extension CGVector: AdditiveArithmetic {

    public static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }

    public static func += (left: inout CGVector, right: CGVector) {
        left = left + right
    }

    public static func - (left: CGVector, right: CGVector) -> CGVector {
        return left + (-right)
    }

    public static func -= (left: inout CGVector, right: CGVector) {
        left = left - right
    }

    static prefix func - (vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }
}
