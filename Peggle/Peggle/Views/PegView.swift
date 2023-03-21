/**
 `PegView` is the `UIview` for  a peg, with gesture recognizers for tap, long press and pan.
 When a gesture is detected, it is delegated to the `PegViewDelegate` to handle.
 */

import UIKit

class PegView: UIImageView {

    weak var delegate: GameObjectViewDelegate?

    init(center: CGPoint,
         radius: CGFloat,
         assetName: String,
         delegate: GameObjectViewDelegate? = nil,
         superView: UIView) {
        let pegImage = UIImage(named: assetName)
        super.init(image: pegImage)
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleAspectFit
        self.delegate = delegate

        if delegate != nil {
            addPegViewGestureRecognizers()
        }
        setNewConstraints(center: center, radius: radius)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func changeImage(to assetName: String) {
        let markedPegImage = UIImage(named: assetName)
        self.image = markedPegImage
    }

    func fadeOut() {
        UIView.transition(with: self,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.image = nil },
                          completion: nil)
    }

    func addPegViewGestureRecognizers() {
        self.isUserInteractionEnabled = true

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
            action: #selector(handleLongPressGesture))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))

        self.addGestureRecognizer(longPressGestureRecognizer)
        self.addGestureRecognizer(tapGestureRecognizer)
        self.addGestureRecognizer(panGestureRecognizer)
    }

    /// Move the `PegView` to the specified `center` and adjust it's radius.
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

    /// Free up the `PegView` to be moved.
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
