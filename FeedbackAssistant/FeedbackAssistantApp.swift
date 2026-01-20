import CoreData
import CoreSpotlight
import SwiftUI

@main
struct FeedbackAssistantApp: App {

    @StateObject var dataController = DataController()
    @Environment(\.scenePhase) var scenePhase

    private let notificationDelegate: NotificationDelegate

    init() {
        let dc = DataController()
        _dataController = StateObject(wrappedValue: dc)

        let nd = NotificationDelegate()
        nd.dataController = dc
        notificationDelegate = nd

        UNUserNotificationCenter.current().delegate = nd
    }

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
            //            .onAppear {
            //                notificationDelegate.dataController = dataController
            //                UNUserNotificationCenter.current().delegate =
            //                    notificationDelegate
            //            }

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
