import Combine
import CoreData
import StoreKit
import SwiftUI
import WidgetKit

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

/// An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {

    private var saveTask: Task<Void, Error>?

    private var storeTask: Task<Void, Never>?

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentContainer

    let defaults: UserDefaults

    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    @Published var products = [Product]()

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    static let model: NSManagedObjectModel = {
        guard
            let url = Bundle.main.url(
                forResource: "Main",
                withExtension: "momd"
            )
        else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst())
            .trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(
                format: "name CONTAINS[c] %@",
                trimmedFilterText
            )
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {

        self.defaults = defaults

        container = NSPersistentContainer(
            name: "Main",
            managedObjectModel: Self.model
        )

        storeTask = Task {
            await monitorTransactions()
        }

        // for testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(
                fileURLWithPath: "/dev/null"
            )
        } else {
            let groupID = "group.com.ezacd.feedbackassistant.upa"

            if let url = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: groupID
            ) {
                container.persistentStoreDescriptions.first?.url =
                    url.appending(path: "Main.sqlite")
            }
        }

        // icloud synchronizing data between devices
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy =
            NSMergePolicy.mergeByPropertyObjectTrump

        // make sure that we watch iCloud for all changes to make
        // absolutely sure we keep our local UI in sync when a
        // remote change happens.
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                fatalError(
                    "Fatal error loading store: \(error.localizedDescription)"
                )
            }

            if let description = self?.container.persistentStoreDescriptions
                .first
            {
                if let coordinator = self?.container.persistentStoreCoordinator
                {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                        forStoreWith: description,
                        coordinator: coordinator
                    )

                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }

            #if DEBUG
                if CommandLine.arguments.contains("enable-testing") {
                    self?.deleteAll()
                }

            //                UIView.setAnimationsEnabled(false)
            #endif
        }
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        saveTask?.cancel()

        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> =
            Issue.fetchRequest()
        delete(request2)

        save()
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    // When performing a batch delete we need to make sure we read the result back
    // then merge all the changes from that result back into our live view context
    // so that the two stay in sync.
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest)
            as? NSBatchDeleteResult
        {
            let changes = [
                NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []
            ]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [container.viewContext]
            )
        }
    }

    // icloud synchronizing data between devices
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }

    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    /// Runs a fetch request with various predicates that filter the user's issues based
    /// on tag, title and content text, search tokens, priority, and completion status.
    /// - Returns: An array of all matching issues.
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all

        // Collect all predicates that should be applied
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            // Filter issues that contain the selected tag
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            // Filter issues newer than the minimum modification date
            let datePredicate = NSPredicate(
                format: "modificationDate > %@",
                filter.minModificationDate as NSDate
            )
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            // Match search text against title or content (case-insensitive)
            let titlePredicate = NSPredicate(
                format: "title CONTAINS[c] %@",
                trimmedFilterText
            )
            let contentPredicate = NSPredicate(
                format: "content CONTAINS[c] %@",
                trimmedFilterText
            )

            // Either title OR content must match
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [
                    titlePredicate,
                    contentPredicate,
                ]
            )
            predicates.append(combinedPredicate)
        }

        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(
                    format: "priority = %d",
                    filterPriority
                )
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(
                    format: "completed = %@",
                    NSNumber(value: lookForClosed)
                )
                predicates.append(statusFilter)
            }
        }

        // Build fetch request with all predicates combined using AND
        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)
        ]

        // Fetch and sort results
        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues.sorted()
    }

    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString(
            "New issue",
            comment: "Create a new issue"
        )
        issue.creationDate = .now
        issue.priority = 1

        // If we're currently browsing a user-created tag, immediately
        // add this new issue to the tag otherwise it won't appear in
        // the list of issues they see.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }

        save()
        selectedIssue = issue
    }

    func newTag() -> Bool {
        var shouldCreate = fullVersionUnlocked

        if shouldCreate == false {
            // check how many tags we currently have
            shouldCreate = count(for: Tag.fetchRequest()) < 3
        }

        guard shouldCreate else {
            return false
        }

        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()

        return true
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    // convert spotlight id to issue object
    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard
            let id = container.persistentStoreCoordinator.managedObjectID(
                forURIRepresentation: url
            )
        else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Issue
    }

    @MainActor
    func loadIssueFromExternalTrigger(_ uniqueIdentifier: String) {
        selectedIssue = issue(with: uniqueIdentifier)
        selectedFilter = .all
    }

    func fetchRequestForTopIssues(count: Int) -> NSFetchRequest<Issue> {
        let request = Issue.fetchRequest()
        request.predicate = NSPredicate(format: "completed = false")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Issue.priority, ascending: false)
        ]

        request.fetchLimit = count
        return request
    }

    func results<T: NSManagedObject>(for fetchRequest: NSFetchRequest<T>) -> [T]
    {
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
}
