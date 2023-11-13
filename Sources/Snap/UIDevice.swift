#if canImport(UIKit)
import UIKit

extension UIDevice {
    var videoRotationAngle: CGFloat {
        switch orientation {
        case .landscapeRight:
            return 180.0
        case .landscapeLeft:
            return 0.0
        case .portraitUpsideDown:
            return 270.0
        default:
            return 90.0 // .portrait
        }
    }
}
#endif
