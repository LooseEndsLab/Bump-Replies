import AppKit
import SwiftUI

struct MenuBarView: View {
    private enum ConversationTab: String, CaseIterable, Identifiable {
        case waitingOnThem = "Waiting"
        case waitingOnYou = "Ghosting"

        var id: Self { self }
    }

    private enum LikelihoodFilter: String, CaseIterable, Identifiable {
        case likely = "Likely"
        case all = "All"

        var id: Self { self }
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @State private var selectedTab = ConversationTab.waitingOnThem
    @State private var likelihoodFilter = LikelihoodFilter.likely

    private var conversations: [FollowUp] {
        let items = selectedTab == .waitingOnThem ? model.followUps : model.ghostedConversations
        return likelihoodFilter == .likely ? items.filter { $0.likelihood.isLikely } : items
    }

    private var statusText: String {
        selectedTab == .waitingOnThem ? "waiting" : "awaiting your reply"
    }

    private var likelihoodSubject: String? {
        selectedTab == .waitingOnThem ? "you" : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text("BumpReplies").font(.headline)
                NativeChoiceToggle(
                    selection: $selectedTab,
                    first: .waitingOnThem,
                    firstTitle: "Waiting",
                    second: .waitingOnYou,
                    secondTitle: "Ghosting",
                    accessibilityLabel: "Conversation type"
                )
                .frame(width: 130)

                Text("Show")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NativeChoiceToggle(
                    selection: $likelihoodFilter,
                    first: .likely,
                    firstTitle: "Likely",
                    second: .all,
                    secondTitle: "All",
                    accessibilityLabel: "Follow-up likelihood"
                )
                .frame(width: 90)
            }
            .padding()

            Divider()

            content
                .frame(maxHeight: .infinity)

            Divider()

            HStack {
                Button("Refresh") { model.refresh() }
                Spacer()
                Button("Settings") { openWindow(id: "settings") }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .padding()
        }
        .frame(width: 420, height: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder private var content: some View {
        if let error = model.errorMessage {
            ScrollView { PermissionView(error: error) }
        } else if conversations.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle").font(.title2).foregroundStyle(.secondary)
                Text(likelihoodFilter == .likely ? "No likely follow-ups" : (selectedTab == .waitingOnThem ? "No conversations waiting" : "No unanswered conversations"))
                Text(likelihoodFilter == .likely ? "Use All to review every older conversation." : (selectedTab == .waitingOnThem ? "You’re all caught up." : "No one is waiting on your reply.")).font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(conversations) { FollowUpRow(followUp: $0, statusText: statusText, likelihoodSubject: likelihoodSubject) }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
    }
}

private struct NativeChoiceToggle<Value: Hashable>: NSViewRepresentable {
    @Binding var selection: Value
    let first: Value
    let firstTitle: String
    let second: Value
    let secondTitle: String
    let accessibilityLabel: String

    func makeNSView(context: Context) -> NSSegmentedControl {
        let control = NSSegmentedControl(labels: [firstTitle, secondTitle], trackingMode: .selectOne, target: context.coordinator, action: #selector(Coordinator.toggleSelection))
        control.segmentStyle = .rounded
        control.controlSize = .small
        control.setAccessibilityLabel(accessibilityLabel)
        return control
    }

    func updateNSView(_ control: NSSegmentedControl, context: Context) {
        context.coordinator.parent = self
        control.selectedSegment = selection == first ? 0 : 1
        control.setAccessibilityValue(selection == first ? firstTitle : secondTitle)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject {
        var parent: NativeChoiceToggle

        init(parent: NativeChoiceToggle) {
            self.parent = parent
        }

        @objc func toggleSelection() {
            parent.selection = parent.selection == parent.first ? parent.second : parent.first
        }
    }
}
