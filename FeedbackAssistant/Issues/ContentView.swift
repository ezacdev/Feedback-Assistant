import CoreData
import StoreKit
import SwiftUI

struct ContentView: View {

    #if !os(watchOS)
        @Environment(\.requestReview) var requestReview
    #endif

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
                #if os(watchOS)
                    IssueRowWatch(issue: issue)
                #else
                    IssueRow(issue: issue)
                #endif
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        #if !os(watchOS)
            .searchable(text: $viewModel.filterText, prompt: "Filter issues")
        #endif
        .toolbar {
            ContentViewToolbar()
        }
        .onAppear(perform: askForReview)
        .onOpenURL(perform: viewModel.openURL)
        .userActivity(newIssueActivity) { activity in
            #if !os(macOS)
                activity.isEligibleForPrediction = true
            #endif
            activity.title = "New Issue"
        }
        #if !os(watchOS)
            .onContinueUserActivity(newIssueActivity, perform: resumeActivity)
        #endif
    }

    func askForReview() {
        #if !os(watchOS) && !DEBUG
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
