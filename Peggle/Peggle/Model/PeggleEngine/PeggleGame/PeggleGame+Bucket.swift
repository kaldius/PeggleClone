import CoreGraphics

extension PeggleGame {
    func createBucket(speed: CGVector = PeggleGame.DEFAULTBUCKETSPEED) throws -> Bucket {
        let leftIdAndPolygon = try makeBucketLeftPiece(speed: speed)
        let bucketLeftSide = BucketSidePiece(internalShape: leftIdAndPolygon.polygon)
        let rightIdAndPolygon = try makeBucketRightPiece(speed: speed)
        let bucketRightSide = BucketSidePiece(internalShape: rightIdAndPolygon.polygon)
        let bottomIdAndPolygon = try makeBucketBottomPiece(speed: speed)
        let bucketBottomSide = BucketBottomPiece(internalShape: bottomIdAndPolygon.polygon)
        let bucket = Bucket(leftPiece: bucketLeftSide,
                            leftPieceId: leftIdAndPolygon.id,
                            rightPiece: bucketRightSide,
                            rightPieceId: rightIdAndPolygon.id,
                            bottomPiece: bucketBottomSide,
                            bottomPieceId: bottomIdAndPolygon.id)
        return bucket
    }

    func makeBucketLeftPiece(speed: CGVector = PeggleGame.DEFAULTBUCKETSPEED,
                             width: CGFloat = PeggleGame.DEFAULTBUCKETWIDTH,
                             height: CGFloat = PeggleGame.DEFAULTBUCKETHEIGHT) throws ->
    (id: ObjectIdentifier, polygon: ConvexPolygon) {
        let leftSideShape = try ConvexPolygon(vertices: [CGVector(dx: area.xMin, dy: area.yMax - height),
                                                         CGVector(dx: area.xMin, dy: area.yMax),
                                                         CGVector(dx: area.xMin + 20, dy: area.yMax),
                                                         CGVector(dx: area.xMin + 20, dy: area.yMax - height)])
        let leftSidePhysicsBody = ConvexPolygonalPhysicsBody(polygon: leftSideShape,
                                                             isStatic: false,
                                                             isPushable: false,
                                                             isAcceleratable: false)
        leftSidePhysicsBody.moveCenter(by: speed)
        let leftPhysicsBodyId = ObjectIdentifier(leftSidePhysicsBody)
        physicsWorld.add(physicsBody: leftSidePhysicsBody)
        return (leftPhysicsBodyId, leftSideShape)
    }

    func makeBucketRightPiece(speed: CGVector = PeggleGame.DEFAULTBUCKETSPEED,
                              width: CGFloat = PeggleGame.DEFAULTBUCKETWIDTH,
                              height: CGFloat = PeggleGame.DEFAULTBUCKETHEIGHT) throws ->
    (id: ObjectIdentifier, polygon: ConvexPolygon) {
        let rightSideShape = try ConvexPolygon(vertices: [CGVector(dx: area.xMin + width, dy: area.yMax - height),
                                                          CGVector(dx: area.xMin + width, dy: area.yMax),
                                                          CGVector(dx: area.xMin + 20 + width, dy: area.yMax),
                                                          CGVector(dx: area.xMin + 20 + width, dy: area.yMax - height)
                                                         ])
        let rightSidePhysicsBody = ConvexPolygonalPhysicsBody(polygon: rightSideShape,
                                                              isStatic: false,
                                                              isPushable: false,
                                                              isAcceleratable: false)
        rightSidePhysicsBody.moveCenter(by: speed)
        let rightPhysicsBodyId = ObjectIdentifier(rightSidePhysicsBody)
        physicsWorld.add(physicsBody: rightSidePhysicsBody)
        return (rightPhysicsBodyId, rightSideShape)
    }

    func makeBucketBottomPiece(speed: CGVector = PeggleGame.DEFAULTBUCKETSPEED,
                               width: CGFloat = PeggleGame.DEFAULTBUCKETWIDTH,
                               height: CGFloat = PeggleGame.DEFAULTBUCKETHEIGHT) throws ->
    (id: ObjectIdentifier, polygon: ConvexPolygon) {
        let bottomShape = try ConvexPolygon(vertices: [CGVector(dx: area.xMin, dy: area.yMax - 5),
                                                       CGVector(dx: area.xMin, dy: area.yMax),
                                                       CGVector(dx: area.xMin + 20 + width, dy: area.yMax),
                                                       CGVector(dx: area.xMin + 20 + width, dy: area.yMax - 5)])
        let bottomPhysicsBody = ConvexPolygonalPhysicsBody(polygon: bottomShape,
                                                           isStatic: false,
                                                           isPushable: false,
                                                           isAcceleratable: false)
        bottomPhysicsBody.moveCenter(by: speed)
        let bottomPhysicsBodyId = ObjectIdentifier(bottomPhysicsBody)
        physicsWorld.add(physicsBody: bottomPhysicsBody)
        return (bottomPhysicsBodyId, bottomShape)
    }

    func wentInsideBucket(id: ObjectIdentifier) {
        removeBall(id: id)
        checkRoundEnded()
        guard let ballCount = ballsLeft else { return }
        ballsLeft = ballCount + 1
    }

    func checkBucketReachedWall(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        guard let currBucket = bucket else { return }
        if (currBucket.isBucketPiece(id: body1Id) && isWall(id: body2Id)) ||
            (currBucket.isBucketPiece(id: body2Id) && isWall(id: body1Id)) {
            reverseBucketDirection()
        }
    }

    func checkBallEnteredBucket(body1Id: ObjectIdentifier, body2Id: ObjectIdentifier) {
        guard let currBucket = bucket else { return }
        if currBucket.isBottomPiece(id: body1Id) && isBall(id: body2Id) {
            wentInsideBucket(id: body2Id)
        }
        if currBucket.isBottomPiece(id: body2Id) && isBall(id: body1Id) {
            wentInsideBucket(id: body1Id)
        }
    }
}
