#if canImport(UIKit)
import SwiftUI
import AVFoundation

public struct Camera: View {
    public typealias Quality = AVCapturePhotoOutput.QualityPrioritization
    public typealias Flash = AVCaptureDevice.FlashMode
    
    public static var quality: Quality = .balanced
    public static var flash: Flash = .off
    
    public struct Image: Equatable {
        public let fileType: UTType
        public let data: Data
        
        init(_ fileType: UTType = .image, data: Data) {
            self.fileType = fileType
            self.data = data
        }
    }
    
    public init(_ isCapturing: Binding<Bool>, image: Binding<Image?>, error: Binding<Error?> = .constant(nil)) {
        _isCapturing = isCapturing
        _image = image
        _error = error
    }
    
    @Binding private var isCapturing: Bool
    @Binding private var image: Image?
    @Binding private var error: Error?
    
    // MARK: View
    public var body: some View {
        CameraView(isCapturing: $isCapturing, image: $image, error: $error)
            .ignoresSafeArea()
    }
}

extension Camera {
    public func shutterToggle(_ alignment: Alignment = .bottom) -> some View {
        return modifier(_ShutterToggle($isCapturing, alignment: alignment))
    }
    
    private struct _ShutterToggle: ViewModifier {
        public let alignment: Alignment
        
        public init(_ isCapturing: Binding<Bool>, alignment: Alignment) {
            self.alignment = alignment
            _isCapturing = isCapturing
        }
        
        @Binding private var isCapturing: Bool
        
        // MARK: ViewModifier
        public func body(content: Content) -> some View {
            ZStack(alignment: alignment) {
                content
                ShutterToggle($isCapturing)
                    .padding()
            }
        }
    }
}
#endif
