import SwiftUI

public struct CloseButton: View {
    public init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    @Binding private var isPresented: Bool
    
    // MARK: View
    public var body: some View {
        ZStack {
            Circle()
                .fill(.gray.opacity(0.5))
                .frame(width: 29.0, height: 29.0)
                .shadow(radius: 0.5)
            Button(action: {
                isPresented.toggle()
            }) {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white.opacity(0.67))
                    .padding()
            }
            .buttonStyle(.borderless)
        }
    }
}

#Preview("Close Button") {
    @State var isPresented: Bool = false
    return CloseButton($isPresented)
}
