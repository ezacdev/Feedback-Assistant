import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool

    var body: some View {
        #if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label(LocalizedStringKey("ADD SAMPLES"), systemImage: "flame")
            }
        #endif

        Button(action: dataController.newTag) {
            Label(LocalizedStringKey("Add tag"), systemImage: "plus")
        }

        Button {
            showingAwards.toggle()
        } label: {
            Label(LocalizedStringKey("Show awards"), systemImage: "rosette")
        }

    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
