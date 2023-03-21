import XCTest
@testable import Peggle

final class PegTests: XCTestCase {

    func testConstructor() {
        let center = CGPoint(x: 7.23, y: 4.8)
        let radius = CGFloat(6.3)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        XCTAssertEqual(center, peg.center.asCGPoint)
        XCTAssertEqual(radius, peg.radius)
        XCTAssertEqual(type, peg.type)
    }

    func testOverlaps_doesOverlap() {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(1)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let overlappingCenter = CGPoint(x: 2, y: 2)
        let overlappingPeg = Peg(center: overlappingCenter, radius: radius, type: type)

        XCTAssertTrue(peg.overlaps(with: overlappingPeg))
    }

    func testOverlaps_doesNotOverlap() {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(1)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let nonOverlappingCenter = CGPoint(x: 4, y: 4)
        let nonOverlappingPeg = Peg(center: nonOverlappingCenter, radius: radius, type: type)

        XCTAssertFalse(peg.overlaps(with: nonOverlappingPeg))
    }

    func testFullyEnclosedIn_insideArea() throws {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(1)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let enclosingArea = try Area(xMin: 0, xMax: 2, yMin: 0, yMax: 2)

        XCTAssertTrue(peg.isFullyEnclosedIn(area: enclosingArea))
    }

    func testFullyEnclosedIn_outsideArea() throws {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(2)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let enclosingArea = try Area(xMin: 0, xMax: 2, yMin: 0, yMax: 2)

        XCTAssertFalse(peg.isFullyEnclosedIn(area: enclosingArea))
    }

    func testCovers_pointInsidePeg() {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(2)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let pointInsidePeg = CGPoint(x: 0, y: 0)

        XCTAssertTrue(peg.covers(point: pointInsidePeg.asCGVector))
    }

    func testCovers_pointOutsidePeg() {
        let center = CGPoint(x: 1, y: 1)
        let radius = CGFloat(2)
        let type = PegType.compulsary
        let peg = Peg(center: center, radius: radius, type: type)

        let pointInsidePeg = CGPoint(x: -0.5, y: -0.5)

        XCTAssertFalse(peg.covers(point: pointInsidePeg.asCGVector))
    }
}
