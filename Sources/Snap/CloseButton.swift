import SwiftUI

public struct CloseButton: View {
    let action: () -> Void
    
    // MARK: View
    public var body: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
                .frame(width: 29.0, height: 29.0)
            Button(action: {
                action()
            }) {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
    }
}

#Preview("Close Button") {
    CloseButton {
        
    }
    .padding()
}
