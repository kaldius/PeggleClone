import UIKit

struct BoxViewRenderer {
    let superView: UIView

    var boxIdToBoxViewMap: [ObjectIdentifier: BoxView]

    init(superView: UIView) {
        self.superView = superView
        self.boxIdToBoxViewMap = [:]
    }

    mutating func addBoxView(forBox box: SquareBox) {
        let newBoxView = addToSuperView(box: box)
        boxIdToBoxViewMap[box.id] = newBoxView
    }

    mutating func removeBoxView(forBoxId id: ObjectIdentifier) {
        let boxViewToRemove = boxIdToBoxViewMap.removeValue(forKey: id)
        boxViewToRemove?.removeFromSuperview()
    }

    mutating func moveBoxView(boxId id: ObjectIdentifier, toBox newBox: SquareBox) {
        let boxViewToChange = boxIdToBoxViewMap.removeValue(forKey: id)
        boxViewToChange?.setNewConstraints(box: newBox)
        boxIdToBoxViewMap[newBox.id] = boxViewToChange
    }

    mutating func removeAllBoxViews() {
        superView.subviews.forEach({ if $0 is BoxView {$0.removeFromSuperview()} })
        boxIdToBoxViewMap.removeAll()
    }

    private func addToSuperView(box: SquareBox) -> BoxView? {
        return BoxView(box: box, superView: superView)
    }
}
