import CoreGraphics

extension PeggleGame {
    func createAllBoundingBodies(area: Area) -> [any PhysicsBody] {
        let topLeft = CGVector(dx: area.xMin, dy: area.yMin)
        let topRight = CGVector(dx: area.xMax, dy: area.yMin)
        let bottomLeft = CGVector(dx: area.xMin, dy: area.yMax)
        let bottomRight = CGVector(dx: area.xMax, dy: area.yMax)

        let additionalVerticalBuffer = CGVector(dx: 0, dy: 100)

        let leftBoundBody = createVerticalBoundingBody(point1: topLeft - additionalVerticalBuffer,
                                                       point2: bottomLeft + additionalVerticalBuffer,
                                                       directionPositive: false)
        let rightBoundBody = createVerticalBoundingBody(point1: topRight - additionalVerticalBuffer,
                                                        point2: bottomRight + additionalVerticalBuffer,
                                                        directionPositive: true)
        let topBoundBody = createHorizontalBoundingBody(point1: topLeft,
                                                        point2: topRight,
                                                        directionPositive: false)
        return [leftBoundBody, rightBoundBody, topBoundBody]
    }

    private func createHorizontalBoundingBody(point1: CGVector,
                                              point2: CGVector,
                                              directionPositive: Bool) -> RegularPolygonalPhysicsBody {
        let centerXCoordinate = (point1.dx + point2.dx) / 2
        let distanceToCenter = abs((point1.dx - point2.dx) / 2)
        let centerYCoordinate: CGFloat
        if directionPositive {
            centerYCoordinate = point1.dy + distanceToCenter
        } else {
            centerYCoordinate = point1.dy - distanceToCenter
        }
        let center = CGVector(dx: centerXCoordinate, dy: centerYCoordinate)
        let centerToFirstVertex = point1 - center
        let polygon = RegularPolygon(center: center, numberOfSides: 4, centerToFirstVertex: centerToFirstVertex)
        return RegularPolygonalPhysicsBody(polygon: polygon,
                                                    mass: 10,
                                                    acceleration: CGVector.zero,
                                                    isStatic: true)
    }

    private func createVerticalBoundingBody(point1: CGVector,
                                            point2: CGVector,
                                            directionPositive: Bool) -> RegularPolygonalPhysicsBody {
        let centerYCoordinate = (point1.dy + point2.dy) / 2
        let distanceToCenter = abs((point1.dy - point2.dy) / 2)
        let centerXCoordinate: CGFloat
        if directionPositive {
            centerXCoordinate = point1.dx + distanceToCenter
        } else {
            centerXCoordinate = point1.dx - distanceToCenter
        }
        let center = CGVector(dx: centerXCoordinate, dy: centerYCoordinate)
        let centerToFirstVertex = point1 - center
        let polygon = RegularPolygon(center: center, numberOfSides: 4, centerToFirstVertex: centerToFirstVertex)
        return RegularPolygonalPhysicsBody(polygon: polygon,
                                                    mass: 10,
                                                    acceleration: CGVector.zero,
                                                    isStatic: true)
    }
}
