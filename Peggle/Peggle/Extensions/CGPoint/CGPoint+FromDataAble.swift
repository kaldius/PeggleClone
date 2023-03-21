/**
 Extends `CGPoint` such that it can be constructed from a `CGPointData` object obtained from CoreData.
 */

import CoreData
import CoreGraphics

extension CGPoint: FromDataAble {
    init(data: CGPointData) throws {
        self.init(x: data.x, y: data.y)
    }
}
