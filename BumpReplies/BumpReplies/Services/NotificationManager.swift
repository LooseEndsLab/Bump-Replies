import Foundation
import UserNotifications
protocol FollowUpNotifying { func notifyIfPermitted(for followUp: FollowUp) async -> Bool }
struct NotificationDeduplicator { static func shouldNotify(messageID: Int64, notifiedMessageIDs: Set<Int64>) -> Bool { !notifiedMessageIDs.contains(messageID) } }
final class NotificationManager: FollowUpNotifying {
    func requestAuthorization() async -> Bool { (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false }
    func notifyIfPermitted(for followUp: FollowUp) async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return false }
        let content = UNMutableNotificationContent(); content.title = "BumpReplies"; content.body = "\(followUp.name) has been waiting \(followUp.daysOld()) days for a reply."; content.sound = .default
        do { try await UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "BumpReplies.\(followUp.messageID)", content: content, trigger: nil)); return true } catch { return false }
    }
}
