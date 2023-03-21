/**
`BlockView` is the `UIView` for a `RectangularBlock`.
 */

import UIKit

class BlockView: UIView {

    weak var delegate: GameObjectViewDelegate?

    init(block: RectangularBlock,
         delegate: GameObjectViewDelegate? = nil,
         superView: UIView) {
        let rect = CGRect(x: 0,
                          y: 0,
                          width: block.width,
                          height: block.height)
        super.init(frame: rect)
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit
        if block.visible {
            self.backgroundColor = .black
        }
        self.delegate = delegate

        if delegate != nil {
            addBlockViewGestureRecognizers()
        }

        setNewConstraints(block: block)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func addBlockViewGestureRecognizers() {
        self.isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
            action: #selector(handleLongPressGesture))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))

        self.addGestureRecognizer(longPressGestureRecognizer)
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(panGestureRecognizer)
    }

    /// Move the `BlockView` to the specified `center` and adjust it's height and width.
    func setNewConstraints(block: RectangularBlock) {
        guard let superView = self.superview else { return }
        removeAllConstraints()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superView.leftAnchor, constant: block.center.dx),
            self.centerYAnchor.constraint(equalTo: superView.topAnchor, constant: block.center.dy),
            self.widthAnchor.constraint(equalToConstant: block.width),
            self.heightAnchor.constraint(equalToConstant: block.height)
        ])
        self.rotate(toRadians: block.angle)
    }

    /// Free up the `BlockView` to be moved.
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

    /// Rotates the view by the specified angle in radians.
    func rotate(byRadians angle: CGFloat) {
        self.transform = self.transform.rotated(by: angle)
    }

    func rotate(toRadians angle: CGFloat) {
        let currRotationAngle = getRotateAngle()
        self.transform = self.transform.rotated(by: -currRotationAngle)
        self.transform = self.transform.rotated(by: angle)
    }

    func getRotateAngle() -> CGFloat {
        atan2(self.transform.b, self.transform.a)
    }

    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        delegate?.userTappedGameObjectView(sender)
    }

    @objc func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        delegate?.userLongPressedGameObjectView(sender)
    }

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        delegate?.userPannedGameObjectView(sender)
    }
}
