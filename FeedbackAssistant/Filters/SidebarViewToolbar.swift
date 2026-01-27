import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool
    @State private var showingStore = false

    var body: some View {
        #if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label(LocalizedStringKey("ADD SAMPLES"), systemImage: "flame")
            }
        #endif

        Button(action: tryNewTag) {
            Label("Add tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore) {
            StoreView()
        }

        Button {
            showingAwards.toggle()
        } label: {
            Label(LocalizedStringKey("Show awards"), systemImage: "rosette")
        }

    }

    func tryNewTag() {
        if dataController.newTag() == false {
            showingStore = true
        }
    }

}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
