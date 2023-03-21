/**
 A `CircularBody` represents a `Body` with the shape of `Circle`.
 */

protocol CircularBody: Body {
    var internalShape: Circle { get set }
}
