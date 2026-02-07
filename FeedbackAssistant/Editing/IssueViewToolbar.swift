import SwiftUI

#if canImport(CoreHaptics)
    import CoreHaptics
#endif

struct IssueViewToolbar: View {

    @EnvironmentObject var dataController: DataController

    @ObservedObject var issue: Issue

    #if canImport(CoreHaptics)
        @State private var engine = try? CHHapticEngine()
    #endif

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        #if !os(watchOS)
            Menu {
                Button {
                    copyToClipboard()
                } label: {
                    Label("Copy Issue Title", systemImage: "doc.on.doc")
                }

                Button(action: toggleCompleted) {
                    Label(
                        openCloseButtonText,
                        systemImage:
                            "bubble.left.and.exclamationmark.bubble.right"
                    )
                }

                Divider()

                Section("Tags") {
                    TagsMenuView(issue: issue)
                }
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
        #endif
    }

    func toggleCompleted() {
        issue.completed.toggle()
        dataController.save()

        if issue.completed {
            playHaptic()
        }
    }

    func playHaptic() {
        #if canImport(CoreHaptics)
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
            else {
                return
            }

            do {
                try engine?.start()

                let sharpness = CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: 0
                )
                let intensity = CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: 1
                )

                let start = CHHapticParameterCurve.ControlPoint(
                    relativeTime: 0,
                    value: 1
                )
                let end = CHHapticParameterCurve.ControlPoint(
                    relativeTime: 1,
                    value: 0
                )

                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )

                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )

                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [intensity, sharpness],
                    relativeTime: 0.125,
                    duration: 1
                )

                let pattern = try CHHapticPattern(
                    events: [event1, event2],
                    parameterCurves: [parameter]
                )

                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)

            } catch {
                // playing haptics didn't work, but that's okay
            }
        #endif
    }

    func copyToClipboard() {
        #if os(iOS)
            UIPasteboard.general.string = issue.title
        #elseif os(macOS)
            NSPasteboard.general.prepareForNewContents()
            NSPasteboard.general.setString(issue.issueTitle, forType: .string)
        #endif
    }
}

#Preview {
    IssueViewToolbar(issue: Issue.example)
}
