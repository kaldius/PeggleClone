/**
 The `Peg` struct represents a peg in the `Level`.
 */

import CoreData
import CoreGraphics

struct Peg: CircularBody {

    static let DEFAULTPEGRADIUS: CGFloat = 20
    static let MINPEGRADIUS: CGFloat = 20
    static let MAXPEGRADIUS: CGFloat = 200

    var internalShape: Circle
    var radius: CGFloat {
        get {
            internalShape.radius
        }
        set(newRadius) {
            internalShape.radius = newRadius
        }
    }
    let type: PegType
    var gotHit: Bool

    var leftMostPoint: CGPoint {
        CGPoint(x: center.dx - radius, y: center.dy)
    }
    var rightMostPoint: CGPoint {
        CGPoint(x: center.dx + radius, y: center.dy)
    }
    var topMostPoint: CGPoint {
        CGPoint(x: center.dx, y: center.dy - radius)
    }
    var bottomMostPoint: CGPoint {
        CGPoint(x: center.dx, y: center.dy + radius)
    }

    init(center: CGPoint, radius: CGFloat = DEFAULTPEGRADIUS,
         type: PegType, gotHit: Bool = false) {
        var correctedRadius = radius
        if radius < 0 {
            correctedRadius = Peg.DEFAULTPEGRADIUS
        }
        self.internalShape = Circle(center: center.asCGVector, radius: correctedRadius)
        self.type = type
        self.gotHit = gotHit
    }

    /// Checks if the `Peg` has any overlapping parts with `otherPeg`.
    ///
    /// - Parameters:
    ///   - otherPeg: other `Peg` to check for overlaps with.
    /// - Returns: true if there is an overlap, false otherwise.
    func overlaps(with otherPeg: Peg) -> Bool {
        let distanceBetweenCenters = CGVector.euclideanDistance(between: center, and: otherPeg.center)
        let sumOfRadii = self.radius + otherPeg.radius
        return distanceBetweenCenters < sumOfRadii
    }

    /// Checks if there is any part of the `Peg` outside of the given `Area`
    ///  - Parameters:
    ///    - area: an `Area` to check if the `Peg` is enclosed in.
    ///  - Returns: true if the peg is fully inside the `Area`, false otherwise.
    func isFullyEnclosedIn(area: Area) -> Bool {
        return area.encloses(leftMostPoint)
            && area.encloses(rightMostPoint)
            && area.encloses(topMostPoint)
            && area.encloses(bottomMostPoint)
    }
}

// MARK: +GameObject
extension Peg: GameObject {

    mutating func translate(by translation: CGVector) {
        center += translation
    }

    mutating func translate(to newCenter: CGVector) {
        center = newCenter
    }

    mutating func rotate(byRadians: CGFloat) {
        return
    }

    mutating func scale(byFactor scaleFactor: CGFloat) {
        let newRadius = radius * scaleFactor
        radius = min(max(newRadius, Peg.MINPEGRADIUS), Peg.MAXPEGRADIUS)
    }

    var center: CGVector {
        get {
            internalShape.center
        }
        set(newCenter) {
            internalShape.center = newCenter
        }
    }

    /// Checks if the `Peg`'s area covers a given `point`
    ///  - Parameters:
    ///    - point: a `CGPoint` to check if the `Peg` covers.
    ///  - Returns: true if the `Peg` covers the point, false otherwise.
    func covers(point: CGVector) -> Bool {
        let distanceToPoint = CGVector.euclideanDistance(between: center, and: point)
        return distanceToPoint < radius
    }

    mutating func adjust(to point: CGVector) {
        let newRadius = CGVector.euclideanDistance(between: center, and: point)
        radius = newRadius
    }

    mutating func scale(to point: CGVector) {
        let scaleFactor = (point - center).length / radius
        scale(byFactor: scaleFactor)
    }
}

// MARK: +ToDataAble
extension Peg: ToDataAble {
    func toData(context: NSManagedObjectContext) -> NSManagedObject {
        let pegData = PegData(context: context)
        pegData.center = center.asCGPoint.toData(context: context) as? CGPointData
        pegData.radius = radius
        pegData.type = type.toData(context: context) as? PegTypeData
        return pegData as NSManagedObject
    }
}

// MARK: +FromDataAble
extension Peg: FromDataAble {
    init(data: PegData) throws {
        guard let centerData = data.center, let type = data.type else {
            throw PeggleError.invalidPegDataError
        }
        let center = try CGPoint(data: centerData)
        self.init(center: center,
                  radius: data.radius,
                  type: try PegType(data: type))
    }
}

// MARK: +Hashable
extension Peg: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(center)
        hasher.combine(radius)
        hasher.combine(type)
    }
}

// MARK: +Equatable
extension Peg: Equatable {
    public static func == (lhs: Peg, rhs: Peg) -> Bool {
        lhs.center == rhs.center
        && lhs.radius == rhs.radius
        && lhs.type == rhs.type
    }
}

// MARK: +CircularCollidableBody
extension Peg: CircularCollidableBody {}
