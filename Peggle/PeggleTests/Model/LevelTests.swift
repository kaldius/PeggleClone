import XCTest
@testable import Peggle

final class LevelTests: XCTestCase {

    var testLevel: Level!

    override func setUpWithError() throws {
        super.setUp()
        let name = "test level"
        let area = try Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10)
        let pegs = Set<Peg>()
        let blocks = Set<RectangularBlock>()

        testLevel = try Level(name: name, pegs: pegs, blocks: blocks, area: area)
    }

    func testInit_validSetOfPegs() throws {
        let name = "another test level"
        let area = try Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10)
        var pegs = Set<Peg>()
        for coordinate in 1...9 {
            // pegs of radius 0.5 will not overlap each other
            let newPeg = Peg(center: CGPoint(x: coordinate, y: coordinate),
                             radius: CGFloat(0.5),
                             type: PegType.compulsary)
            pegs.insert(newPeg)
        }
        let blocks = Set<RectangularBlock>()
        XCTAssertNoThrow(try Level(name: name, pegs: pegs, blocks: blocks, area: area))
    }

    func testInit_invalidSetOfPegs() throws {
        let name = "another test level"
        let area = try Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10)
        var pegs = Set<Peg>()
        for coordinate in 1...9 {
            // pegs of radius 1 will overlap each other
            let newPeg = Peg(center: CGPoint(x: coordinate, y: coordinate),
                             radius: CGFloat(1),
                             type: PegType.compulsary)
            pegs.insert(newPeg)
        }
        let blocks = Set<RectangularBlock>()
        XCTAssertThrowsError(try Level(name: name, pegs: pegs, blocks: blocks, area: area),
            "Level with overlapping pegs should not be allowed to be initalized, unableToAddPegError should be thrown")
    }

    func testAdd_validPeg_isAdded() throws {
        let validPeg = Peg(center: CGPoint(x: 5, y: 5), radius: CGFloat(2), type: PegType.compulsary)
        XCTAssertNoThrow(try testLevel.add(validPeg))

        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: validPeg))
    }

    func testAdd_invalidPeg_throwsError() throws {
        let invalidPeg = Peg(center: CGPoint(x: 11, y: 11), radius: CGFloat(2), type: PegType.compulsary)
        XCTAssertThrowsError(try testLevel.add(invalidPeg),
                             "Attempting to add invalid peg should throw unableAddPegError")
    }

    func testRemove_pegGetsRemoved() throws {
        let validPeg = Peg(center: CGPoint(x: 5, y: 5), radius: CGFloat(2), type: PegType.compulsary)
        try testLevel.add(validPeg)
        testLevel.remove(validPeg)
        XCTAssertTrue(!testLevel.gameObjectSet.hasPegs)
    }

    func testMove_validPeg_validNewCenter_getsMoved() throws {
        let newPeg = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg)

        let validPoint = CGPoint(x: 2, y: 2)
        let destinationPoint = CGPoint(x: 8, y: 8)

        let expectedNewPeg = Peg(center: destinationPoint, radius: CGFloat(1), type: PegType.compulsary)
        let pegFinalCenter = testLevel.move(objectAt: validPoint.asCGVector, to: destinationPoint.asCGVector)

        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: expectedNewPeg))
        XCTAssertEqual(pegFinalCenter, destinationPoint)
    }

    func testMove_noPegToMove_notMoved() throws {
        let newPeg = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg)

        let invalidPoint = CGPoint(x: 7, y: 7)
        let destinationPoint = CGPoint(x: 8, y: 8)

        XCTAssertNil(testLevel.move(objectAt: invalidPoint.asCGVector, to: destinationPoint.asCGVector))
        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: newPeg))
    }

    func testMove_validPeg_movedOutsideArea_movedToNearestValidCenter() throws {
        let newPeg = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg)

        let validPoint = CGPoint(x: 2, y: 2)
        let destinationPoint = CGPoint(x: 9.9, y: 9.9)
        let pegFinalCenter = testLevel.move(objectAt: validPoint.asCGVector, to: destinationPoint.asCGVector)
        let expectedFinalCenter = CGPoint(x: 9, y: 9)
        let expectedFinalPeg = Peg(center: expectedFinalCenter,
                         radius: CGFloat(1),
                         type: PegType.compulsary)

        XCTAssertEqual(pegFinalCenter, expectedFinalCenter)
        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: expectedFinalPeg))
    }

    func testMove_validPeg_overlapsWithOtherPeg_notMoved() throws {
        let newPeg1 = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        let newPeg2 = Peg(center: CGPoint(x: 6, y: 6),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg1)
        try testLevel.add(newPeg2)

        let validPoint = CGPoint(x: 2, y: 2)
        let destinationPoint = CGPoint(x: 5.5, y: 5.5)
        let pegFinalCenter = testLevel.move(objectAt: validPoint.asCGVector, to: destinationPoint.asCGVector)

        XCTAssertEqual(pegFinalCenter, validPoint)
        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: newPeg1))
        XCTAssertTrue(testLevel.gameObjectSet.contains(peg: newPeg2))
    }

    func testPegAt_pegExists_pegReturned() throws {
        let newPeg = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg)

        let validPoint = CGPoint(x: 2.1, y: 1.8)
        let extractedPeg = try XCTUnwrap(testLevel.gameObject(at: validPoint) as? Peg)
        XCTAssertEqual(extractedPeg, newPeg)
    }

    func testPegAt_pegDoesNotExist_returnsNil() throws {
        let newPeg = Peg(center: CGPoint(x: 2, y: 2),
                         radius: CGFloat(1),
                         type: PegType.compulsary)
        try testLevel.add(newPeg)

        let validPoint = CGPoint(x: 5, y: 5)
        let extractedPeg = try XCTUnwrap(testLevel.gameObject(at: validPoint) as? Peg)
        XCTAssertNil(extractedPeg)
    }
}
