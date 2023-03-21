/**
 `BallView` is the `UIView` for a ball.
 */

import UIKit

class BallView: UIImageView {

    init?(center: CGPoint, radius: CGFloat, assetName: String, superview: UIView) {
        let ballImage = UIImage(named: assetName)
        super.init(image: ballImage)
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit

        setNewConstraints(center: center, radius: radius)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Move the `BallView` to the specified `center` and adjust it's radius.
    func setNewConstraints(center: CGPoint, radius: CGFloat) {
        guard let superview = self.superview else { return }
        removeAllConstraints()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.leftAnchor, constant: center.x),
            self.centerYAnchor.constraint(equalTo: superview.topAnchor, constant: center.y),
            self.widthAnchor.constraint(equalToConstant: radius * 2),
            self.heightAnchor.constraint(equalToConstant: radius * 2)
        ])
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
}
