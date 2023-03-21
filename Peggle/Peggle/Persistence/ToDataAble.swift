/**
 Any type that conforms to `ToDataAble` will be able to be converted to its
 respective data storage class used by CoreData.
 
 For example, the `Peg` struct conforms to `ToDataAble` and is able to be
 converted to a `PegData` object which can be easily stored using CoreData.
 */

import CoreData

protocol ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject
}
