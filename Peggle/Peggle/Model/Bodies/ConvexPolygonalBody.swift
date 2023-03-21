/**
 A `ConvexPolygonalBody` represents a `Body` with the shape of a `ConvexPolygon`.
 */

protocol ConvexPolygonalBody: Body {
    var internalShape: ConvexPolygon { get set }
}
