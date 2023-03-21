/**
 Extends `CGPoint` such that it can be turned into a `CGPointData` object for saving using CoreData.
 */

import CoreData
import CoreGraphics

extension CGPoint: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let pointData = CGPointData(context: context)
        pointData.x = x
        pointData.y = y
        return pointData as NSManagedObject
    }
}
