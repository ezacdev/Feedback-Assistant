import CoreData
import CoreSpotlight
import SwiftUI

@main
struct FeedbackAssistantApp: App {

    @StateObject private var dataController: DataController
    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let notificationDelegate = NotificationDelegate()

    init() {
        let dc = DataController()
        _dataController = StateObject(wrappedValue: dc)
        notificationDelegate.dataController = dc

        UNUserNotificationCenter.current().delegate = notificationDelegate
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
