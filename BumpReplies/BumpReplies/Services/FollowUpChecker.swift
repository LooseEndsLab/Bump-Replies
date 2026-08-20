import Foundation

enum ConversationSelector {
    /// Mirrors MessageStore's SQL ranking: choose the latest message overall before
    /// considering whether it was sent by the local user.
    static func latestOverall(from messages: [ConversationMessage]) -> [ConversationMessage] {
        Dictionary(grouping: messages, by: \.chatID).values.compactMap { messages in
            messages.max { left, right in
                left.date == right.date ? left.messageID < right.messageID : left.date < right.date
            }
        }
    }
}

struct FollowUpChecker {
    let store: MessageStore
    func findFollowUps(thresholdDays: Int, ignoredChatIDs: Set<Int64>, dismissedMessageIDs: Set<Int64>, ignoreGroupChats: Bool, now: Date = .now) throws -> [FollowUp] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -max(1, thresholdDays), to: now) ?? now
        return try store.latestConversationMessages().filter { $0.isFromMe && $0.date <= cutoff }.filter { !ignoreGroupChats || !$0.isGroupChat }.filter { !ignoredChatIDs.contains($0.chatID) && !dismissedMessageIDs.contains($0.messageID) }.map(FollowUp.init(conversation:)).sorted { $0.conversation.date < $1.conversation.date }
    }
}
