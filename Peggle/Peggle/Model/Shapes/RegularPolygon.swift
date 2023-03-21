/**
 A `RegularPolygon` represents a polygon shape with sides of equal length.
 */

import CoreGraphics

struct RegularPolygon: Shape {
    var center: CGVector
    private let centerToFirstVertex: CGVector
    private let numberOfSides: Int

    var vertices: [CGVector] {
        let rotationAngle = 2.0 * Double.pi / Double(numberOfSides)

        var newVertices = [CGVector]()
        for vertexNumber in 0..<numberOfSides {
            let centerToNextVertex = centerToFirstVertex.rotated(byRadians: rotationAngle * Double(vertexNumber))
            let nextVertex = center + centerToNextVertex
            newVertices.append(nextVertex)
        }
        return newVertices
    }

    /// Constructs a **regular** polygon with `numberOfSides`.
    /// Vertices are stored in the `self.vertices` arry in an anti-clockwise direction.
    init(center: CGVector, numberOfSides: Int, centerToFirstVertex: CGVector) {
        self.center = center
        self.numberOfSides = numberOfSides
        self.centerToFirstVertex = centerToFirstVertex
    }
}
