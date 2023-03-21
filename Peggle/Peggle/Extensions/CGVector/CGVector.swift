import CoreGraphics
import simd

extension CGVector {
    var asCGPoint: CGPoint {
        CGPoint(x: dx, y: dy)
    }

    var length: CGFloat {
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }

    static func * (left: CGFloat, right: CGVector) -> CGVector {
        return CGVector(dx: right.dx * left, dy: right.dy * left)
    }

    static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx * right, dy: left.dy * right)
    }

    static func / (left: CGVector, right: CGFloat) -> CGVector {
        guard right != 0 else { fatalError("Divide by zero error") }
        return CGVector(dx: left.dx / right, dy: left.dy / right)
    }

    static func /= (left: inout CGVector, right: CGFloat) -> CGVector {
        guard right != 0 else { fatalError("Divide by zero error") }
        return CGVector(dx: left.dx / right, dy: left.dy / right)
    }

    static func *= (left: inout CGVector, right: CGFloat) {
        left = left * right
    }

    // allow 2 CGVectors with very similar dx and dy values to be considered equal
    func isEquals(to vector: CGVector) -> Bool {
        let difference = self - vector
        return abs(difference.dx) < pow(10, -10)
            && abs(difference.dy) < pow(10, -10)
    }

    var unitVector: CGVector {
        let ans =  CGVector(dx: dx / length, dy: dy / length)
        return ans
    }

    func dot(_ vector: CGVector) -> CGFloat {
        let ans = self.dx * vector.dx + self.dy * vector.dy
        return ans
    }

    func cross(_ vector: CGVector) -> CGFloat {
        let ans = self.dx * vector.dy - vector.dx * self.dy
        return ans
    }

    // θ = acos(AB), where A and B are unit vectors
    func absAngle(to vector: CGVector) -> CGFloat {
        acos(self.unitVector.dot(vector.unitVector))
    }

    /// Anticlockwise is positive, clockwise is negative.
    func angleFromVertical() -> CGFloat {
        let verticalVector = CGVector(dx: 0, dy: 1)
        let angle = absAngle(to: verticalVector)
        return dx < 0 ? angle : -angle
    }

    static func lengthOfProjection(of vector1: CGVector, onto vector2: CGVector) -> CGFloat {
        let ans = vector1.dot(vector2.unitVector)
        return ans
    }

    static func euclideanDistance(between vector1: CGVector, and vector2: CGVector) -> CGFloat {
        return (vector1 - vector2).length
    }

    // rotates anti-clockwise
    func rotated(byRadians angle: CGFloat) -> CGVector {
        let rotatedX: CGFloat = cos(angle) * dx - sin(angle) * dy
        let rotatedY: CGFloat = sin(angle) * dx + cos(angle) * dy
        return CGVector(dx: rotatedX, dy: rotatedY)
    }

    // rotates anti-clockwise
    var perpendicularUnitVector: CGVector {
        CGVector(dx: -dy, dy: dx).unitVector
    }

    func isParallel(to vector: CGVector) -> Bool {
        return self.unitVector.isEquals(to: vector.unitVector)
            || self.unitVector.isEquals(to: -vector.unitVector)
    }

    func isPerpendicular(to vector: CGVector) -> Bool {
        absAngle(to: vector).isApproximatelyEqual(to: CGFloat.pi / 2)
    }

    func mirrorAlong(axis: CGVector) -> CGVector {
        let ans = -(self - 2 * (self.dot(axis.unitVector)) * axis.unitVector)
        return ans
    }

    static func arithmeticMean(points: [CGVector]) -> CGVector {
        var total = CGVector.zero
        for point in points {
            total += point
        }
        return total / CGFloat(points.count)
    }

    static func getRotationMatrix(from vectorA: CGVector, to vectorB: CGVector) -> simd_double2x2 {
        let vector1 = vectorA.unitVector
        let vector2 = vectorB.unitVector
        return simd_double2x2(simd_double2(vector1.dx * vector2.dx + vector1.dy * vector2.dy,
                                           vector1.dx * vector2.dy - vector2.dx * vector1.dy),
                              simd_double2(vector2.dx * vector1.dy - vector1.dx * vector2.dy,
                                           vector1.dx * vector2.dx + vector1.dy * vector2.dy))
    }

    func rotatedBy(matrix: simd_double2x2) -> CGVector {
        let vectorAsSimd = simd_double2(dx, dy)
        let outputSimd = matrix * vectorAsSimd
        return CGVector(dx: outputSimd[0], dy: outputSimd[1])
    }

}
