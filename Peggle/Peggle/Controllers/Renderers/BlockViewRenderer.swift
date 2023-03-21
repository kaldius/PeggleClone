/**
 Contains all the logic for adding, moving and removing `BlockView`s.
 */

import UIKit

struct BlockViewRenderer {
    let superView: UIView
    let blockViewDelegate: GameObjectViewDelegate?

    var blockToBlockViewMap: [RectangularBlock: BlockView]

    init(superView: UIView, delegate: GameObjectViewDelegate? = nil) {
        self.superView = superView
        self.blockViewDelegate = delegate
        self.blockToBlockViewMap = [:]
    }

    mutating func addBlockView(forBlock block: RectangularBlock) {
        let newBlockView = addToSuperView(block: block)
        blockToBlockViewMap[block] = newBlockView
    }

    mutating func removeBlockView(block: RectangularBlock) {
        let blockViewToRemove = blockToBlockViewMap.removeValue(forKey: block)
        blockViewToRemove?.removeFromSuperview()
    }

    mutating func moveBlockView(beforeBlock: RectangularBlock, afterBlock: RectangularBlock) {
        let blockViewToChange = blockToBlockViewMap.removeValue(forKey: beforeBlock)
        blockViewToChange?.setNewConstraints(block: afterBlock)
        blockToBlockViewMap[afterBlock] = blockViewToChange
    }

    mutating func removeAllBlockViews() {
        superView.subviews.forEach({ if $0 is BlockView {$0.removeFromSuperview()} })
        blockToBlockViewMap.removeAll()
    }

    private func addToSuperView(block: RectangularBlock) -> BlockView? {
        return BlockView(block: block, delegate: blockViewDelegate, superView: superView)
    }
}
