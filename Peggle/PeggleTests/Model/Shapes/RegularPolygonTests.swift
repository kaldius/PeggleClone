import XCTest
@testable import Peggle

final class RegularPolygonTests: XCTestCase {
    func testInit() {
        let center = CGVector(dx: 0, dy: 0)
        let numberOfSides = 4
        let centerToFirstVertex = CGVector(dx: 0, dy: 1)

        let square = RegularPolygon(center: center,
                                    numberOfSides: numberOfSides,
                                    centerToFirstVertex: centerToFirstVertex)

        let expectedVertexSet = Set([CGVector(dx: 0, dy: 1),
                                     CGVector(dx: 1, dy: 0),
                                     CGVector(dx: 0, dy: -1),
                                     CGVector(dx: -1, dy: 0)])
        let actualVertexSet = Set(square.vertices)

        // this allows the use of CGVector's isEqualsTo
        for vertex in actualVertexSet {
            XCTAssertTrue(expectedVertexSet.contains(where: { vertex.isEquals(to: $0) }))
        }
    }

    func testInit_zeroArea() {
        let center = CGVector(dx: 0, dy: 0)
        let numberOfSides = 4
        let centerToFirstVertex = CGVector(dx: 0, dy: 0)

        let square = RegularPolygon(center: center,
                                    numberOfSides: numberOfSides,
                                    centerToFirstVertex: centerToFirstVertex)

        let expectedVertexSet = Set([CGVector(dx: 0, dy: 0)])
        let actualVertexSet = Set(square.vertices)

        // this allows the use of CGVector's isEqualsTo
        for vertex in actualVertexSet {
            XCTAssertTrue(expectedVertexSet.contains(where: { vertex.isEquals(to: $0) }))
        }
    }

    func testMove() {
        let center = CGVector(dx: 0, dy: 0)
        let numberOfSides = 6
        let centerToFirstVertex = CGVector(dx: 0, dy: 1)

        var hexagon = RegularPolygon(center: center,
                                     numberOfSides: numberOfSides,
                                     centerToFirstVertex: centerToFirstVertex)

        let originalVertices = hexagon.vertices

        let translation = CGVector(dx: 50, dy: 50)
        hexagon.center += translation

        let expectedVertices = originalVertices.map({ $0 + translation })

        // this allows the use of CGVector's isEqualsTo
        XCTAssertEqual(expectedVertices, hexagon.vertices)
        for vertex in hexagon.vertices {
            XCTAssertTrue(expectedVertices.contains(where: { vertex.isEquals(to: $0) }))
        }
    }
}
