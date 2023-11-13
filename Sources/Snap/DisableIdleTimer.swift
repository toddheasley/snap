#if canImport(UIKit)
import SwiftUI

struct DisableIdleTimer: ViewModifier {
    let timeout: TimeInterval
    
    init(_ timeout: TimeInterval) {
        self.timeout = timeout
    }
    
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
