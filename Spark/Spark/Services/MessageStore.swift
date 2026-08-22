import Foundation
import SQLite3

protocol MessageStore { func latestConversationMessages() throws -> [ConversationMessage] }
enum MessageStoreError: LocalizedError { case databaseUnavailable(String), queryFailed(String)
    var errorDescription: String? { switch self { case .databaseUnavailable(let d): return "Unable to open the local Messages database: \(d)"; case .queryFailed(let d): return "Unable to read local Messages metadata: \(d)" } }
}

final class SQLiteMessageStore: MessageStore {
    private let databaseURL: URL
    init(databaseURL: URL = FileManager.default.homeDirectoryForCurrentUser.appending(path: "Library/Messages/chat.db")) { self.databaseURL = databaseURL }
    func latestConversationMessages() throws -> [ConversationMessage] {
        var database: OpaquePointer?
        let uri = "file:\(databaseURL.path(percentEncoded: false))?mode=ro"
        guard sqlite3_open_v2(uri, &database, SQLITE_OPEN_READONLY | SQLITE_OPEN_URI | SQLITE_OPEN_NOMUTEX, nil) == SQLITE_OK, let database else {
            defer { sqlite3_close(database) }; throw MessageStoreError.databaseUnavailable(database.map { String(cString: sqlite3_errmsg($0)) } ?? "database could not be opened")
        }
        defer { sqlite3_close(database) }
        sqlite3_exec(database, "PRAGMA query_only = ON", nil, nil, nil)

        // The latest eligible message content is read only for local follow-up
        // likelihood classification. No text is persisted, logged, or sent off this Mac.
        let sql = """
        WITH latest_message_per_chat AS (
            SELECT
                cmj.chat_id,
                cmj.message_id,
                ROW_NUMBER() OVER (
                    PARTITION BY cmj.chat_id
                    ORDER BY m.date DESC, m.ROWID DESC
                ) AS position
            FROM chat_message_join cmj
            JOIN message m ON m.ROWID = cmj.message_id
            WHERE COALESCE(m.associated_message_type, 0) = 0
        )
        SELECT c.ROWID, c.chat_identifier, c.display_name, m.ROWID, m.date, m.is_from_me, m.text, m.attributedBody,
               EXISTS (
                   SELECT 1 FROM chat_handle_join ch
                   WHERE ch.chat_id = c.ROWID
                   GROUP BY ch.chat_id HAVING COUNT(*) > 1
               ),
               EXISTS (
                   SELECT 1
                   FROM chat_message_join reaction_join
                   JOIN message reaction ON reaction.ROWID = reaction_join.message_id
                   WHERE reaction_join.chat_id = c.ROWID
                     AND COALESCE(reaction.associated_message_type, 0) != 0
                     AND reaction.is_from_me != m.is_from_me
                     AND (reaction.date > m.date OR (reaction.date = m.date AND reaction.ROWID > m.ROWID))
               )
        FROM latest_message_per_chat latest
        JOIN chat c ON c.ROWID = latest.chat_id
        JOIN message m ON m.ROWID = latest.message_id
        WHERE latest.position = 1
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK, let statement else { throw MessageStoreError.queryFailed(String(cString: sqlite3_errmsg(database))) }
        defer { sqlite3_finalize(statement) }
        var messages: [ConversationMessage] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let rawDate = sqlite3_column_int64(statement, 4)
            let messageText = MessageTextExtractor.text(plainText: Self.text(statement, 6), attributedBody: Self.data(statement, 7))
            messages.append(ConversationMessage(chatID: sqlite3_column_int64(statement, 0), chatIdentifier: Self.text(statement, 1) ?? "Unknown conversation", displayName: Self.text(statement, 2), messageID: sqlite3_column_int64(statement, 3), date: Self.dateFromAppleNanoseconds(rawDate), isFromMe: sqlite3_column_int(statement, 5) != 0, isGroupChat: sqlite3_column_int(statement, 8) != 0, hasOppositeDirectionReactionAfterMessage: sqlite3_column_int(statement, 9) != 0, likelihood: FollowUpLikelihood.classify(messageText: messageText)))
        }
        return messages
    }

    static func dateFromAppleNanoseconds(_ rawDate: Int64) -> Date {
        Date(timeIntervalSinceReferenceDate: Double(rawDate) / 1_000_000_000)
    }

    private static func text(_ statement: OpaquePointer, _ column: Int32) -> String? { guard let value = sqlite3_column_text(statement, column) else { return nil }; return String(cString: value) }
    private static func data(_ statement: OpaquePointer, _ column: Int32) -> Data? {
        guard let bytes = sqlite3_column_blob(statement, column) else { return nil }
        return Data(bytes: bytes, count: Int(sqlite3_column_bytes(statement, column)))
    }
}
