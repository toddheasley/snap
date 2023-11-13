#if canImport(UIKit)
import SwiftUI

struct DisableIdleTimer: ViewModifier {
    
    init(_ timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    private let timeout: TimeInterval
    
    // MARK: ViewModifier
    func body(content: Content) -> some View {
        content
            .task {
                UIApplication.shared.isIdleTimerDisabled = true
                try? await Task.sleep(until: .now + .seconds(timeout), clock: .continuous)
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}
#endif
