/**
 Extends `CGVector` such that it can be turned into a `CGVectorData` object for saving using CoreData.
 */

import CoreData
import CoreGraphics

extension CGVector: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let vectorData = CGVectorData(context: context)
        vectorData.dx = dx
        vectorData.dy = dy
        return vectorData as NSManagedObject
    }
}
