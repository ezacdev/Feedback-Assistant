import StoreKit
import SwiftUI

enum LoadState {
    case loading, loaded, error
}

struct StoreView: View {

    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var loadState = LoadState.loading

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    switch loadState {
                    case .loading:
                        Text("Loading…")
                            .font(.headline)
                        ProgressView()

                    case .loaded:
                        ForEach(dataController.products) { product in
                            VStack(alignment: .leading) {
                                Text(product.displayName)
                                    .font(.title)
                                Text(product.description)

                                Button("Buy Now") {
                                    purchase(product)
                                }
                            }
                        }
                    case .error:
                        Text("Sorry, there was an error loading our store.")

                        Button("Try Again") {
                            Task {
                                await load()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
        .task {
            await load()
        }
    }

    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }

    func purchase(_ product: Product) {
        Task { @MainActor in
            try await dataController.purchase(product)
        }
    }

    func load() async {
        loadState = .loading

        do {
            try await dataController.loadProducts()

            if dataController.products.isEmpty {
                loadState = .error
            } else {
                loadState = .loaded
            }
        } catch {
            loadState = .error
        }
    }

}
