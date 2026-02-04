import StoreKit
import SwiftUI

enum LoadState {
    case loading, loaded, error
}

struct StoreView: View {

    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var loadState = LoadState.loading
    @State private var showingPurchaseError = false

    var body: some View {

        NavigationStack {
            VStack(spacing: 20) {
                headerView
                ScrollView {
                    VStack {
                        switch loadState {
                        case .loading:
                            loadingView
                        case .loaded:
                            loadedView
                        case .error:
                            errorView
                        }
                    }
                }

                Button("Restore Purchases", action: restore)

                Button("Cancel") {
                    dismiss()
                }
                .padding(20)
            }
        }
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
        .task {
            await load()
        }
        .alert(
            "In-app purchases are disabled",
            isPresented: $showingPurchaseError
        ) {
        } message: {
            Text(
                """
                You can't purchase the premium unlock because in-app purchases are disabled on this device.

                Please ask whomever manages your device for assistance.
                """
            )
        }
    }

    private var headerView: some View {
        VStack {
            Image(decorative: "unlock")
                .resizable()
                .scaledToFit()

            Text("Upgrade Today!")
                .font(.title.bold())
                .fontDesign(.rounded)
                .foregroundStyle(.white)

            Text("Get the most out of the app")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.blue.gradient)

    }

    private var loadingView: some View {
        VStack {
            Text("Fetching offers…")
                .font(.title2.bold())
                .padding(.top, 50)
            ProgressView()
                .controlSize(.large)
        }
    }

    private var loadedView: some View {
        ForEach(dataController.products) { product in
            Button {
                purchase(product)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(product.displayName)
                            .font(.title2.bold())
                        Text(product.description)
                    }
                    .padding(20)

                    Spacer()

                    Text(product.displayPrice)
                        .font(.title)
                        .fontDesign(.rounded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    .gray.opacity(0.2),
                    in: .rect(cornerRadius: 20)
                )
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    private var errorView: some View {
        VStack {
            Text("Sorry, there was an error loading our store.")
                .padding(.top, 50)

            Button("Try Again") {
                Task {
                    await load()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }

    func purchase(_ product: Product) {
        guard AppStore.canMakePayments else {
            showingPurchaseError.toggle()
            return
        }

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

    func restore() {
        Task {
            try await AppStore.sync()
        }
    }
}

#Preview {
    StoreView()
        .environmentObject(DataController())
}
