import SwiftUI
struct PermissionView: View { let error: String
    var body: some View { VStack(alignment: .leading, spacing: 10) { Image(systemName: "lock.shield").font(.title2); Text("Spark needs access to your local Messages database to determine which conversations are waiting for a response. Your messages never leave this Mac."); Text("Open System Settings → Privacy & Security → Full Disk Access, then enable Spark and refresh.").font(.caption).foregroundStyle(.secondary); Text(error).font(.caption2).foregroundStyle(.secondary) }.padding().frame(width: 360, alignment: .leading) }
}
