import SwiftUI

struct MenuBarView: View {
    private enum ConversationTab: String, CaseIterable, Identifiable {
        case waitingOnThem = "Waiting"
        case waitingOnYou = "Ghosting"

        var id: Self { self }
    }

    @EnvironmentObject private var model: AppModel
    @Environment(\.openWindow) private var openWindow
    @State private var selectedTab = ConversationTab.waitingOnThem

    private var conversations: [FollowUp] {
        selectedTab == .waitingOnThem ? model.followUps : model.ghostedConversations
    }

    private var statusText: String {
        selectedTab == .waitingOnThem ? "waiting" : "awaiting your reply"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("BumpReplies").font(.headline)
                Spacer()
                Picker("Conversation type", selection: $selectedTab) {
                    ForEach(ConversationTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 200)
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
        .frame(width: 360, height: 420)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder private var content: some View {
        if let error = model.errorMessage {
            ScrollView { PermissionView(error: error) }
        } else if conversations.isEmpty {
            VStack(spacing: 6) {
                Image(systemName: "checkmark.circle").font(.title2).foregroundStyle(.secondary)
                Text(selectedTab == .waitingOnThem ? "No conversations waiting" : "No unanswered conversations")
                Text(selectedTab == .waitingOnThem ? "You’re all caught up." : "No one is waiting on your reply.").font(.caption).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(conversations) { FollowUpRow(followUp: $0, statusText: statusText) }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
    }
}
