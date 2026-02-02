import CoreData
import StoreKit
import SwiftUI

struct ContentView: View {

    @Environment(\.requestReview) var requestReview

    @StateObject var viewModel: ViewModel

    private let newIssueActivity = "com.ezacd.feedbackassistant.newIssue"

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) {
                issue in
                IssueRow(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $viewModel.filterText, prompt: "Filter issues")
        .toolbar {
            ContentViewToolbar()
        }
        .onAppear(perform: askForReview)
        .onOpenURL(perform: viewModel.openURL)
        .userActivity(newIssueActivity) { activity in
            activity.isEligibleForPrediction = true
            activity.title = "New Issue"
        }
        .onContinueUserActivity(newIssueActivity, perform: resumeActivity)
    }

    func askForReview() {
        #if !DEBUG
        if viewModel.shouldRequestReview {
            requestReview()
        }
        #endif
    }

    func resumeActivity(_ userActivity: NSUserActivity) {
        viewModel.dataController.newIssue()
    }
}

#Preview {
    ContentView(dataController: .preview)
}
