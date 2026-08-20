import Foundation
import Combine
@MainActor final class AppModel: ObservableObject {
    @Published private(set) var followUps: [FollowUp] = []; @Published private(set) var errorMessage: String?
    @Published var thresholdDays: Int { didSet { defaults.set(max(1, thresholdDays), forKey: "thresholdDays"); refresh() } }
    @Published var notificationsEnabled: Bool { didSet { defaults.set(notificationsEnabled, forKey: "notificationsEnabled"); if notificationsEnabled { Task { _ = await notifier.requestAuthorization(); await refreshNotifications() } } } }
    @Published var ignoreGroupChats: Bool { didSet { defaults.set(ignoreGroupChats, forKey: "ignoreGroupChats"); refresh() } }
    @Published var launchAtLogin: Bool { didSet { defaults.set(launchAtLogin, forKey: "launchAtLogin"); do { try LaunchAtLoginManager.setEnabled(launchAtLogin) } catch { errorMessage = "Could not change Launch at Login: \(error.localizedDescription)" } } }
    private let store: MessageStore; private let notifier: NotificationManager; private let defaults: UserDefaults; private let contactsNameResolver = ContactsNameResolver()
    private var ignoredChatIDs: Set<Int64>; private var dismissedMessageIDs: Set<Int64>; private var notifiedMessageIDs: Set<Int64>
    @Published private(set) var contactNames: [String: String] = [:]
    init(store: MessageStore = SQLiteMessageStore(), notifier: NotificationManager = NotificationManager(), defaults: UserDefaults = .standard) {
        self.store = store; self.notifier = notifier; self.defaults = defaults; thresholdDays = max(1, defaults.object(forKey: "thresholdDays") as? Int ?? 7); notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as? Bool ?? false; ignoreGroupChats = defaults.object(forKey: "ignoreGroupChats") as? Bool ?? true; launchAtLogin = defaults.object(forKey: "launchAtLogin") as? Bool ?? LaunchAtLoginManager.isEnabled
        ignoredChatIDs = Set(defaults.array(forKey: "ignoredChatIDs") as? [Int64] ?? []); dismissedMessageIDs = Set(defaults.array(forKey: "dismissedMessageIDs") as? [Int64] ?? []); notifiedMessageIDs = Set(defaults.array(forKey: "notifiedMessageIDs") as? [Int64] ?? []); refresh()
    }
    func refresh() { do { followUps = try FollowUpChecker(store: store).findFollowUps(thresholdDays: thresholdDays, ignoredChatIDs: ignoredChatIDs, dismissedMessageIDs: dismissedMessageIDs, ignoreGroupChats: ignoreGroupChats); errorMessage = nil; Task { await refreshContactNames(); await refreshNotifications() } } catch { followUps = []; errorMessage = error.localizedDescription } }
    func dismiss(_ item: FollowUp) { dismissedMessageIDs.insert(item.messageID); save(dismissedMessageIDs, "dismissedMessageIDs"); refresh() }
    func ignore(_ item: FollowUp) { ignoredChatIDs.insert(item.chatID); save(ignoredChatIDs, "ignoredChatIDs"); refresh() }
    func openInMessages(_ item: FollowUp) { MessagesLauncher.open(chatIdentifier: item.conversation.chatIdentifier) }
    func name(for item: FollowUp) -> String { contactNames[item.conversation.chatIdentifier] ?? item.name }
    func unignore(_ id: Int64) { ignoredChatIDs.remove(id); save(ignoredChatIDs, "ignoredChatIDs"); refresh() }
    var ignoredChats: [Int64] { ignoredChatIDs.sorted() }
    private func refreshNotifications() async { guard notificationsEnabled else { return }; for item in followUps where NotificationDeduplicator.shouldNotify(messageID: item.messageID, notifiedMessageIDs: notifiedMessageIDs) { if await notifier.notifyIfPermitted(for: item) { notifiedMessageIDs.insert(item.messageID); save(notifiedMessageIDs, "notifiedMessageIDs") } } }
    private func save(_ values: Set<Int64>, _ key: String) { defaults.set(Array(values), forKey: key) }
    private func refreshContactNames() async { contactNames = await contactsNameResolver.names(for: followUps.map(\.conversation.chatIdentifier)) }
}
