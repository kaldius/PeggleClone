/**
 A `Body` represents an entity that has a `Shape`.
 */

protocol Body {
    associatedtype Shape
    var internalShape: Shape { get set }
}
