/**
 The `BallType` enumeration contains all the types of `Ball`s that can be used in the game.
 */

enum BallType: Equatable {
    case regular

    static let ballTypeToAssetNameMap = [regular: "ball"]
}
