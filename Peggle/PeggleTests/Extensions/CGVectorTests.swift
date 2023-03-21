import XCTest
@testable import Peggle

final class CGVectorTests: XCTestCase {

    // MARK: AdditiveArithmetic
    func testPlus() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let vectorSum = vectorA + vectorB

        let expectedSum = CGVector(dx: -4, dy: 41)

        XCTAssertEqual(vectorSum, expectedSum)
    }

    func testIncrement() {
        let vectorA = CGVector(dx: 7, dy: 9)
        var vectorB = CGVector(dx: -11, dy: 32)
        vectorB += vectorA

        let expectedSum = CGVector(dx: -4, dy: 41)

        XCTAssertEqual(vectorB, expectedSum)
    }

    func testMinus() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let vectorDifference = vectorA - vectorB

        let expectedDifference = CGVector(dx: 18, dy: -23)

        XCTAssertEqual(vectorDifference, expectedDifference)
    }

    func testDeccrement() {
        let vectorA = CGVector(dx: 7, dy: 9)
        var vectorB = CGVector(dx: -11, dy: 32)
        vectorB -= vectorA

        let expectedDifference = CGVector(dx: -18, dy: 23)

        XCTAssertEqual(vectorB, expectedDifference)
    }

    func testNegate() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let negatedVectorA = -vectorA

        let expectedResult = CGVector(dx: -7, dy: -9)

        XCTAssertEqual(negatedVectorA, expectedResult)
    }

    func testMultiplyWithScalar() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let scalar = CGFloat(5)
        let multiplicationResult1 = vectorA * scalar
        let multiplicationResult2 = scalar * vectorA

        let expectedProduct = CGVector(dx: 35, dy: 45)

        XCTAssertEqual(multiplicationResult1, expectedProduct)
        XCTAssertEqual(multiplicationResult2, expectedProduct)
    }

    func testMultiplyByScalar() {
        var vectorA = CGVector(dx: 7, dy: 9)
        let scalar = CGFloat(5)
        vectorA *= scalar

        let expectedProduct = CGVector(dx: 35, dy: 45)

        XCTAssertEqual(vectorA, expectedProduct)
    }

    func testDivideByScalar() {
        let vectorA = CGVector(dx: 35, dy: 45)
        let scalar = CGFloat(5)
        let divisionResult = vectorA / scalar

        let expectedResult = CGVector(dx: 7, dy: 9)

        XCTAssertEqual(divisionResult, expectedResult)
    }

    func testLength() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let length = vectorA.length

        let expectedLength = CGFloat(sqrt(pow(7, 2) + pow(9, 2)))

        XCTAssertEqual(length, expectedLength)
    }

    func testUnitVector() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let unitVector = vectorA.unitVector

        let expectedUnitVector = CGVector(dx: 7 / vectorA.length,
                                          dy: 9 / vectorA.length)

        XCTAssertEqual(unitVector, expectedUnitVector)
    }

    func testDotProduct() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let aDotB = vectorA.dot(vectorB)

        let expectedDotProduct = CGFloat(7 * (-11) + 9 * 32)

        XCTAssertEqual(aDotB, expectedDotProduct)
    }

    func testCrossProduct() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let aCrossB = vectorA.cross(vectorB)

        let expectedCrossProduct = CGFloat(7 * 32 - 9 * (-11))

        XCTAssertEqual(aCrossB, expectedCrossProduct)
    }

    func testAbsAngle_acuteAngleAnticlockwise() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let angle = vectorA.absAngle(to: vectorB)

        let expectedAngle = CGFloat(0.9921)

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -4))
    }

    func testAbsAngle_acuteAngleClockwise() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: 11, dy: -1)
        let angle = vectorA.absAngle(to: vectorB)

        let expectedAngle = CGFloat(1.0004)

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -4))
    }

    func testAbsAngle_obtuseAngleAnticlockwise() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: -1)
        let angle = vectorA.absAngle(to: vectorB)

        let expectedAngle = CGFloat(2.3225)

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -4))
    }

    func testAbsAngle_obtuseAngleClockwise() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -1, dy: -11)
        let angle = vectorA.absAngle(to: vectorB)

        let expectedAngle = CGFloat(2.571)

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -3))
    }

    func testAngleFromVertical_clockwise() {
        let vectorA = CGVector(dx: 1, dy: 1)
        let angle = vectorA.angleFromVertical()

        let expectedAngle = -CGFloat.pi / 4

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -3))
    }

    func testAngleFromVertical_anticlockwise() {
        let vectorA = CGVector(dx: -1, dy: -1)
        let angle = vectorA.angleFromVertical()

        let expectedAngle = 3 * CGFloat.pi / 4

        XCTAssertEqual(angle, expectedAngle, accuracy: pow(10, -3))
    }

    func testLengthOfProjection() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let lengthOfProjection = CGVector.lengthOfProjection(of: vectorA, onto: vectorB)

        let expectedResult = 6.2356

        XCTAssertEqual(lengthOfProjection, expectedResult, accuracy: pow(10, -4))
    }

    func testEuclideanDistance() {
        let vectorA = CGVector(dx: 7, dy: 9)
        let vectorB = CGVector(dx: -11, dy: 32)
        let euclideanDistance = CGVector.euclideanDistance(between: vectorA, and: vectorB)

        let expectedResult = sqrt(pow(7 - (-11), 2) + pow(9 - 32, 2))

        XCTAssertEqual(euclideanDistance, expectedResult)
    }

    func testRotated() {
        let vectorA = CGVector(dx: 2, dy: 2)
        let rotatedVectorA = vectorA.rotated(byRadians: Double.pi / 4)

        let expectedResult = CGVector(dx: 0, dy: 1) * vectorA.length

        XCTAssertEqual(rotatedVectorA.dx, expectedResult.dx, accuracy: pow(10, -10))
        XCTAssertEqual(rotatedVectorA.dy, expectedResult.dy, accuracy: pow(10, -10))
    }

    func testPerpendicularUnitVector() {
        let vectorA = CGVector(dx: 2, dy: 3)
        let perpendicularUnitVector = vectorA.perpendicularUnitVector

        let expectedResult = vectorA.rotated(byRadians: Double.pi / 2).unitVector

        XCTAssertEqual(perpendicularUnitVector, expectedResult)
    }

    func testIsParallel() {
        let vectorA = CGVector(dx: 2, dy: 3)
        let vectorB = CGVector(dx: 9, dy: 13.5)
        let vectorC = CGVector(dx: -4, dy: -6)

        // not parallel to the others
        let vectorD = CGVector(dx: 1, dy: 2)

        XCTAssertTrue(vectorA.isParallel(to: vectorB))
        XCTAssertTrue(vectorA.isParallel(to: vectorC))
        XCTAssertFalse(vectorA.isParallel(to: vectorD))
    }

    func testIsPerpendicular() {
        let vectorA = CGVector(dx: 2, dy: 3)
        let vectorB = CGVector(dx: 9, dy: 13.5)
        let vectorC = CGVector(dx: -8, dy: 2)

        // perpendicular to A
        let vectorD = CGVector(dx: -3, dy: 2)

        XCTAssertFalse(vectorA.isPerpendicular(to: vectorB))
        XCTAssertFalse(vectorA.isPerpendicular(to: vectorC))
        XCTAssertTrue(vectorA.isPerpendicular(to: vectorD))
    }

    func testMirrorAlong_verticalAxis() {
        let vector = CGVector(dx: 2, dy: 3)
        let axisA = CGVector(dx: 0, dy: 2)
        let axisB = CGVector(dx: 0, dy: -2)

        let expectedResultA = CGVector(dx: -2, dy: 3)
        let expectedResultB = CGVector(dx: -2, dy: 3)

        let actualResultA = vector.mirrorAlong(axis: axisA)
        let actualResultB = vector.mirrorAlong(axis: axisB)

        XCTAssertEqual(actualResultA, expectedResultA)
        XCTAssertEqual(actualResultB, expectedResultB)
    }

    func testMirrorAlong_horizontalAxis() {
        let vector = CGVector(dx: 2, dy: 3)
        let axisA = CGVector(dx: 3, dy: 0)
        let axisB = CGVector(dx: -3, dy: 0)

        let expectedResultA = CGVector(dx: 2, dy: -3)
        let expectedResultB = CGVector(dx: 2, dy: -3)

        let actualResultA = vector.mirrorAlong(axis: axisA)
        let actualResultB = vector.mirrorAlong(axis: axisB)

        XCTAssertEqual(actualResultA, expectedResultA)
        XCTAssertEqual(actualResultB, expectedResultB)
    }

    func testMirrorAlong_diagonalAxis() {
        let vector = CGVector(dx: 2, dy: 3)
        let axisA = CGVector(dx: 1, dy: 1)
        let axisB = CGVector(dx: -1, dy: -1)
        let axisC = CGVector(dx: -1, dy: 1)
        let axisD = CGVector(dx: 1, dy: -1)

        let expectedResultA = CGVector(dx: 3, dy: 2)
        let expectedResultB = CGVector(dx: 3, dy: 2)
        let expectedResultC = CGVector(dx: -3, dy: -2)
        let expectedResultD = CGVector(dx: -3, dy: -2)

        let actualResultA = vector.mirrorAlong(axis: axisA)
        let actualResultB = vector.mirrorAlong(axis: axisB)
        let actualResultC = vector.mirrorAlong(axis: axisC)
        let actualResultD = vector.mirrorAlong(axis: axisD)

        XCTAssertTrue(actualResultA.isEquals(to: expectedResultA))
        XCTAssertTrue(actualResultB.isEquals(to: expectedResultB))
        XCTAssertTrue(actualResultC.isEquals(to: expectedResultC))
        XCTAssertTrue(actualResultD.isEquals(to: expectedResultD))
    }

    func testArithmeticMean() {
        let vectorA = CGVector(dx: 2, dy: 3)
        let vectorB = CGVector(dx: -9, dy: 13.5)
        let vectorC = CGVector(dx: -8, dy: 0)
        let vectorD = CGVector(dx: 0, dy: 0)
        let vectorArray = [vectorA, vectorB, vectorC, vectorD]

        let arithmeticMean = CGVector.arithmeticMean(points: vectorArray)
        let expectedArithmeticMean = CGVector(dx: -3.75, dy: 4.125)

        XCTAssertEqual(arithmeticMean, expectedArithmeticMean)
    }
}
