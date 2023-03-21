import XCTest
@testable import Peggle

final class GameObjectSetTests: XCTestCase {

    var testGameObjectSet: GameObjectSet!

    override func setUp() {
        super.setUp()
        testGameObjectSet = GameObjectSet()
    }

    override func tearDown() {
        testGameObjectSet = nil
        super.tearDown()
    }

    func testInit() {
        let gameObjectSet = GameObjectSet()

        XCTAssertFalse(gameObjectSet.hasPegs)
    }

    func testInsertPeg() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)

        XCTAssertTrue(testGameObjectSet.contains(peg: pegToInsertA))
        XCTAssertTrue(testGameObjectSet.contains(peg: pegToInsertB))
    }

    func testRemovePeg() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)
        testGameObjectSet.remove(peg: pegToInsertA)

        XCTAssertFalse(testGameObjectSet.contains(peg: pegToInsertA))
        XCTAssertTrue(testGameObjectSet.contains(peg: pegToInsertB))
    }

    func testSwapPeg() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)
        let pegToInsertC = Peg(center: CGPoint(x: 15, y: 15), type: .optional)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)
        testGameObjectSet.swap(toRemove: pegToInsertA, toAdd: pegToInsertC)

        XCTAssertFalse(testGameObjectSet.contains(peg: pegToInsertA))
        XCTAssertTrue(testGameObjectSet.contains(peg: pegToInsertB))
        XCTAssertTrue(testGameObjectSet.contains(peg: pegToInsertC))
    }

    func testRemoveAllPegs() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)
        let pegToInsertC = Peg(center: CGPoint(x: 15, y: 15), type: .optional)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)
        testGameObjectSet.insert(peg: pegToInsertC)

        testGameObjectSet.removeAllPegs()

        XCTAssertFalse(testGameObjectSet.hasPegs)
    }

    func testFirstPegWhere() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)
        let pegToInsertC = Peg(center: CGPoint(x: 15, y: 15), type: .optional)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)
        testGameObjectSet.insert(peg: pegToInsertC)

        let firstOptionalPeg = testGameObjectSet.firstPeg(where: { $0.type == .optional })
        XCTAssertEqual(firstOptionalPeg, pegToInsertC)
    }

    func testClearPegCache() {
        let pegToInsertA = Peg(center: CGPoint(x: 5, y: 5), type: .compulsary)
        let pegToInsertB = Peg(center: CGPoint(x: 10, y: 10), type: .compulsary)
        let pegToInsertC = Peg(center: CGPoint(x: 15, y: 15), type: .optional)

        testGameObjectSet.insert(peg: pegToInsertA)
        testGameObjectSet.insert(peg: pegToInsertB)
        testGameObjectSet.insert(peg: pegToInsertC)

        testGameObjectSet.clearPegCache()

        XCTAssertFalse(testGameObjectSet.hasPegChanges)
    }
}
