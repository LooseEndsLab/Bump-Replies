import SwiftUI
struct FollowUpRow: View {
    @EnvironmentObject private var model: AppModel
    let followUp: FollowUp

    var body: some View {
        HStack(spacing: 12) {
            Button {
                model.openInMessages(followUp)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.name(for: followUp)).lineLimit(1)
                        Text("\(followUp.daysOld())d waiting")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Dismiss") {
                model.dismiss(followUp)
            }
            .buttonStyle(.borderless)

            Menu {
                Button("Open in Messages") { model.openInMessages(followUp) }
                Button("Dismiss") { model.dismiss(followUp) }
                Button("Ignore Conversation", role: .destructive) { model.ignore(followUp) }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(.vertical, 5)
    }
}
