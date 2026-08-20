import SwiftUI
struct SettingsView: View { @EnvironmentObject private var model: AppModel
    var body: some View { Form { Stepper("Follow up after: \(model.thresholdDays) days", value: $model.thresholdDays, in: 1...365); Toggle("Notifications", isOn: $model.notificationsEnabled); Toggle("Ignore group chats", isOn: $model.ignoreGroupChats); Toggle("Launch at Login", isOn: $model.launchAtLogin); Section("Ignored Conversations") { if model.ignoredChats.isEmpty { Text("None").foregroundStyle(.secondary) } else { ForEach(model.ignoredChats, id: \.self) { id in HStack { Text("Chat \(id)"); Spacer(); Button("Unignore") { model.unignore(id) } } } } } }.formStyle(.grouped).padding().frame(width: 430, height: 300) }
}
