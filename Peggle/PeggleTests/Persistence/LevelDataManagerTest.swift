import XCTest
@testable import Peggle

final class LevelDataManagerTest: XCTestCase {

    var coreDataStack: CoreDataTestStack!
    var levelDataManager: LevelDataManager!
    var testLevel: Level!

    override func setUpWithError() throws {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        levelDataManager = LevelDataManager(mainContext: coreDataStack.mainContext)

        let peg = Peg(center: CGPoint(x: 1, y: 1),
                      radius: CGFloat(1),
                      type: PegType.compulsary)
        var pegs = Set<Peg>()
        pegs.insert(peg)
        let blocks = Set<RectangularBlock>()
        let area = try Area(xMin: 0, xMax: 4, yMin: 0, yMax: 4)

        testLevel = try Level(name: "testLevel", pegs: pegs, blocks: blocks, area: area)
    }

    override func tearDown() {
        coreDataStack = nil
        levelDataManager = nil
        super.tearDown()
    }

    func testSaveLevelDataAndFetchLevelData_ableToFetch() throws {
        XCTAssertNoThrow(try levelDataManager.saveLevelData(level: testLevel))
        XCTAssertNoThrow(try levelDataManager.fetchLevelData(levelName: testLevel.name))

        let levelData = try levelDataManager.fetchLevelData(levelName: testLevel.name)
        let fetchedLevel = try Level(data: levelData)
        XCTAssertEqual(fetchedLevel, testLevel)
    }

    func testSaveLevelDataAndFetchLevelData_duplicateLevelName_throwsError() throws {
        XCTAssertNoThrow(try levelDataManager.saveLevelData(level: testLevel))
        XCTAssertThrowsError(try levelDataManager.saveLevelData(level: testLevel),
                             "Saving a level with the same name should throw error.")
    }

    func testSaveLevelData_duplicateLevelNameWithOverwrite_onlyLatestCopySaved() throws {
        XCTAssertNoThrow(try levelDataManager.saveLevelData(level: testLevel))
        let newPeg = Peg(center: CGPoint(x: 3, y: 3),
                         radius: CGFloat(1),
                         type: PegType.optional)
        try testLevel.add(newPeg)
        XCTAssertNoThrow(try levelDataManager.saveLevelData(level: testLevel, overwrite: true))

        let levelData = try levelDataManager.fetchLevelData(levelName: testLevel.name)
        let fetchedLevel = try Level(data: levelData)
        XCTAssertEqual(fetchedLevel.name, testLevel.name)
        XCTAssertEqual(fetchedLevel.gameObjectSet.pegSet, testLevel.gameObjectSet.pegSet)
    }

    func testFetchLevelData_nonexistentLevel_throwsError() throws {
        XCTAssertThrowsError(try levelDataManager.fetchLevelData(levelName: "non-existent level name"),
                             "Fetching a non-existent level name should throw error.")
    }
}
