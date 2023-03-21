import XCTest
@testable import Peggle

final class AxisSetTests: XCTestCase {
    func testInit() {
        XCTAssertNoThrow(AxisSet())
    }

    func testInsert_newAxis() {
        var axisSet = AxisSet()
        let axis = CGVector(dx: 10, dy: 0)
        axisSet.insert(axis)

        let expectedAxis = CGVector(dx: 1, dy: 0)
        var expectedInternalSet = Set<CGVector>()
        expectedInternalSet.insert(expectedAxis)

        XCTAssertEqual(axisSet.asSet, expectedInternalSet)
    }

    func testInsert_oppositeDirectionAxis() {
        var axisSet = AxisSet()
        let axis = CGVector(dx: 10, dy: 0)
        axisSet.insert(axis)

        let oppositeDirectionAxis = CGVector(dx: -10, dy: 0)
        axisSet.insert(oppositeDirectionAxis)

        let expectedAxis = CGVector(dx: 1, dy: 0)
        var expectedInternalSet = Set<CGVector>()
        expectedInternalSet.insert(expectedAxis)

        XCTAssertEqual(axisSet.asSet, expectedInternalSet)
    }

    func testInsert_scaledAxis() {
        var axisSet = AxisSet()
        let axis = CGVector(dx: 10, dy: 0)
        axisSet.insert(axis)

        let scaledAxis = CGVector(dx: 7, dy: 0)
        axisSet.insert(scaledAxis)

        let expectedAxis = CGVector(dx: 1, dy: 0)
        var expectedInternalSet = Set<CGVector>()
        expectedInternalSet.insert(expectedAxis)

        XCTAssertEqual(axisSet.asSet, expectedInternalSet)
    }

    func testRemove_emptySet() {
        var axisSet = AxisSet()
        let axis = CGVector(dx: 10, dy: 0)

        XCTAssertNil(axisSet.remove(axis))
    }

    func testRemove_availableAxis() {
        var axisSet = AxisSet()
        let axis = CGVector(dx: 10, dy: 0)
        let unitAxis = axis.unitVector
        axisSet.insert(axis)

        XCTAssertEqual(axisSet.remove(unitAxis), unitAxis)
    }
}
