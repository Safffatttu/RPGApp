import UIKit

extension UIView {
  var safeYCoordinate: CGFloat {
    return 0
  }

  var isiPhoneX: Bool {
    return safeYCoordinate > 20
  }
}
