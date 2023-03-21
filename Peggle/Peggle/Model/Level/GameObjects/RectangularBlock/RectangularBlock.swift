/**
 `RectangularBlock` represents a rectangle-shaped object in the `Level`, capable of being resized and rotated.
 */

import CoreData
import CoreGraphics

struct RectangularBlock: ConvexPolygonalBody {
    static let DEFAULTWIDTH: CGFloat = 100
    static let DEFAULTHEIGHT: CGFloat = 50
    static let MAXDIAGONALLENGTH: CGFloat = 300
    static let MINDIAGONALLENGTH: CGFloat = 50
    var internalShape: ConvexPolygon

    var visible: Bool

    var center: CGVector {
        internalShape.center
    }

    /// The length of the short side of the Rectangle
    var width: CGFloat {
        let sideLengthA = (internalShape.vertices[0] - internalShape.vertices[1]).length
        let sideLengthB = (internalShape.vertices[1] - internalShape.vertices[2]).length
        return min(sideLengthA, sideLengthB)
    }

    /// The length of the long side of the Rectangle
    var height: CGFloat {
        let sideLengthA = (internalShape.vertices[0] - internalShape.vertices[1]).length
        let sideLengthB = (internalShape.vertices[1] - internalShape.vertices[2]).length
        return max(sideLengthA, sideLengthB)
    }

    /// The anticlockwise angle between the long side and the vertical
    var angle: CGFloat {
        let sideVectorA = internalShape.vertices[0] - internalShape.vertices[1]
        let sideVectorB = internalShape.vertices[1] - internalShape.vertices[2]
        let longerVector = sideVectorA.length > sideVectorB.length ? sideVectorA : sideVectorB
        return longerVector.angleFromVertical()
    }

    init(polygon: ConvexPolygon, visible: Bool = true) throws {
        self.internalShape = polygon
        self.visible = visible
        if !checkRepresentation() {
            throw PeggleError.invalidRectangularBlockError(vertices: polygon.vertices)
        }
    }

    /// Constructs a RectangularBlock with default width and height centered around `center`.
    init(center: CGVector, visible: Bool = true) throws {
        let topLeftVertex = center + CGVector(dx: -RectangularBlock.DEFAULTWIDTH/2,
                                              dy: -RectangularBlock.DEFAULTHEIGHT/2)
        let bottomLeftVertex = center + CGVector(dx: -RectangularBlock.DEFAULTWIDTH/2,
                                                 dy: RectangularBlock.DEFAULTHEIGHT/2)
        let bottomRightVertex = center + CGVector(dx: RectangularBlock.DEFAULTWIDTH/2,
                                                  dy: RectangularBlock.DEFAULTHEIGHT/2)
        let topRightVertex = center + CGVector(dx: RectangularBlock.DEFAULTWIDTH/2,
                                               dy: -RectangularBlock.DEFAULTHEIGHT/2)
        let vertices = [topLeftVertex, bottomLeftVertex, bottomRightVertex, topRightVertex]
        try self.init(vertices: vertices, visible: visible)
    }

    init(vertices: [CGVector], visible: Bool = true) throws {
        let convexPolygon = try ConvexPolygon(vertices: vertices)
        try self.init(polygon: convexPolygon, visible: visible)
    }

    /// Checks that this is a 4 sided polygon with 4 right angles.
    private func checkRepresentation() -> Bool {
        return hasFourSides(polygon: internalShape)
            && allAnglesRightAngles(polygon: internalShape)
    }

    private func hasFourSides(polygon: ConvexPolygon) -> Bool {
        polygon.numberOfSides == 4
    }

    private func allAnglesRightAngles(polygon: ConvexPolygon) -> Bool {
        let sides = polygon.sidesAsVectors
        return sides[0].isPerpendicular(to: sides[1])
            && sides[1].isPerpendicular(to: sides[2])
            && sides[2].isPerpendicular(to: sides[3])
            && sides[3].isPerpendicular(to: sides[0])
    }

    private func nearestVertexTo(point: CGVector) -> CGVector {
        var nearestVertex = CGVector.zero
        var shortestDistance = CGFloat.infinity
        for vertex in internalShape.vertices {
            let distanceToPoint = CGVector.euclideanDistance(between: point, and: vertex)
            if distanceToPoint < shortestDistance {
                nearestVertex = vertex
                shortestDistance = distanceToPoint
            }
        }
        return nearestVertex
    }
}

// MARK: +GameObject
extension RectangularBlock: GameObject {
    mutating func translate(by translation: CGVector) {
        internalShape.translate(by: translation)
    }

    mutating func translate(to newCenter: CGVector) {
        let translation = newCenter - center
        translate(by: translation)
    }

    mutating func rotate(byRadians angle: CGFloat) {
        internalShape.rotate(byRadians: angle)
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        internalShape.scale(byFactor: scaleFactor,
                            maxLimit: RectangularBlock.MAXDIAGONALLENGTH,
                            minLimit: RectangularBlock.MINDIAGONALLENGTH)
    }

    mutating func adjust(to point: CGVector) {
        let nearestVertex = nearestVertexTo(point: point)
        let rotationMatrix = CGVector.getRotationMatrix(from: nearestVertex, to: point)
        internalShape.applyRotation(matrix: rotationMatrix)
    }

    mutating func scale(to point: CGVector) {
        let nearestVertex = nearestVertexTo(point: point)
        let centerToVertexVector = nearestVertex - center
        let centerToPointVector = point - center
        let scaleFactor = centerToPointVector.length / centerToVertexVector.length
        scale(byFactor: scaleFactor)
    }

    func covers(point: CGVector) -> Bool {
        let xAxis = CGVector(dx: 1, dy: 0)
        let yAxis = CGVector(dx: 0, dy: 1)
        let extremePointsAlongXAxis = extremePointsAlong(axis: xAxis)
        let extremePointsAlongYAxis = extremePointsAlong(axis: yAxis)
        let xCoordinateWithinBlock = point.dx >= extremePointsAlongXAxis.min
                                  && point.dx <= extremePointsAlongXAxis.max
        let yCoordinateWithinBlock = point.dy >= extremePointsAlongYAxis.min
                                  && point.dy <= extremePointsAlongYAxis.max
        return xCoordinateWithinBlock && yCoordinateWithinBlock
    }
}

// MARK: +ToDataAble
extension RectangularBlock: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let rectangularBlockData = RectangularBlockData(context: context)
        var vertexDataArray = [NSManagedObject]()
        for vertex in internalShape.vertices {
            vertexDataArray.append(vertex.toData(context: context))
        }
        rectangularBlockData.vertices = NSOrderedSet(array: vertexDataArray)
        return rectangularBlockData as NSManagedObject
    }
}

// MARK: +FromDataAble
extension RectangularBlock: FromDataAble {
    init(data: RectangularBlockData) throws {
        guard let verticesData = data.vertices?.array as? [CGVectorData] else {
            throw PeggleError.invalidVerticesDataError
        }
        var newVertices = [CGVector]()
        for vertexData in verticesData {
            let vertex = try CGVector(data: vertexData)
            newVertices.append(vertex)
        }
        try self.init(vertices: newVertices)
    }
}

extension RectangularBlock: ConvexPolygonalCollidableBody {}
