#if canImport(UIKit)
import SwiftUI
import AVFoundation

public struct Camera: View {
    public typealias Quality = AVCapturePhotoOutput.QualityPrioritization
    public typealias FlashMode = AVCaptureDevice.FlashMode
    
    public struct Device {
        public typealias DeviceType = AVCaptureDevice.DeviceType
        public typealias Position = AVCaptureDevice.Position
        
        public static func `default`(_ position: Position = .back) -> Self {
            return Self([
                .builtInDualCamera,
                .builtInWideAngleCamera,
                .builtInTripleCamera,
                .builtInDualWideCamera
            ], position: position)
        }
        
        public let deviceTypes: [DeviceType]
        public let position: Position
        
        public init(_ deviceTypes: [DeviceType], position: Position = .back) {
            self.deviceTypes = deviceTypes // First available selected
            self.position = position
        }
    }
    
    public static var device: Device = .default()
    public static var quality: Quality = .balanced
    public static var flash: FlashMode = .off
    
    public struct Image: Equatable {
        public let fileType: UTType
        public let data: Data
        
        init(_ fileType: UTType = .image, data: Data) {
            self.fileType = fileType
            self.data = data
        }
    }
    
    public typealias Handler = (Image) -> Void
    
    public init(_ isCapturing: Binding<Bool>, error: Binding<Error?> = .constant(nil), handler: @escaping Handler) {
        self.handler = handler
        _isCapturing = isCapturing
        _error = error
    }
    
    @Binding private var isCapturing: Bool
    @Binding private var error: Error?
    private let handler: Handler
    
    // MARK: View
    public var body: some View {
        CameraView(isCapturing: $isCapturing, error: $error, handler: handler)
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
            }
        }
    }
}
#endif
