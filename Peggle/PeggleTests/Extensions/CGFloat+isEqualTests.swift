import XCTest
@testable import Peggle

final class CGFloatIsEqualTests: XCTestCase {
    func testIsEqual_withinRange() {
        let floatA = CGFloat(10.123452)
        let floatB = CGFloat(10.123451)

        XCTAssertTrue(floatA.isApproximatelyEqual(to: floatB))
    }

    func testIsEqual_exceededRange() {
        let floatA = CGFloat(10.12345)
        let floatB = CGFloat(10.12359)

        XCTAssertFalse(floatA.isApproximatelyEqual(to: floatB))
    }
}
