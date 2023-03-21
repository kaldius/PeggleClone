import CoreGraphics

extension CGFloat {
    func isApproximatelyEqual(to otherCGFloat: CGFloat) -> Bool {
        self.isLess(than: otherCGFloat + pow(10, -4))
        && otherCGFloat.isLess(than: self + pow(10, -4))
    }

}
