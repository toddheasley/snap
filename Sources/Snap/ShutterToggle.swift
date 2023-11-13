import SwiftUI

struct ShutterToggle: View {
    let diameter: CGFloat
    
    init(_ isCapturing: Binding<Bool>, diameter: CGFloat = 75.0) {
        self.diameter = diameter
        _isCapturing = isCapturing
    }
    
    @State private var isPressed: Bool = false
    @Binding private var isCapturing: Bool
    
    // MARK: View
    public var body: some View {
        ZStack {
            Circle()
                .fill(.gray.opacity(0.1))
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 4.0))
                .fill(.white)
                .padding(2.5)
            Circle()
                .fill(.white)
                .padding(isPressed ? 10.5 : 7.5)
        }
        .frame(width: diameter, height: diameter)
        .padding()
        .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isCapturing = true
                    isPressed = false
                })
    }
}

#Preview("Shutter Toggle") {
    return ShutterToggle(.constant(false))
}
