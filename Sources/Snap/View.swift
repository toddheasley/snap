#if canImport(UIKit)
import SwiftUI

extension View {
    public func disableIdleTimer(_ timeout: TimeInterval = 300.0) -> some View {
        modifier(DisableIdleTimer(timeout))
    }
    
    public func imagePicker(_ isPresented: Binding<Bool>, image: Binding<Camera.Image?>, error: Binding<Error?> = .constant(nil)) -> some View {
        return fullScreenCover(isPresented: isPresented) {
            ImagePicker(image: image, error: error)
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
