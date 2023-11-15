#if canImport(UIKit)
import SwiftUI

extension View {
    public func disableIdleTimer(_ timeout: TimeInterval = 300.0) -> some View {
        modifier(DisableIdleTimer(timeout))
    }
    
    public func imagePicker(_ isPresented: Binding<Bool>, media: [ImagePicker.Media] = [
        .image
    ], videoQuality: ImagePicker.Quality = .typeMedium, flashMode: ImagePicker.FlashMode = .off, isEditable: Bool = false, handler: @escaping ImagePicker.Handler) -> some View {
        return fullScreenCover(isPresented: isPresented) {
            ImagePicker(media: media, videoQuality: videoQuality, flashMode: flashMode, isEditable: isEditable, handler: handler)
                .background(.black)
        }
    }
    
    public func sheet(_ isPresented: Binding<Bool>, alignment: Alignment = .bottom, @ViewBuilder camera: @escaping () -> Camera) -> some View {
        return sheet(isPresented: isPresented) {
            modal(isPresented, alignment: alignment, camera: camera)
        }
    }
    
    public func fullScreenCover(_ isPresented: Binding<Bool>, alignment: Alignment = .bottom, @ViewBuilder camera: @escaping () -> Camera) -> some View {
        return fullScreenCover(isPresented: isPresented) {
            modal(isPresented, alignment: alignment, camera: camera)
                .statusBarHidden()
        }
    }
    
    private func modal(_ isPresented: Binding<Bool>, alignment: Alignment, @ViewBuilder camera: @escaping () -> Camera) -> some View {
        ZStack(alignment: .top) {
            camera()
                .shutterToggle(alignment)
                .disableIdleTimer()
            CloseHandle(isPresented)
        }
        .background(.black)
    }
}
#endif
