import XCTest
@testable import Peggle

final class AreaTests: XCTestCase {

    func testInit_validArea() throws {
        try XCTAssertNoThrow(Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10))
    }

    func testInit_invalidArea() throws {
        try XCTAssertThrowsError(Area(xMin: 10, xMax: 0, yMin: 0, yMax: 10))
    }

    func testEncloses_pointInArea_isEnclosed() throws {
        let area = try Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10)
        let pointInArea = CGPoint(x: 5, y: 5)
        XCTAssertTrue(area.encloses(pointInArea))
    }

    func testEncloses_pointOutsideArea_notEnclosed() throws {
        let area = try Area(xMin: 0, xMax: 10, yMin: 0, yMax: 10)
        let pointInArea = CGPoint(x: 5, y: 12)
        XCTAssertFalse(area.encloses(pointInArea))
    }
}
