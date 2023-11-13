#if canImport(UIKit)
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    init(isCapturing: Binding<Bool>, image: Binding<Camera.Image?>, error: Binding<Error?>) {
        _isCapturing = isCapturing
        _image = image
        _error = error
    }
    
    @Binding private var isCapturing: Bool
    @Binding private var image: Camera.Image?
    @Binding private var error: Error?
    
    // MARK: UIViewControllerRepresentable
    class Coordinator: NSObject, CameraViewDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        // MARK: CameraViewDelegate
        func cameraToggledCapture(isCapturing: Bool) {
            parent.isCapturing = isCapturing
        }
        
        func cameraCapturedImage(_ image: Camera.Image) {
            parent.image = image
        }
        
        func cameraFailed(error: Error) {
            parent.error = error
        }
    }
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ controller: CameraViewController, context: Context) {
        if isCapturing != controller.isCapturing {
            controller.capture()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#endif
