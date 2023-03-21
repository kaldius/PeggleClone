import XCTest
@testable import Peggle

final class ConvexPolygonTests: XCTestCase {
    var rectangle: ConvexPolygon!
    var triangle: ConvexPolygon!

    override func setUpWithError() throws {
        let vertexA = CGVector(dx: 10, dy: 10)
        let vertexB = CGVector(dx: 2, dy: 10)
        let vertexC = CGVector(dx: 2, dy: 2)
        let vertexD = CGVector(dx: 10, dy: 2)
        let rectangleVertices = [vertexA, vertexB, vertexC, vertexD]
        rectangle = try ConvexPolygon(vertices: rectangleVertices)

        let vertexE = CGVector(dx: 5, dy: 5)
        let vertexF = CGVector(dx: 3, dy: 3)
        let vertexG = CGVector(dx: 7, dy: 4)
        let triangleVertices = [vertexE, vertexF, vertexG]
        triangle = try ConvexPolygon(vertices: triangleVertices)
    }

    override func tearDown() {
        rectangle = nil
        triangle = nil
    }

    func testInit_validConvexPolygon() {
        let vertexA = CGVector(dx: 10, dy: 10)
        let vertexB = CGVector(dx: 5, dy: 11)
        let vertexC = CGVector(dx: -1, dy: 1)
        let vertexD = CGVector(dx: -2, dy: -3)
        let vertexE = CGVector(dx: 7, dy: -3)
        let vertices = [vertexA, vertexB, vertexC, vertexD, vertexE]

        XCTAssertNoThrow(try ConvexPolygon(vertices: vertices))
    }

    func testInit_nonConvexPolygon() {
        let vertexA = CGVector(dx: 10, dy: 10)
        let vertexB = CGVector(dx: 5, dy: 11)
        let vertexC = CGVector(dx: 3, dy: 0)
        let vertexD = CGVector(dx: -2, dy: -3)
        let vertexE = CGVector(dx: 7, dy: -3)
        let vertices = [vertexA, vertexB, vertexC, vertexD, vertexE]

        XCTAssertThrowsError(try ConvexPolygon(vertices: vertices))
    }

    func testInit_selfIntersectingPolygon() {
        let vertexA = CGVector(dx: 10, dy: 10)
        let vertexB = CGVector(dx: 5, dy: 11)
        let vertexC = CGVector(dx: 20, dy: 0)
        let vertexD = CGVector(dx: -2, dy: -3)
        let vertexE = CGVector(dx: 7, dy: -3)
        let vertices = [vertexA, vertexB, vertexC, vertexD, vertexE]

        XCTAssertThrowsError(try ConvexPolygon(vertices: vertices))
    }

    func testRotate() {
        rectangle.rotate(byRadians: -0.645772)
        let expectedVertexA = CGVector(dx: 11.6, dy: 6.79)
        let expectedVertexB = CGVector(dx: 5.21, dy: 11.6)
        let expectedVertexC = CGVector(dx: 0.4, dy: 5.21)
        let expectedVertexD = CGVector(dx: 6.79, dy: 0.4)
        let expectedVertices = [expectedVertexA, expectedVertexB, expectedVertexC, expectedVertexD]

        for index in 0..<rectangle.vertices.count {
            let actualX = rectangle.vertices[index].dx
            let expectedX = expectedVertices[index].dx
            let actualY = rectangle.vertices[index].dy
            let expectedY = expectedVertices[index].dy
            XCTAssertEqual(actualX, expectedX, accuracy: 0.01)
            XCTAssertEqual(actualY, expectedY, accuracy: 0.01)
        }
    }

    func testScale() {
        rectangle.scale(byFactor: 1.3)
        let expectedVertexA = CGVector(dx: 11.2, dy: 11.2)
        let expectedVertexB = CGVector(dx: 0.8, dy: 11.2)
        let expectedVertexC = CGVector(dx: 0.8, dy: 0.8)
        let expectedVertexD = CGVector(dx: 11.2, dy: 0.8)
        let expectedVertices = [expectedVertexA, expectedVertexB, expectedVertexC, expectedVertexD]

        for index in 0..<rectangle.vertices.count {
            let actualX = rectangle.vertices[index].dx
            let expectedX = expectedVertices[index].dx
            let actualY = rectangle.vertices[index].dy
            let expectedY = expectedVertices[index].dy
            XCTAssertEqual(actualX, expectedX, accuracy: 0.01)
            XCTAssertEqual(actualY, expectedY, accuracy: 0.01)
        }
    }

    func testEqual_rectangleAndTriangle_notEqual() {
        XCTAssertFalse(rectangle == triangle)
    }

    func testEqual_rectangleAndNinetyDegreeRotatedRectangle_equal() {
        var rotatedRectangle = rectangle
        rotatedRectangle?.rotate(byRadians: CGFloat.pi / 2)
        XCTAssertTrue(rectangle == rotatedRectangle)
    }
}
