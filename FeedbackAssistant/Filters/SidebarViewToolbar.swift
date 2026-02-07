import SwiftUI

struct SidebarViewToolbar: ToolbarContent {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool
    @State private var showingStore = false

    var body: some ToolbarContent {
        #if DEBUG
            ToolbarItem(placement: .automatic) {
                Button {
                    dataController.deleteAll()
                    dataController.createSampleData()
                } label: {
                    Label(
                        LocalizedStringKey("ADD SAMPLES"),
                        systemImage: "flame"
                    )
                }
            }
        #endif

        ToolbarItem(placement: .automaticOrTrailing) {
            Button(action: tryNewTag) {
                Label("Add tag", systemImage: "plus")
            }
        }

        ToolbarItem(placement: .automaticOrLeading) {
            Button {
                showingAwards.toggle()
            } label: {
                Label(LocalizedStringKey("Show awards"), systemImage: "rosette")
            }
            .sheet(isPresented: $showingStore) {
                StoreView()
            }
        }
    }

    func tryNewTag() {
        if dataController.newTag() == false {
            showingStore = true
        }
    }

}
