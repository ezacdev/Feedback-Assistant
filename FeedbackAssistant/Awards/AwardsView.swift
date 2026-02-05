import SwiftUI

struct AwardsView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss

    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false
    @State private var showingAwards = false

    var awardTitle: String {
        if dataController.hasEarned(award: selectedAward) {
            return String(
                format: NSLocalizedString(
                    "Unlocked: %@",
                    comment: "Label shown when an award is unlocked"
                ),
                selectedAward.name
            )
        } else {
            return NSLocalizedString("Locked", comment: "Locked award")
        }
    }

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(color(for: award))
                                .accessibilityLabel(label(for: award))
                                .accessibilityHint(award.description)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .alert(awardTitle, isPresented: $showingAwardDetails) {
            } message: {
                Text(selectedAward.description)
            }
            .navigationTitle("Awards")
            .toolbar {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .macFrame(minWidth: 600, maxHeight: 500)
    }
}

extension AwardsView {
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award)
            ? Color(award.color) : .secondary.opacity(0.5)
    }

    func label(for award: Award) -> LocalizedStringKey {
        dataController.hasEarned(award: award)
            ? "Unlocked: \(award.name)" : "Locked"
    }

}
