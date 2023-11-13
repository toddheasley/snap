#if canImport(UIKit)
import SwiftUI

extension View {
    public func disableIdleTimer(_ timeout: TimeInterval = 300.0) -> some View {
        modifier(DisableIdleTimer(timeout))
    }
}
#endif
