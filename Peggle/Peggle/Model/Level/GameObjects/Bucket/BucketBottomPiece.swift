import CoreGraphics

struct BucketBottomPiece: BucketPiece, ConvexPolygonalBody, Hashable {
    var center: CGVector {
        internalShape.center
    }

    var internalShape: ConvexPolygon

    init(internalShape: ConvexPolygon) {
        self.internalShape = internalShape
    }

}
