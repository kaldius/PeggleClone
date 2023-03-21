/**
 Contains all the logic for adding, moving and removing `CannonView`s.
 */

import UIKit

struct CannonViewRenderer {
    let superView: UIView

    var cannonToCannonView: [Cannon: CannonView]

    init(superView: UIView) {
        self.superView = superView
        self.cannonToCannonView = [:]
    }

    mutating func addCannonView(forCannon cannon: Cannon) throws {
        let newCannonView = try addToSuperView(cannon: cannon)
        cannonToCannonView[cannon] = newCannonView
    }

    mutating func removeCannonView(cannon: Cannon) {
        let cannonViewToRemove = cannonToCannonView.removeValue(forKey: cannon)
        cannonViewToRemove?.removeFromSuperview()
    }

    mutating func moveCannonView(beforeCannon: Cannon, afterCannon: Cannon) {
        let cannonViewToChange = cannonToCannonView.removeValue(forKey: beforeCannon)
        cannonViewToChange?.setNewConstraints(radius: afterCannon.radius,
                                              position: afterCannon.position,
                                              direction: afterCannon.direction)
        if afterCannon.loaded {
            cannonViewToChange?.load()
        } else {
            cannonViewToChange?.unload()
        }
        cannonToCannonView[afterCannon] = cannonViewToChange
    }

    mutating func removeAllCannonViews() {
        superView.subviews.forEach({ if $0 is CannonView {$0.removeFromSuperview()} })
        cannonToCannonView.removeAll()
    }

    private func addToSuperView(cannon: Cannon) throws -> CannonView? {
        guard let assetName = Cannon.cannonStatetoAssetNameMap["loaded"] else {
            throw PeggleError.noAssetForCannonError
        }
        return CannonView(radius: cannon.radius,
                          position: cannon.position,
                          direction: cannon.direction,
                          assetName: assetName,
                          superView: superView)
    }
}
