#if canImport(UIKit)
import UIKit
import AVFoundation

class VideoPreview: UIView {
    let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIView
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer.connection?.videoRotationAngle = UIDevice.current.videoRotationAngle
        
        // "Scale to fill" (square video preview layer by longest edge and center; overflow gets clipped)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            previewLayer.frame = CGRect(x: 0.0, y: (bounds.height - bounds.width) / 2.0, width: bounds.width, height: bounds.width)
        default:
            previewLayer.frame = CGRect(x: (bounds.width - bounds.height) / 2.0, y: 0.0, width: bounds.height, height: bounds.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(previewLayer)
    }
}

private extension UIDevice {
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
