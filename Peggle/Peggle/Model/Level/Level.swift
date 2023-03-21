/**
 The `Level` struct represents a level in the game.
 */

import CoreData
import CoreGraphics

struct Level: Equatable {
    var name: String
    var area: Area
    var gameObjectSet: GameObjectSet
    var gameMode: GameMode

    init(name: String,
         pegs: Set<Peg>,
         blocks: Set<RectangularBlock>,
         area: Area,
         withWalls: Bool = true,
         gameMode: GameMode = .normal) throws {
        self.name = name
        self.area = area
        self.gameMode = gameMode
        self.gameObjectSet = GameObjectSet()
        if withWalls {
            try generateWalls(area: area)
        }
        for peg in pegs {
            try add(peg)
        }
        for block in blocks {
            try add(block)
        }
    }

    init(area: Area, withWalls: Bool = true, gameMode: GameMode = .normal) throws {
        let defaultName: String = "New Level"
        let emptySetOfPegs = Set<Peg>()
        let emptySetOfBlocks = Set<RectangularBlock>()
        try self.init(name: defaultName,
                      pegs: emptySetOfPegs,
                      blocks: emptySetOfBlocks,
                      area: area,
                      withWalls: withWalls,
                      gameMode: gameMode)
    }

    mutating func scale(toFit newArea: Area) {
        let scaleFactor = newArea.yMax / area.yMax
        scale(by: scaleFactor)
    }

    mutating func scale(objectAt point: CGVector, by scaleFactor: CGFloat) {
        guard var objectToScale = gameObjectSet.objectAt(point: point) else { return }
        let oldObject = objectToScale
        objectToScale.scale(byFactor: scaleFactor)
        var resolvedObject = resolveCollision(for: objectToScale, excluding: oldObject)
        for _ in 0...3 {
            resolvedObject = resolveCollision(for: resolvedObject, excluding: oldObject)
        }
        gameObjectSet.swap(toRemove: oldObject, toAdd: resolvedObject)
    }

    mutating func adjust(gameObjectAt location: CGVector, to point: CGVector) {
        guard let oldObject = gameObjectSet.objectAt(point: location),
              let objectToRotate = gameObjectSet.adjust(objectAt: location, to: point) else { return }
        var resolvedObject = resolveCollision(for: objectToRotate, excluding: oldObject)
        for _ in 0...3 {
            resolvedObject = resolveCollision(for: resolvedObject, excluding: oldObject)
        }
        gameObjectSet.swap(toRemove: oldObject, toAdd: resolvedObject)
    }

    mutating func scale(objectAt location: CGVector, to point: CGVector) {
        guard let oldObject = gameObjectSet.objectAt(point: location),
              let objectToScale = gameObjectSet.scale(objectAt: location, to: point) else { return }
        var resolvedObject = resolveCollision(for: objectToScale, excluding: oldObject)
        for _ in 0...3 {
            resolvedObject = resolveCollision(for: resolvedObject, excluding: oldObject)
        }
        gameObjectSet.swap(toRemove: oldObject, toAdd: resolvedObject)
    }

    mutating func add(_ gameObject: any GameObject) throws {
        var finalObject = gameObject
        for _ in 0..<5 {
            finalObject = resolveCollision(for: finalObject)
        }
        if hasCollision(gameObject: gameObject) {
            throw PeggleError.unableToAddObjectError(object: gameObject, level: self)
        }
        gameObjectSet.insert(finalObject)
    }

    mutating func remove(_ gameObject: any GameObject) {
        gameObjectSet.remove(gameObject)
    }

    /// Removes the old `GameObject` and adds a new one as close to `newCenter` as possible.
    ///   - Parameters:
    ///     - objectAt: original `GameObject`'s center.
    ///     - newCenter: the center point of the new `GameObject`.
    ///   - Returns: If there is a `GameObject` at `point`, returns the position of the new `GameObject`.
    ///              If not, returns `nil`.
    @discardableResult
    mutating func move(objectAt point: CGVector, to newCenter: CGVector) -> CGPoint? {
        guard var movingObject = gameObjectSet.objectAt(point: point) else { return nil }
        let oldObject = movingObject
        movingObject.translate(to: newCenter)
        var resolvedObject = resolveCollision(for: movingObject, excluding: oldObject)
        for _ in 0...3 {
            resolvedObject = resolveCollision(for: resolvedObject, excluding: oldObject)
        }
        gameObjectSet.swap(toRemove: oldObject, toAdd: resolvedObject)
        return resolvedObject.center.asCGPoint
    }

    mutating func rotate(blockAt point: CGVector, byRadians angle: CGFloat) {
        guard var rotatingObject = gameObjectSet.objectAt(point: point) else { return }
        let oldObject = rotatingObject
        rotatingObject.rotate(byRadians: angle)
        var resolvedObject = resolveCollision(for: rotatingObject, excluding: oldObject)
        for _ in 0...3 {
            resolvedObject = resolveCollision(for: resolvedObject, excluding: oldObject)
        }
        gameObjectSet.swap(toRemove: oldObject, toAdd: resolvedObject)
    }

    /// Deletes all `GameObjects`s in the `Level`.
    mutating func reset() {
        gameObjectSet.removeAll()
    }

    func gameObject(at point: CGPoint) -> (any GameObject)? {
        let objectAtPoint = gameObjectSet.objectAt(point: point.asCGVector)
        return objectAtPoint
    }

    private mutating func scale(by scaleFactor: CGFloat) {
        area.scale(byFactor: scaleFactor)
        gameObjectSet.scale(byFactor: scaleFactor)
    }

    private func resolveCollision(movingObject: any GameObject, otherObject: any GameObject) -> CGVector? {
        guard let collisionResolution = CollisionResolver.getCollisionResolution(between: movingObject,
                                                                                 and: otherObject) else {
            return nil
        }
        return collisionResolution.deltaFirstBody
    }

    private func resolveCollision(for gameObject: any GameObject,
                                  excluding excludedObject: any GameObject) -> any GameObject {
        var movingObject = gameObject
        for otherObject in gameObjectSet.allObjects where !otherObject.isEqualTo(excludedObject) {
            guard let translation = resolveCollision(movingObject: movingObject, otherObject: otherObject) else {
                continue
            }
            movingObject.translate(by: translation)
        }
        return movingObject
    }

    private func resolveCollision(for gameObject: any GameObject) -> any GameObject {
        var movingObject = gameObject
        for otherObject in gameObjectSet.allObjects {
            guard let translation = resolveCollision(movingObject: movingObject, otherObject: otherObject) else {
                continue
            }
            movingObject.translate(by: translation)
        }
        return movingObject
    }

    private func hasCollision(gameObject: any GameObject) -> Bool {
        for otherObject in gameObjectSet.allObjects where resolveCollision(movingObject: gameObject,
                                                                           otherObject: otherObject) != nil {
            return true
        }
        return false
    }

    private mutating func generateWalls(area: Area) throws {
        let topWall = try generateTopWall(area: area)
        let bottomWall = try generateBottomWall(area: area)
        let leftWall = try generateLeftWall(area: area)
        let rightWall = try generateRightWall(area: area)
        try add(topWall)
        try add(bottomWall)
        try add(leftWall)
        try add(rightWall)
    }

    private func generateTopWall(area: Area) throws -> RectangularBlock {
        let vertices = [CGVector(dx: area.xMin - 100, dy: area.yMin - 1),
                        CGVector(dx: area.xMax + 100, dy: area.yMin - 1),
                        CGVector(dx: area.xMax + 100, dy: area.yMin - 500),
                        CGVector(dx: area.xMin - 100, dy: area.yMin - 500)]
        let polygon = try ConvexPolygon(vertices: vertices)
        return try RectangularBlock(polygon: polygon, visible: false)
    }

    private func generateBottomWall(area: Area) throws -> RectangularBlock {
        let vertices = [CGVector(dx: area.xMax + 100, dy: area.yMax + 1),
                        CGVector(dx: area.xMin - 100, dy: area.yMax + 1),
                        CGVector(dx: area.xMin - 100, dy: area.yMax + 500),
                        CGVector(dx: area.xMax + 100, dy: area.yMax + 500)]
        let polygon = try ConvexPolygon(vertices: vertices)
        return try RectangularBlock(polygon: polygon, visible: false)
    }

    private func generateLeftWall(area: Area) throws -> RectangularBlock {
        let vertices = [CGVector(dx: area.xMin, dy: area.yMax),
                        CGVector(dx: area.xMin, dy: area.yMin),
                        CGVector(dx: area.xMin - 100, dy: area.yMin),
                        CGVector(dx: area.xMin - 100, dy: area.yMax)]
        let polygon = try ConvexPolygon(vertices: vertices)
        return try RectangularBlock(polygon: polygon, visible: false)
    }

    private func generateRightWall(area: Area) throws -> RectangularBlock {
        let vertices = [CGVector(dx: area.xMax, dy: area.yMin),
                        CGVector(dx: area.xMax, dy: area.yMax),
                        CGVector(dx: area.xMax + 100, dy: area.yMax),
                        CGVector(dx: area.xMax + 100, dy: area.yMin)]
        let polygon = try ConvexPolygon(vertices: vertices)
        return try RectangularBlock(polygon: polygon, visible: false)
    }

    private var objectsWithoutWalls: [any GameObject] {
        var outputArr = [any GameObject]()
        for gameObject in gameObjectSet.allObjects where area.encloses(gameObject.center.asCGPoint) {
            outputArr.append(gameObject)
        }
        return outputArr
    }
}

// MARK: +ToDataAble
extension Level: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let levelData = LevelData(context: context)
        levelData.name = name
        levelData.areaData = area.toData(context: context) as? AreaData
        levelData.gameModeData = gameMode.toData(context: context) as? GameModeData

        for gameObject in objectsWithoutWalls {
            if let peg = gameObject as? Peg, let pegData = peg.toData(context: context) as? PegData {
                levelData.addToPegDatas(pegData)
            }
            if let block = gameObject as? RectangularBlock,
                let blockData = block.toData(context: context) as? RectangularBlockData {
                levelData.addToBlockDatas(blockData)
            }
        }
        return levelData as NSManagedObject
    }
}

// MARK: +FromDataAble
extension Level: FromDataAble {
    init(data: LevelData, withWalls: Bool = true) throws {
        guard let levelName = data.name else {
            throw PeggleError.invalidLevelNameError(levelName: data.name)
        }
        guard let nsPegSet = data.pegDatas else {
            throw PeggleError.invalidPegDataError
        }
        guard let nsBlockSet = data.blockDatas else {
            throw PeggleError.invalidBlockDataError
        }
        guard let areaData = data.areaData else {
            throw PeggleError.invalidAreaDataError
        }
        guard let gameModeData = data.gameModeData else {
            throw PeggleError.invalidGameModeError(modeName: "unavailable")
        }
        self.name = levelName
        self.area = Area(data: areaData)
        self.gameMode = try GameMode(data: gameModeData)
        self.gameObjectSet = GameObjectSet()
        if withWalls {
            try generateWalls(area: area)
        }
        try loadPegsFrom(nsSet: nsPegSet)
        try loadBlocksFrom(nsSet: nsBlockSet)
    }

    init(data: LevelData) throws {
        try self.init(data: data, withWalls: true)
    }

    private mutating func loadPegsFrom(nsSet: NSSet) throws {
        let pegDatas = nsSet.compactMap({ $0 as? PegData })
        guard pegDatas.count == nsSet.count else {
            throw PeggleError.invalidPegDataError
        }
        for pegData in pegDatas {
            let peg = try Peg(data: pegData)
            try add(peg)
        }
    }

    private mutating func loadBlocksFrom(nsSet: NSSet) throws {
        let blockDatas = nsSet.compactMap({ $0 as? RectangularBlockData })
        guard blockDatas.count == nsSet.count else {
            throw PeggleError.invalidBlockDataError
        }
        for blockData in blockDatas {
            let block = try RectangularBlock(data: blockData)
            try add(block)
        }
    }
}
