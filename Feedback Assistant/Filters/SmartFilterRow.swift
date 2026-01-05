import SwiftUI

struct SmartFilterRow: View {
    var filter: Filter

    var body: some View {
        NavigationLink(value: filter) {
            Label(
                LocalizedStringKey(filter.name),
                systemImage: filter.icon
            )
        }
    }
}
