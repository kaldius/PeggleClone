/**
 Represents a Convex Polygon. The order of the vertices is important in this representation.
 */

import CoreGraphics
import simd

struct ConvexPolygon: Shape {
    var center: CGVector {
        get {
            return CGVector.arithmeticMean(points: vertices)
        }
        set(newCenter) {
            let translation = newCenter - center
            translate(by: translation)
        }
    }

    /// Vertices in **anticlockwise** order.
    var vertices: [CGVector]
    var numberOfSides: Int {
        vertices.count
    }
    var sidesAsVectors: [CGVector] {
        var outputArray = [CGVector]()
        for index in 0..<numberOfSides {
            let vertexA = getVertex(index: index)
            let vertexB = getVertex(index: index + 1)
            outputArray.append(vertexB - vertexA)
        }
        return outputArray
    }

    init(vertices: [CGVector]) throws {
        self.vertices = vertices
        if !checkRepresentation() {
            throw PeggleError.invalidConvexPolygonVerticesError(vertices: vertices)
        }
    }

    mutating func translate(by translation: CGVector) {
        vertices = vertices.map({ $0 + translation })
    }

    /// Rotates the polygon about its center by a specified angle in **radians**.
    mutating func rotate(byRadians angle: CGFloat) {
        var vertexVectorArray = centerToVertexVectors
        for index in 0..<vertexVectorArray.count {
            let rotatedVector = vertexVectorArray[index].rotated(byRadians: angle)
            vertexVectorArray[index] = rotatedVector
        }
        vertices = vectorsToVertices(vectors: vertexVectorArray)
    }

    mutating func applyRotation(matrix: simd_double2x2) {
        var newVertices = [CGVector]()
        for vertex in centerToVertexVectors {
            let newVertex = vertex.rotatedBy(matrix: matrix)
            newVertices.append(newVertex)
        }
        vertices = vectorsToVertices(vectors: newVertices)
    }

    /// Scales the polygon by a specified scale factor.
    mutating func scale(byFactor scaleFactor: CGFloat, maxLimit: CGFloat = 1000, minLimit: CGFloat = 0) {
        var vertexVectorArray = centerToVertexVectors
        for index in 0..<vertexVectorArray.count {
            let scaledVector = vertexVectorArray[index] * scaleFactor
            vertexVectorArray[index] = scaledVector
        }
        vertices = vectorsToVertices(vectors: vertexVectorArray)
    }

    /// Ignores the overall order of the vertices, but requires that relative order remains the same.
    /// ConvexPolygons are equal as long as their vertices align.
    static func == (lhs: ConvexPolygon, rhs: ConvexPolygon) -> Bool {
        let firstMatchingVertexIndex = rhs.vertices.firstIndex(where: { $0.isEquals(to: lhs.vertices[0]) })
        guard let firstIndex = firstMatchingVertexIndex,
              lhs.numberOfSides == rhs.numberOfSides else { return false }
        for index in 1..<lhs.numberOfSides {
            let vertexMatch = lhs.vertices[index].isEquals(to: rhs.getVertex(index: index + firstIndex))
            if !vertexMatch { return false }
        }
        return true
    }

    /// Returns an array of vectors from the center to a vertex,
    /// Order corresponds to `self.vertices`.
    private var centerToVertexVectors: [CGVector] {
        var outputArray = [CGVector]()
        for vertex in vertices {
            let centerToVertexVector = vertex - center
            outputArray.append(centerToVertexVector)
        }
        return outputArray
    }

    /// Generates all vertices of the polygon given an array of vectors from the center to the respective vertex.
    private func vectorsToVertices(vectors: [CGVector]) -> [CGVector] {
        var outputVertices = [CGVector]()
        for vector in vectors {
            outputVertices.append(center + vector)
        }
        return outputVertices
    }

    /// Iterates through every side, checking that the change in angle is always positive.
    /// At the end, checks that the sum of all the angles is 2 pi radians.
    private func checkRepresentation() -> Bool {
        guard vertices.count >= 3 else { return false }
        for index in 0..<numberOfSides {
            let prevVertex = getVertex(index: index - 1)
            let vertexUnderTest = getVertex(index: index)
            let nextVertex = getVertex(index: index + 1)
            let prevSideVector = prevVertex - vertexUnderTest
            let nextSideVector = nextVertex - vertexUnderTest
            let crossProduct = nextSideVector.cross(prevSideVector)
            if crossProduct > 0 {
                return false
            }
        }
        return true
    }

    /// Allows for indexing in a loop.
    /// Index [-1] will be the last item, index [count] will loop back to the first item.
    private func getVertex(index: Int) -> CGVector {
        if index >= 0 && index < numberOfSides {
            return vertices[index]
        } else if index < 0 {
            return getVertex(index: index + vertices.count)
        } else {
            return getVertex(index: index - vertices.count)
        }
    }
}
