/**
 Extends `CGVector` such that it can be constructed from a `CGVectorData` object obtained from CoreData.
 */

import CoreData
import CoreGraphics

extension CGVector: FromDataAble {
    init(data: CGVectorData) throws {
        self.init(dx: data.dx, dy: data.dy)
    }
}
