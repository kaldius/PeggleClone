import XCTest
@testable import Peggle

final class TrackedSetTests: XCTestCase {

    var testTrackedIntSet: TrackedSet<Int>!

    override func setUp() {
        super.setUp()
        testTrackedIntSet = TrackedSet<Int>(Set(1...5))
        testTrackedIntSet.clearCache()
    }

    override func tearDown() {
        testTrackedIntSet = nil
        super.tearDown()
    }

    func testInit() {
        let intSet = Set(1...10)
        let trackedIntSet = TrackedSet(intSet)

        XCTAssertEqual(trackedIntSet.asSet, intSet)
    }

    func testInsert() {
        var trackedStringSet = TrackedSet<String>()

        let stringsToInsert = ["string1", "string2"]
        var expectedChanges: [TrackedSetChange<String>] = []
        for str in stringsToInsert {
            trackedStringSet.insert(str)
            expectedChanges.append(TrackedSetChange(before: nil, after: str))
        }

        XCTAssertEqual(trackedStringSet.asSet, Set(stringsToInsert))
        for change in expectedChanges {
            XCTAssertEqual(trackedStringSet.retrieveOldestChange(), change)
        }
    }

    func testRemove_existingItem() {
        let removedItem = testTrackedIntSet.remove(3)
        let expectedChange = TrackedSetChange(before: 3, after: nil)

        XCTAssertEqual(removedItem, 3)
        XCTAssertEqual(testTrackedIntSet.retrieveOldestChange(), expectedChange)
    }

    func testRemove_nonexistentItem() {
        let removedItem = testTrackedIntSet.remove(6)

        XCTAssertNil(removedItem)
        XCTAssertNil(testTrackedIntSet.retrieveOldestChange())
    }

    func testSwap_existingItem() {
        let removedItem = testTrackedIntSet.swap(toRemove: 3, toAdd: 7)
        let expectedChange = TrackedSetChange(before: 3, after: 7)

        XCTAssertEqual(removedItem, 3)
        XCTAssertEqual(testTrackedIntSet.retrieveOldestChange(), expectedChange)
    }

    func testSwap_nonexistentItem() {
        let removedItem = testTrackedIntSet.swap(toRemove: 6, toAdd: 7)
        let expectedChange = TrackedSetChange(before: nil, after: 7)

        XCTAssertNil(removedItem)
        XCTAssertEqual(testTrackedIntSet.retrieveOldestChange(), expectedChange)
    }

    func testRemoveAll() throws {
        testTrackedIntSet.removeAll()
        var trackedChanges: [TrackedSetChange<Int>] = []
        for item in 1...5 {
            let change = TrackedSetChange(before: item, after: nil)
            trackedChanges.append(change)
        }

        while !trackedChanges.isEmpty {
            let retrievedChange = try XCTUnwrap(testTrackedIntSet.retrieveOldestChange())
            XCTAssertTrue(trackedChanges.contains(retrievedChange))
            trackedChanges.removeAll(where: { $0 == retrievedChange })
        }
    }

    func testRemoveAllWhere() throws {
        testTrackedIntSet.removeAll(where: { $0 % 2 == 0 })
        var trackedChanges: [TrackedSetChange<Int>] = []
        for item in [2, 4] {
            let change = TrackedSetChange(before: item, after: nil)
            trackedChanges.append(change)
        }

        while !trackedChanges.isEmpty {
            let retrievedChange = try XCTUnwrap(testTrackedIntSet.retrieveOldestChange())
            XCTAssertTrue(trackedChanges.contains(retrievedChange))
            trackedChanges.removeAll(where: { $0 == retrievedChange })
        }
    }

    func testRetrieveOldestChange() {
        testTrackedIntSet.remove(3)
        testTrackedIntSet.swap(toRemove: 2, toAdd: 7)

        let expectedChanges = [TrackedSetChange(before: 3, after: nil),
                               TrackedSetChange(before: 2, after: 7)]

        var index = 0
        while !testTrackedIntSet.isCacheEmpty {
            let oldestChange = testTrackedIntSet.retrieveOldestChange()
            XCTAssertEqual(oldestChange, expectedChanges[index])
            index += 1
        }
    }

    func testClearCache() {
        testTrackedIntSet.removeAll()
        testTrackedIntSet.clearCache()
        XCTAssertNil(testTrackedIntSet.retrieveOldestChange())
    }

    func testIsEmpty() {
        XCTAssertFalse(testTrackedIntSet.isEmpty)
        testTrackedIntSet.removeAll()
        XCTAssertTrue(testTrackedIntSet.isEmpty)
    }

    func testIsCacheEmpty() {
        testTrackedIntSet.clearCache()
        XCTAssertTrue(testTrackedIntSet.isCacheEmpty)
        testTrackedIntSet.removeAll()
        XCTAssertFalse(testTrackedIntSet.isCacheEmpty)
    }
}
