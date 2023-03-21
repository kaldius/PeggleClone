/**
 `PeggleError` contains the errors that can be thrown in the game.
 */

import CoreGraphics

enum PeggleError: Error {

    case invalidLevelNameError(levelName: String?)
    case invalidDataError(levelName: String)
    case invalidPegDataError
    case invalidBlockDataError
    case invalidAreaDataError
    case invalidVerticesDataError
    case invalidAreaBoundsError
    case invalidPegTypeError(typeName: String?)
    case invalidGameModeError(modeName: String?)
    case duplicateLevelNameError(levelName: String)
    case levelDoesNotExistError(levelName: String)
    case unableToAddPegError(peg: Peg, level: Level)
    case unableToAddBlockError(block: RectangularBlock, level: Level)
    case unableToAddObjectError(object: any GameObject, level: Level)
    case pegTooBigForAreaError(peg: Peg, area: Area)
    case invalidBoxError(vertices: [CGVector])
    case noAssetForPegError(peg: Peg)
    case noAssetForBallError(ball: Ball)
    case noAssetForCannonError
    case negativeRadiusError
    case invalidConvexPolygonVerticesError(vertices: [CGVector])
    case invalidRectangularBlockError(vertices: [CGVector])

    var errorMsg: String {
        switch self {
        case .invalidLevelNameError(let levelName):
            return "'\(String(describing: levelName))' is an invalid level name"
        case .invalidDataError(let levelName):
            return "Persistence data for '\(levelName)' is invalid"
        case .invalidPegDataError:
            return "Peg data loaded was invalid"
        case .invalidBlockDataError:
            return "Block data loaded was invalid"
        case .invalidAreaDataError:
            return "Area data loaded was invalid"
        case .invalidVerticesDataError:
            return "Vertices data loaded was invalid"
        case .invalidAreaBoundsError:
            return "Area bounds provided to initializer are invalid"
        case .invalidPegTypeError(let typeName):
            return "'\(String(describing: typeName))' is an invalid peg type"
        case .invalidGameModeError(let modeName):
            return "'\(String(describing: modeName))' is an invalid game mode"
        case .duplicateLevelNameError(let levelName):
            return "'\(levelName)' is a duplicate name. This is not allowed"
        case .levelDoesNotExistError(let levelName):
            return "'\(levelName)' does not exist"
        case .unableToAddPegError(let peg, let level):
            return "Unable to add \(peg) into current level: \(level)"
        case .unableToAddBlockError(let block, let level):
            return "Unable to add \(block) into current level: \(level)"
        case .unableToAddObjectError(let object, let level):
            return "Unable to add \(object) into current level: \(level)"
        case .pegTooBigForAreaError(let peg, let area):
            return "\(peg) is too big to fit into \(area)"
        case .invalidBoxError(let vertices):
            return "\(vertices) are invalid vertices for a Box"
        case .noAssetForPegError(let peg):
            return "there is no asset available for \(peg)"
        case .noAssetForBallError(let ball):
            return "there is no asset available for \(ball)"
        case .noAssetForCannonError:
            return "there is no asset available for the cannon"
        case .negativeRadiusError:
            return "negative radius is not allowed"
        case .invalidConvexPolygonVerticesError(let vertices):
            return "vertices provided do not form a valid convex polygon: \(vertices)"
        case .invalidRectangularBlockError(let vertices):
            return "vertices provided do not form a valid rectangle: \(vertices)"
        }
    }
}
