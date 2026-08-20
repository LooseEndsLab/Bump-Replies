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
                Picker("Conversation type", selection: $selectedTab) {
                    ForEach(ConversationTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 130)

                Text("Show")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Follow-up likelihood", selection: $likelihoodFilter) {
                    ForEach(LikelihoodFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
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
