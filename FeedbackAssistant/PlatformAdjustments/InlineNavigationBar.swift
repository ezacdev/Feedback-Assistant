import SwiftUI

extension View {
    func inlineNavigationBar() -> some View {
        #if os(macOS)
            self
        #else
            self.navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
