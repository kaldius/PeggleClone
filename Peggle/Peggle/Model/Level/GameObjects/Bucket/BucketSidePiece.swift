import CoreGraphics

struct BucketSidePiece: BucketPiece, ConvexPolygonalBody, Hashable {
    var center: CGVector {
        get {
            internalShape.center
        }
        set(newCenter) {
            internalShape.center = newCenter
        }
    }

    var internalShape: ConvexPolygon

    init(internalShape: ConvexPolygon) {
        self.internalShape = internalShape
    }
}
