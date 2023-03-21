/**
 Any type that conforms to `FromDataAble` will be able to be initialized using its
 respective data storage class from CoreData.
 
 For example, the `Peg` struct conforms to `FromDataAble` and is able to be initialized
 using a `PegData` object.
 */

import CoreData

protocol FromDataAble {
    associatedtype PeggleDataType: NSManagedObject

    init(data: PeggleDataType) throws
}
