#if canImport(UIKit)
import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
    typealias Source = UIImagePickerController.SourceType
    
    let source: Source
    
    init(_ source: Source = .camera, image: Binding<Camera.Image?>, error: Binding<Error?> = .constant(nil)) {
        self.source = source
        _image = image
        _error = error
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @Binding private var image: Camera.Image?
    @Binding private var error: Error?
    
    // MARK: UIViewControllerRepresentable
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // MARK: UIImagePickerControllerDelegate
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image: UIImage = (info[UIImagePickerController.InfoKey.editedImage] ?? info[UIImagePickerController.InfoKey.originalImage]) as? UIImage,
                let data: Data = image.jpegData(compressionQuality: 0.75) {
                parent.image = Camera.Image(.jpeg, data: data)
            } else {
                parent.error = AVError(.decodeFailed)
            }
            imagePickerControllerDidCancel(picker)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController: UIImagePickerController = UIImagePickerController()
        imagePickerController.sourceType = source
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#endif
