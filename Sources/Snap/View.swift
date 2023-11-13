#if canImport(UIKit)
import SwiftUI

extension View {
    public func sheet(_ isPresented: Binding<Bool>, @ViewBuilder camera: @escaping () -> Camera) -> some View {
        return sheet(isPresented: isPresented) {
            ZStack(alignment: .top) {
                camera()
                    .shutterToggle()
                CloseHandle(isPresented)
            }
            .background(.black)
        }
    }
    
    public func fullScreenCover(_ isPresented: Binding<Bool>, @ViewBuilder camera: @escaping () -> Camera) -> some View {
        return fullScreenCover(isPresented: isPresented) {
            ZStack(alignment: .topTrailing) {
                camera()
                    .shutterToggle()
                CloseButton(isPresented)
            }
            .background(.black)
        }
    }
    
    public func imagePicker(_ isPresented: Binding<Bool>, source: ImagePicker.Source = .camera, image: Binding<Camera.Image?>, error: Binding<Error?> = .constant(nil)) -> some View {
        return fullScreenCover(isPresented: isPresented) {
            ImagePicker(source, image: image, error: error)
                .background(.black)
        }
    }
    
    public func disableIdleTimer(_ timeout: TimeInterval = 300.0) -> some View {
        modifier(DisableIdleTimer(timeout))
    }
}
#endif
