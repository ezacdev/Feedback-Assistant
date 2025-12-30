import SwiftUI

struct SidebarView: View {

    @EnvironmentObject var dataController: DataController

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags:
        FetchedResults<Tag>

    @State private var tagToRename: Tag?
    @State private var renamingTag = false
    @State private var tagName = ""

    @State private var showingAwards = false

    let smartFilters: [Filter] = [.all, .recent]

    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "tag", tag: tag)
        }
    }

    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section(LocalizedStringKey("Smart Filters")) {
                ForEach(smartFilters) { filter in
                    SmartFilterRow(filter: filter)
                }
            }

            Section(LocalizedStringKey("Tags")) {
                ForEach(tagFilters) { filter in
                    UserFilterRow(
                        filter: filter,
                        rename: rename,
                        delete: delete
                    )
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Filters")
        .alert(LocalizedStringKey("Rename tag"), isPresented: $renamingTag) {
            Button(LocalizedStringKey("OK"), action: completeRename)
            Button(LocalizedStringKey("Cancel"), role: .cancel) {}
            TextField(LocalizedStringKey("New name"), text: $tagName)
        }
        .sheet(isPresented: $showingAwards) {
            AwardsView()
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $showingAwards)
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = tags[offset]
            dataController.delete(item)
        }
    }

    func delete(_ filter: Filter) {
        guard let tag = filter.tag else { return }
        dataController.delete(tag)
        dataController.save()
    }

    func rename(_ filter: Filter) {
        tagToRename = filter.tag
        tagName = filter.name
        renamingTag = true
    }

    func completeRename() {
        tagToRename?.name = tagName
        dataController.save()
    }
}

#Preview {
    SidebarView()
        .environmentObject(DataController.preview)
}
