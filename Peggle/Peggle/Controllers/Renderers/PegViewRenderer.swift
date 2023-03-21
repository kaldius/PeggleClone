/**
 Contains all the logic for adding, moving and removing `PegView`s.
 */

import UIKit

struct PegViewRenderer {
    let superView: UIView
    let pegViews: [PegView]
    let pegViewDelegate: GameObjectViewDelegate?

    var pegToPegViewMap: [Peg: PegView]

    init(superView: UIView, delegate: GameObjectViewDelegate? = nil) {
        self.superView = superView
        self.pegViews = []
        self.pegViewDelegate = delegate
        self.pegToPegViewMap = [:]
    }

    mutating func addPegView(forPeg peg: Peg) throws {
        let newPegView = try addToSuperView(peg: peg)
        pegToPegViewMap[peg] = newPegView
    }

    mutating func removePegView(forPeg peg: Peg) {
        let pegViewToRemove = pegToPegViewMap.removeValue(forKey: peg)
        pegViewToRemove?.removeFromSuperview()
    }

    /// Fades out the `PegView` for the specified `Peg`.
    mutating func fadeOutPegView(forPeg peg: Peg) {
        let pegViewToRemove = pegToPegViewMap.removeValue(forKey: peg)
        cleanUpFadedPegViews()
        pegViewToRemove?.fadeOut()
    }

    mutating func movePegView(fromPeg oldPeg: Peg, toPeg newPeg: Peg) {
        let pegViewToChange = pegToPegViewMap.removeValue(forKey: oldPeg)
        pegViewToChange?.setNewConstraints(center: newPeg.center.asCGPoint, radius: newPeg.radius)
        pegToPegViewMap[newPeg] = pegViewToChange
    }

    mutating func markPegViewAsHit(forPeg peg: Peg) throws {
        let pegViewToMark = pegToPegViewMap.removeValue(forKey: peg)
        guard let assetName = PegType.pegTypeToHitAssetNameMap[peg.type] else {
            throw PeggleError.noAssetForPegError(peg: peg)
        }
        pegViewToMark?.changeImage(to: assetName)
        pegToPegViewMap[peg] = pegViewToMark
    }

    mutating func removeAllPegViews() {
        superView.subviews.forEach({ if $0 is PegView {$0.removeFromSuperview()} })
        pegToPegViewMap.removeAll()
    }

    private func cleanUpFadedPegViews() {
        for (_, pegView) in pegToPegViewMap where pegView.image == nil {
            pegView.removeFromSuperview()
        }
    }

    private func addToSuperView(peg: Peg) throws -> PegView {
        guard let assetName = PegType.pegTypeToAssetNameMap[peg.type] else {
            throw PeggleError.noAssetForPegError(peg: peg)
        }
        if let delegate = pegViewDelegate {
            return PegView(center: peg.center.asCGPoint,
                           radius: peg.radius,
                           assetName: assetName,
                           delegate: delegate,
                           superView: superView)
        } else {
            return PegView(center: peg.center.asCGPoint,
                           radius: peg.radius,
                           assetName: assetName,
                           superView: superView)
        }
    }
}
