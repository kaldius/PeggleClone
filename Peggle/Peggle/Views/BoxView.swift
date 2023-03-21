/**
 `BoxView` is the `UIView` for a box.
 */

import UIKit

class BoxView: UIView {

    init?(box: SquareBox, superView: UIView) {
        let rect = CGRect(x: 0,
                          y: 0,
                          width: box.height,
                          height: box.height)
        super.init(frame: rect)
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit
        self.backgroundColor = .blue

        setNewConstraints(box: box)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Move the `BoxView` to the specified `center` and adjust it's radius.
    func setNewConstraints(box: SquareBox) {
        guard let superView = self.superview else { return }
        removeAllConstraints()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superView.leftAnchor, constant: box.center.x),
            self.centerYAnchor.constraint(equalTo: superView.topAnchor, constant: box.center.y),
            self.widthAnchor.constraint(equalToConstant: box.height),
            self.heightAnchor.constraint(equalToConstant: box.height)
        ])
    }

    /// Free up the `BoxView` to be moved.
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

extension BoxView {
    func setRotation(radians: CGFloat) {
        let rotation = CGAffineTransformRotate(self.transform, radians)
        self.transform = rotation
    }
}
