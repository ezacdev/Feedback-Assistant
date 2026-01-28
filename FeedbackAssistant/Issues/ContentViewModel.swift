import Combine
import Foundation

extension ContentView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        var dataController: DataController
        
        var shouldRequestReview: Bool {
            dataController.count(for: Tag.fetchRequest()) >= 5
        }

        init(dataController: DataController) {
            self.dataController = dataController
        }

        func delete(_ offsets: IndexSet) {
            let issues = dataController.issuesForSelectedFilter()

            for offset in offsets {
                let item = issues[offset]
                dataController.delete(item)
            }
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<DataController, Value>)
            -> Value
        {
            dataController[keyPath: keyPath]
        }

        subscript<Value>(
            dynamicMember keyPath: ReferenceWritableKeyPath<
                DataController, Value
            >
        ) -> Value {
            get { dataController[keyPath: keyPath] }
            set { dataController[keyPath: keyPath] = newValue }
        }

    }
}
