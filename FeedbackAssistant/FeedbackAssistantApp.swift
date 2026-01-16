import CoreData
import CoreSpotlight
import SwiftUI

@main
struct FeedbackAssistantApp: App {

    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(dataController: dataController)
            } content: {
                ContentView(dataController: dataController)
            } detail: {
                DetailView()
            }
            .environment(
                \.managedObjectContext,
                dataController.container.viewContext
            )
            .environmentObject(dataController)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(
                CSSearchableItemActionType,
                perform: loadSpotlightItem
            )
        }
    }

    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[
            CSSearchableItemActivityIdentifier
        ] as? String {
            dataController.selectedIssue = dataController.issue(
                with: uniqueIdentifier
            )
            dataController.selectedFilter = .all
        }
    }
}
