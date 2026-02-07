import CoreData
import SwiftUI

#if canImport(CoreSpotlight)
    import CoreSpotlight
#endif

@main
struct FeedbackAssistantApp: App {

    @StateObject private var dataController: DataController
    @Environment(\.scenePhase) var scenePhase

    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    private let notificationDelegate = NotificationDelegate()

    init() {
        let dc = DataController()
        _dataController = StateObject(wrappedValue: dc)
        #if !os(watchOS)
            notificationDelegate.dataController = dc
        #endif

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
            #if canImport(CoreSpotlight) && !os(watchOS)
                .onContinueUserActivity(
                    CSSearchableItemActionType,
                    perform: loadSpotlightItem
                )
            #endif
        }
    }
    #if canImport(CoreSpotlight) && !os(watchOS)
        func loadSpotlightItem(
            _ userActivity: NSUserActivity
        ) {
            if let uniqueIdentifier = userActivity.userInfo?[
                CSSearchableItemActivityIdentifier
            ] as? String {
                dataController.selectedIssue = dataController.issue(
                    with: uniqueIdentifier
                )
                dataController.selectedFilter = .all
            }
        }
    #endif
}
