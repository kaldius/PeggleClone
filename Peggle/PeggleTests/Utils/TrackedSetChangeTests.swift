import XCTest
@testable import Peggle

final class TrackedSetChangeTests: XCTestCase {

    func testInit_addition() {
        let change = TrackedSetChange(before: nil, after: 1)
        XCTAssertNil(change.before)
        XCTAssertEqual(change.after, 1)
    }

    func testInit_removal() {
        let change = TrackedSetChange(before: 5, after: nil)
        XCTAssertEqual(change.before, 5)
        XCTAssertNil(change.after)
    }

    func testInit_swap() {
        let change = TrackedSetChange(before: 5, after: 8)
        XCTAssertEqual(change.before, 5)
        XCTAssertEqual(change.after, 8)
    }

    func testIsAddition() {
        let change = TrackedSetChange(before: nil, after: 1)
        XCTAssertTrue(change.isAddition)
        XCTAssertFalse(change.isRemoval)
        XCTAssertFalse(change.isSwap)
    }

    func testIsRemoval() {
        let change = TrackedSetChange(before: 5, after: nil)
        XCTAssertFalse(change.isAddition)
        XCTAssertTrue(change.isRemoval)
        XCTAssertFalse(change.isSwap)
    }

    func testIsSwap() {
        let change = TrackedSetChange(before: 5, after: 8)
        XCTAssertFalse(change.isAddition)
        XCTAssertFalse(change.isRemoval)
        XCTAssertTrue(change.isSwap)
    }
}
