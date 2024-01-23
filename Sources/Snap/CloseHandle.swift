import SwiftUI

struct CloseHandle: View {
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    @State private var isPressed: Bool = false
    @Binding private var isPresented: Bool
    
    // MARK: View
    public var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(.secondary.opacity(isPressed ? 0.33 : 0.97))
            .frame(width: 44.0, height: 5.0)
            .padding(.vertical, 9.5)
            .padding(.horizontal)
            .background(.gray.opacity(0.001))
            .gesture(DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                        isPresented = false
                    }
                })
    }
}

#Preview {
    return CloseHandle(.constant(true))
}
