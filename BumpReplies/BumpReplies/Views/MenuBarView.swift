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
                SlidingChoiceToggle(
                    selection: $selectedTab,
                    first: .waitingOnThem,
                    firstTitle: "Waiting",
                    second: .waitingOnYou,
                    secondTitle: "Ghosting"
                )
                .frame(width: 130)

                Text("Show")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                SlidingChoiceToggle(
                    selection: $likelihoodFilter,
                    first: .likely,
                    firstTitle: "Likely",
                    second: .all,
                    secondTitle: "All"
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

private struct SlidingChoiceToggle<Value: Hashable>: View {
    @Binding var selection: Value
    let first: Value
    let firstTitle: String
    let second: Value
    let secondTitle: String

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(nsColor: .controlBackgroundColor))

            GeometryReader { geometry in
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: (geometry.size.width - 4) / 2, height: geometry.size.height - 4)
                    .offset(x: selection == first ? 2 : geometry.size.width / 2)
            }
            .allowsHitTesting(false)

            HStack(spacing: 0) {
                optionButton(title: firstTitle, value: first)
                optionButton(title: secondTitle, value: second)
            }
        }
        .frame(height: 28)
        .animation(.easeInOut(duration: 0.18), value: selection)
        .accessibilityElement(children: .contain)
    }

    private func optionButton(title: String, value: Value) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selection = value
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(selection == value ? .white : .primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selection == value ? .isSelected : [])
    }
}
