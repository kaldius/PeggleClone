import CoreGraphics

protocol BucketPiece: Equatable {
    var internalShape: ConvexPolygon { get set }
    var center: CGVector { get }
}

extension BucketPiece {
    mutating func translate(to location: CGVector) {
        internalShape.center = location
    }

    mutating func translate(by translation: CGVector) {
        internalShape.center += translation
    }
}
