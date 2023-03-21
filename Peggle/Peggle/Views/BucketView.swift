/**
`BucketView` is the `UIView` for a `Bucket`.
 */

import UIKit

class BucketView: UIImageView {

    weak var delegate: GameObjectViewDelegate?

    init(bucket: Bucket,
         superView: UIView,
         assetName: String) {
        let bucketImage = UIImage(named: assetName)
        let rect = CGRect(x: 0,
                          y: 0,
                          width: bucket.width,
                          height: bucket.height)
        super.init(image: bucketImage)
        // self.backgroundColor = .black
        self.frame = rect
        superView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.contentMode = .scaleToFill
        self.layer.masksToBounds = true

        setNewConstraints(bucket: bucket)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// Move the `BucketView` to the specified `center` and adjust width and height.
    func setNewConstraints(bucket: Bucket) {
        guard let superView = self.superview else { return }
        removeAllConstraints()
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superView.leftAnchor, constant: bucket.center.dx),
            self.centerYAnchor.constraint(equalTo: superView.topAnchor, constant: bucket.center.dy - 25),
            self.widthAnchor.constraint(equalToConstant: bucket.width),
            self.heightAnchor.constraint(equalToConstant: bucket.height * 1.7)
        ])
    }

    /// Free up the `BucketView` to be moved.
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
