import SwiftUI

struct NewIssueButton: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Button(action: dataController.newIssue) {
            Label("New Issue", systemImage: "square.and.pencil")
        }
        .help("New Issue")
    }
}
