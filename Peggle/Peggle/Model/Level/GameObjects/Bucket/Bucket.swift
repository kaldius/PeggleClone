/**
 `Bucket` consists of 3 `BucketPiece`s, 2 side walls and one bottom.
 */

import CoreGraphics

struct Bucket {
    var center: CGVector {
        get {
            let centerOfParts = [leftPiece.center, rightPiece.center, bottomPiece.center]
            return CGVector.arithmeticMean(points: centerOfParts)
        }
        set(newCenter) {
            let translation = newCenter - center
            translate(by: translation)
        }
    }

    var width: CGFloat {
        (leftPiece.center - rightPiece.center).length
    }

    var height: CGFloat {
        let sideLengthA = (leftPiece.internalShape.vertices[0] - leftPiece.internalShape.vertices[1]).length
        let sideLengthB = (leftPiece.internalShape.vertices[1] - leftPiece.internalShape.vertices[2]).length
        return max(sideLengthA, sideLengthB)
    }

    var leftPiece: BucketSidePiece
    var rightPiece: BucketSidePiece
    var bottomPiece: BucketBottomPiece

    var idToPartMap: [ObjectIdentifier: any BucketPiece]

    init(leftPiece: BucketSidePiece,
         leftPieceId: ObjectIdentifier,
         rightPiece: BucketSidePiece,
         rightPieceId: ObjectIdentifier,
         bottomPiece: BucketBottomPiece,
         bottomPieceId: ObjectIdentifier) {
        self.leftPiece = leftPiece
        self.rightPiece = rightPiece
        self.bottomPiece = bottomPiece

        self.idToPartMap = [:]
        self.idToPartMap[leftPieceId] = leftPiece
        self.idToPartMap[rightPieceId] = rightPiece
        self.idToPartMap[bottomPieceId] = bottomPiece
    }

    mutating func move(by translation: CGVector) {
        leftPiece.translate(by: translation)
        rightPiece.translate(by: translation)
        bottomPiece.translate(by: translation)
        for (id, piece) in idToPartMap {
            var movedPiece = piece
            movedPiece.translate(by: translation)
            idToPartMap[id] = movedPiece
        }
    }

    mutating func movePart(withId id: ObjectIdentifier, to location: CGVector) {
        guard let partToMove = idToPartMap[id] else { return }
        var movedPart = partToMove
        movedPart.translate(to: location)
        idToPartMap[id] = movedPart
        if let movingPart = partToMove as? BucketSidePiece,
           movingPart == leftPiece,
           let partAfterMove = movedPart as? BucketSidePiece {
            leftPiece = partAfterMove
        } else if let movingPart = partToMove as? BucketSidePiece,
                  movingPart == rightPiece,
                  let partAfterMove = movedPart as? BucketSidePiece {
            rightPiece = partAfterMove
        } else if let movingPart = partToMove as? BucketBottomPiece,
                  movingPart == bottomPiece,
                  let partAfterMove = movedPart as? BucketBottomPiece {
            bottomPiece = partAfterMove
        }
    }

    func isBucketPiece(id: ObjectIdentifier) -> Bool {
        idToPartMap.keys.contains(id)
    }

    func getPieceIds() -> [ObjectIdentifier] {
        return Array(idToPartMap.keys)
    }

    func isBottomPiece(id: ObjectIdentifier) -> Bool {
        idToPartMap[id] as? BucketBottomPiece != nil
    }

}

extension Bucket {
    mutating func translate(by translation: CGVector) {
        leftPiece.internalShape.translate(by: translation)
        rightPiece.internalShape.translate(by: translation)
        bottomPiece.internalShape.translate(by: translation)
    }

    mutating func translate(to newCenter: CGVector) {
        let translation = newCenter - center
        leftPiece.internalShape.translate(by: translation)
        rightPiece.internalShape.translate(by: translation)
        bottomPiece.internalShape.translate(by: translation)
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        leftPiece.internalShape.scale(byFactor: scaleFactor)
        rightPiece.internalShape.scale(byFactor: scaleFactor)
        bottomPiece.internalShape.scale(byFactor: scaleFactor)
    }
}

extension Bucket: Equatable {
    static func == (lhs: Bucket, rhs: Bucket) -> Bool {
        lhs.leftPiece == rhs.leftPiece
        && lhs.rightPiece == rhs.rightPiece
        && lhs.bottomPiece == rhs.bottomPiece
    }
}

extension Bucket: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(leftPiece)
        hasher.combine(rightPiece)
        hasher.combine(bottomPiece)
    }
}
