/**
 Contains all the logic for adding, moving and removing `BucketView`s.
 */

import UIKit

struct BucketViewRenderer {
    let superView: UIView
    let bucketViewDelegate: GameObjectViewDelegate?

    var bucketToBucketViewMap: [Bucket: BucketView]

    init(superView: UIView, delegate: GameObjectViewDelegate? = nil) {
        self.superView = superView
        self.bucketViewDelegate = delegate
        self.bucketToBucketViewMap = [:]
    }

    mutating func addBucketView(forBucket bucket: Bucket) {
        let newBucketView = addToSuperView(bucket: bucket)
        bucketToBucketViewMap[bucket] = newBucketView
    }

    mutating func removeBucketView(bucket: Bucket) {
        let bucketViewToRemove = bucketToBucketViewMap.removeValue(forKey: bucket)
        bucketViewToRemove?.removeFromSuperview()
    }

    mutating func moveBucketView(beforeBucket: Bucket, afterBucket: Bucket) {
        let bucketViewToChange = bucketToBucketViewMap.removeValue(forKey: beforeBucket)
        bucketViewToChange?.setNewConstraints(bucket: afterBucket)
        bucketToBucketViewMap[afterBucket] = bucketViewToChange
    }

    mutating func removeAllBucketViews() {
        superView.subviews.forEach({ if $0 is BucketView {$0.removeFromSuperview()} })
        bucketToBucketViewMap.removeAll()
    }

    private func addToSuperView(bucket: Bucket) -> BucketView {
        return BucketView(bucket: bucket, superView: superView, assetName: "bucket-half")
    }
}
