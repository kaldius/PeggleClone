/**
 `SquareBox` represents an upright, square-shaped object in the `Level`.
 */

import CoreGraphics

struct SquareBox {
    private let internalPolygon: RegularPolygon
    let id: ObjectIdentifier

    var height: CGFloat {
        let selectedVertex = internalPolygon.vertices[0]
        var smallestHeight = CGFloat.infinity
        for vertex in internalPolygon.vertices where vertex != selectedVertex {
            smallestHeight = min(smallestHeight, (vertex - selectedVertex).length)
        }
        return smallestHeight
    }

    var center: CGPoint {
        internalPolygon.center.asCGPoint
    }

    init(id: ObjectIdentifier, polygon: RegularPolygon) throws {
        self.id = id
        self.internalPolygon = polygon
        if !isValidBox(polygon: polygon) {
            throw PeggleError.invalidBoxError(vertices: polygon.vertices)
        }
    }

    init(id: ObjectIdentifier, minX: CGFloat, minY: CGFloat, width: CGFloat, height: CGFloat) {
        self.id = id
        let maxX = minX + width
        let maxY = minY + height
        let center = CGVector(dx: (maxX - minX) / 2 + minX,
                              dy: (maxY - minY) / 2 + minY)
        self.internalPolygon = RegularPolygon(center: center,
                                              numberOfSides: 4,
                                              centerToFirstVertex: CGVector(dx: minX, dy: minY))
    }

    /// Checks that this is a 4 sided polygon and all vertices are the same distance
    /// from the center.
    private func isValidBox(polygon: RegularPolygon) -> Bool {
        return hasFourSides(polygon: polygon)
            && allVerticesSameDistanceFromCenter(polygon: polygon)
            && isUpright(polygon: polygon)
    }

    private func hasFourSides(polygon: RegularPolygon) -> Bool {
        polygon.vertices.count == 4
    }

    private func allVerticesSameDistanceFromCenter(polygon: RegularPolygon) -> Bool {
        let centerToVertexLength = (polygon.vertices[0] - polygon.center).length
        for vertex in polygon.vertices {
            let nextCenterToVertexLength = (vertex - polygon.center).length
            if !(nextCenterToVertexLength.isApproximatelyEqual(to: centerToVertexLength)) {
                return false
            }
        }
        return true
    }

    private func isUpright(polygon: RegularPolygon) -> Bool {
        let vectorA = polygon.vertices[0] - polygon.vertices[1]
        let vectorB = polygon.vertices[0] - polygon.vertices[2]
        let vectorC = polygon.vertices[0] - polygon.vertices[3]
        let allThreeVectors = [vectorA, vectorB, vectorC]
        let horizontal = CGVector(dx: 1, dy: 0)
        let vertical = CGVector(dx: 0, dy: 1)
        return oneVectorParallelTo(vector: horizontal, vectorArray: allThreeVectors)
            && oneVectorParallelTo(vector: vertical, vectorArray: allThreeVectors)
    }

    /// Checks if `vector` is parallel to at least one vector in `vectorArray`.
    private func oneVectorParallelTo(vector: CGVector, vectorArray: [CGVector]) -> Bool {
        for otherVector in vectorArray where otherVector.isParallel(to: vector) {
            return true
        }
        return false
    }
}
