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
        if bounds.width > bounds.height {
            previewLayer.frame = CGRect(x: 0.0, y: (bounds.height - bounds.width) / 2.0, width: bounds.width, height: bounds.width)
        } else {
            previewLayer.frame = CGRect(x: (bounds.width - bounds.height) / 2.0, y: 0.0, width: bounds.height, height: bounds.height)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(previewLayer)
    }
}
#endif
