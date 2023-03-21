/**
 `CannonView` is the `UIView` for a cannon.
 */

import UIKit

class CannonView: UIImageView {

    init(radius: CGFloat, position: CGVector, direction: CGVector, assetName: String, superView: UIView) {
        let cannonImage = UIImage(named: assetName)
        super.init(image: cannonImage)
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit

        setNewConstraints(radius: radius, position: position, direction: direction)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Switch to loaded sprite.
    func load() {
        guard let loadedAssetName = Cannon.cannonStatetoAssetNameMap["loaded"] else { return }
        let loadedImage = UIImage(named: loadedAssetName)
        self.image = loadedImage
    }

    /// Switch to unloaded sprite.
    func unload() {
        guard let unloadedAssetName = Cannon.cannonStatetoAssetNameMap["unloaded"] else { return }
        let unloadedImage = UIImage(named: unloadedAssetName)
        self.image = unloadedImage
    }

    /// Move the `CannonView` to the specified `position` and angle it towards `direction`.
    func setNewConstraints(radius: CGFloat, position: CGVector, direction: CGVector) {
        guard let superview = self.superview else { return }
        removeAllConstraints()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.leftAnchor, constant: position.dx),
            self.centerYAnchor.constraint(equalTo: superview.topAnchor, constant: position.dy),
            self.widthAnchor.constraint(equalToConstant: radius * 2),
            self.heightAnchor.constraint(equalToConstant: radius * 2)
        ])
        let angle = direction.angleFromVertical()
        rotate(toRadians: angle)
    }

    /// Free up the `BallView` to be moved.
    func removeAllConstraints() {
        guard let superview = self.superview else { return }
        for constraint in superview.constraints {
            if let first = constraint.firstItem as? UIView, first == self {
                superview.removeConstraint(constraint)
            }
            if let second = constraint.secondItem as? UIView, second == self {
                superview.removeConstraint(constraint)
            }
        }
        self.removeConstraints(self.constraints)
    }

    private func rotate(toRadians angle: CGFloat) {
        let currRotationAngle = getRotateAngle()
        self.transform = self.transform.rotated(by: -currRotationAngle)
        self.transform = self.transform.rotated(by: angle)
    }

    private func getRotateAngle() -> CGFloat {
        atan2(self.transform.b, self.transform.a)
    }
}
