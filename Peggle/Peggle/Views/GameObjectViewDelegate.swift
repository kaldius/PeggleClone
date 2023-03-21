/**
 A `PegViewDelegate` is able to react to a user tap, long press or pan gesture.
 */

import UIKit

protocol GameObjectViewDelegate: AnyObject {
    func userTappedGameObjectView(_ sender: UITapGestureRecognizer)
    func userLongPressedGameObjectView(_ sender: UILongPressGestureRecognizer)
    func userPannedGameObjectView(_ sender: UIPanGestureRecognizer)
}
