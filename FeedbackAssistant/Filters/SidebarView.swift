import SwiftUI

struct SidebarView: View {

    @StateObject private var viewModel: ViewModel

    let smartFilters: [Filter] = [.all, .recent]

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section(LocalizedStringKey("Smart Filters")) {
                ForEach(smartFilters) { filter in
                    SmartFilterRow(filter: filter)
                }
            }

            Section(LocalizedStringKey("Tags")) {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRow(
                        tag: filter.tag!, filter: filter,
                        rename: viewModel.rename,
                        delete: viewModel.delete
                    )
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .macFrame(minWidth: 220)
        .navigationTitle("Filters")
        .alert(
            LocalizedStringKey("Rename tag"),
            isPresented: $viewModel.renamingTag
        ) {
            Button(LocalizedStringKey("OK"), action: viewModel.completeRename)
            Button(LocalizedStringKey("Cancel"), role: .cancel) {}
            TextField(LocalizedStringKey("New name"), text: $viewModel.tagName)
        }
        .sheet(isPresented: $viewModel.showingAwards) {
            AwardsView()
        }
        .toolbar {
            SidebarViewToolbar(showingAwards: $viewModel.showingAwards)
        }
    }
}

#Preview {
    SidebarView(dataController: .preview)
}
