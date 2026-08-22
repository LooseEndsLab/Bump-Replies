import AppKit
import Foundation

enum MessagesLauncher {
    static func open(chatIdentifier: String) {
        guard let url = url(for: chatIdentifier) else { return }
        NSWorkspace.shared.open(url)
    }

    static func url(for chatIdentifier: String) -> URL? {
        let recipient = chatIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        let permittedCharacters = CharacterSet(charactersIn: "+0123456789-.@_")
        guard !recipient.isEmpty,
              recipient.unicodeScalars.allSatisfy({ permittedCharacters.contains($0) }) else {
            return nil
        }
        return URL(string: "sms:\(recipient)")
    }
}
