import Foundation

enum MessageTextExtractor {
    /// Messages commonly stores modern rich-text message content in attributedBody
    /// instead of text. Decode it only in memory; callers should immediately turn
    /// it into a classification and discard the result.
    static func text(plainText: String?, attributedBody: Data?) -> String? {
        if let plainText = nonEmpty(plainText) { return plainText }
        guard let attributedBody, !attributedBody.isEmpty else { return nil }

        for archive in archiveCandidates(in: attributedBody) {
            if let attributed = decodeAttributedString(from: archive), let text = nonEmpty(attributed.string) {
                return text
            }
        }

        // Older Messages records use NSArchiver's typed stream rather than a
        // keyed archive. It has no bplist header, so it must be decoded from
        // the original blob as a separate fallback.
        if let attributed = NSUnarchiver.unarchiveObject(with: attributedBody) as? NSAttributedString,
           let text = nonEmpty(attributed.string) {
            return text
        }
        return nil
    }

    private static func archiveCandidates(in data: Data) -> [Data] {
        let binaryPlistHeader = Data("bplist00".utf8)
        guard let range = data.range(of: binaryPlistHeader), range.lowerBound > data.startIndex else { return [data] }
        return [data, Data(data[range.lowerBound...])]
    }

    private static func decodeAttributedString(from archive: Data) -> NSAttributedString? {
        if let attributed = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: archive) {
            return attributed
        }

        // Messages has used legacy, non-secure keyed archives for attributedBody.
        // The database is local and opened read-only; the extracted string is used
        // immediately for classification and is never retained or logged.
        guard let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: archive) else { return nil }
        unarchiver.requiresSecureCoding = false
        defer { unarchiver.finishDecoding() }
        return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? NSAttributedString
    }

    private static func nonEmpty(_ text: String?) -> String? {
        guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return text
    }
}
