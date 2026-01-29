import SwiftUI

struct UserFilterRow: View {
    var filter: Filter
    @ObservedObject var tag: Tag
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(tag.tagActiveIssues.count)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label(
                            LocalizedStringKey("Rename"),
                            systemImage: "pencil"
                        )
                    }

                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint(
                    "\(filter.activeIssuesCount) issues"
                )
        }
    }
}
