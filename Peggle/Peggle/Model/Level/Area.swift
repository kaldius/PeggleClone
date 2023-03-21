/**
 The `Area` struct represents a rectangular area in the game.
 */

import CoreData
import CoreGraphics

struct Area: Equatable {
    static let DEFAULTXMIN: Double = 0
    static let DEFAULTXMAX: Double = 1024
    static let DEFAULTYMIN: Double = 0
    static let DEFAULTYMAX: Double = 1196
    var xMin: Double
    var xMax: Double
    var yMin: Double
    var yMax: Double

    init(xMin: Double = DEFAULTXMIN, xMax: Double = DEFAULTXMAX,
         yMin: Double = DEFAULTYMIN, yMax: Double = DEFAULTYMAX) throws {
        guard xMin <= xMax && yMin <= yMax else {
            throw PeggleError.invalidAreaBoundsError
        }
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }

    func encloses(_ point: CGPoint) -> Bool {
        return point.x >= xMin
            && point.x <= xMax
            && point.y >= yMin
            && point.y <= yMax
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        xMax *= scaleFactor
        yMax *= scaleFactor
    }
}

// MARK: +ToDataAble
extension Area: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let areaData = AreaData(context: context)
        areaData.xMin = xMin
        areaData.xMax = xMax
        areaData.yMin = yMin
        areaData.yMax = yMax
        return areaData as NSManagedObject
    }
}

// MARK: +FromDataAble
extension Area: FromDataAble {
    init(data: AreaData) {
        self.xMin = data.xMin
        self.xMax = data.xMax
        self.yMin = data.yMin
        self.yMax = data.yMax
    }
}
