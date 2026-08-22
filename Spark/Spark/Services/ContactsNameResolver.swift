import Contacts
import Foundation

struct ContactNameIndex {
    private var namesByPhoneKey: [String: String] = [:]
    private var namesByEmail: [String: String] = [:]

    mutating func add(name: String, phoneNumbers: [String], emailAddresses: [String]) {
        guard !name.isEmpty else { return }
        for phoneNumber in phoneNumbers {
            for key in Self.phoneKeys(for: phoneNumber) {
                namesByPhoneKey[key, default: name] = name
            }
        }
        for emailAddress in emailAddresses {
            namesByEmail[Self.emailKey(for: emailAddress), default: name] = name
        }
    }

    func name(for identifier: String) -> String? {
        if let name = namesByEmail[Self.emailKey(for: identifier)] { return name }
        return Self.phoneKeys(for: identifier).lazy.compactMap { namesByPhoneKey[$0] }.first
    }

    static func phoneKeys(for value: String) -> Set<String> {
        let digits = value.unicodeScalars.filter(CharacterSet.decimalDigits.contains).map(String.init).joined()
        guard !digits.isEmpty else { return [] }

        var keys = [digits]
        if digits.count == 10 { keys.append("1" + digits) }
        if digits.count == 11, digits.hasPrefix("1") { keys.append(String(digits.dropFirst())) }
        return Set(keys)
    }

    static func emailKey(for value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

final class ContactsNameResolver {
    private let contactStore = CNContactStore()
    private let queue = DispatchQueue(label: "com.looseends.spark.contacts", qos: .utility)
    private var index = ContactNameIndex()
    private var hasLoadedContacts = false
    private var namesByIdentifier: [String: String] = [:]

    func names(for identifiers: [String]) async -> [String: String] {
        await withCheckedContinuation { continuation in
            queue.async {
                self.resolveNames(for: identifiers, continuation: continuation)
            }
        }
    }

    private func resolveNames(for identifiers: [String], continuation: CheckedContinuation<[String: String], Never>) {
        let unresolved = Set(identifiers).subtracting(namesByIdentifier.keys)
        guard !unresolved.isEmpty else {
            continuation.resume(returning: namesByIdentifier)
            return
        }

        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            loadContactsIfNeeded()
            cacheNames(for: unresolved)
            continuation.resume(returning: namesByIdentifier)
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, _ in
                self.queue.async {
                    guard granted else {
                        continuation.resume(returning: self.namesByIdentifier)
                        return
                    }
                    self.loadContactsIfNeeded()
                    self.cacheNames(for: unresolved)
                    continuation.resume(returning: self.namesByIdentifier)
                }
            }
        default:
            continuation.resume(returning: namesByIdentifier)
        }
    }

    private func cacheNames(for identifiers: Set<String>) {
        for identifier in identifiers {
            if let name = index.name(for: identifier) {
                namesByIdentifier[identifier] = name
            }
        }
    }

    private func loadContactsIfNeeded() {
        guard !hasLoadedContacts else { return }
        hasLoadedContacts = true

        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactNicknameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        let request = CNContactFetchRequest(keysToFetch: keys)
        try? contactStore.enumerateContacts(with: request) { [weak self] contact, _ in
            guard let self else { return }
            let name = Self.displayName(for: contact)
            self.index.add(
                name: name,
                phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue },
                emailAddresses: contact.emailAddresses.map { $0.value as String }
            )
        }
    }

    private static func displayName(for contact: CNContact) -> String {
        let fullName = [contact.givenName, contact.familyName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return fullName.isEmpty ? contact.nickname : fullName
    }
}
