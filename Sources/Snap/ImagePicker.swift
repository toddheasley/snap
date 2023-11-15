#if canImport(UIKit)
import SwiftUI
import AVFoundation

public struct ImagePicker: UIViewControllerRepresentable {
    public typealias Source = UIImagePickerController.SourceType
    public typealias Quality = UIImagePickerController.QualityType
    public typealias FlashMode = UIImagePickerController.CameraFlashMode
    public typealias Device = UIImagePickerController.CameraDevice
    public typealias InfoKey = UIImagePickerController.InfoKey
    public typealias Handler = ([InfoKey: Any]) -> Void
    
    public enum Media: String, CaseIterable, CustomStringConvertible {
        case image = "public.image"
        case movie = "public.movie"
        
        // MARK: CustomStringConvertible
        public var description: String { rawValue }
    }
    
    public static var availableMedia: [Media] {
        return (UIImagePickerController.availableMediaTypes(for: .camera) ?? []).compactMap { Media(rawValue: $0) }
    }
    
    public static func isFlashAvailable(for device: Device) -> Bool {
        return UIImagePickerController.isFlashAvailable(for: device)
    }
    
    public let source: Source = .camera
    public let media: [Media]
    public let videoQuality: Quality
    public let flashMode: FlashMode
    public let isEditable: Bool
    
    public init(media: [Media] = [.image], videoQuality: Quality = .typeMedium, flashMode: FlashMode = .auto, isEditable: Bool = false, handler: @escaping Handler) {
        self.media = media
        self.videoQuality = videoQuality
        self.flashMode = flashMode
        self.isEditable = isEditable
        self.handler = handler
    }
    
    @Environment(\.presentationMode) private var presentationMode
    private let handler: Handler
    
    // MARK: UIViewControllerRepresentable
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // MARK: UIImagePickerControllerDelegate
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.handler(info)
            imagePickerControllerDidCancel(picker)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.mediaTypes = media.map { $0.rawValue }
        imagePickerController.videoQuality = videoQuality
        imagePickerController.cameraFlashMode = flashMode
        imagePickerController.allowsEditing = isEditable
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    public func updateUIViewController(_ controller: UIImagePickerController, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#endif
