# Privacy

BumpReplies has no backend, network requests, telemetry, analytics, or cloud synchronization.

## Messages data

It opens `~/Library/Messages/chat.db` using SQLite read-only mode and `PRAGMA query_only = ON`. It retrieves only chat identifiers/display names, message IDs, timestamps, outgoing status, reaction metadata, and participant-count metadata. It does not query message bodies, attachments, or contact handles, and never modifies Apple's database.

## Contacts data

If you grant Contacts permission, BumpReplies reads local contact names, phone numbers, and email addresses to replace a listed phone number/email with a saved name. The matching index and resolved names are kept only in memory for the active app session. Contacts information is never transmitted.

## Local preferences

Its local `UserDefaults` state contains the follow-up threshold, notification preference, group-chat preference, launch-at-login preference, ignored chat IDs, dismissed message IDs, and already-notified message IDs.
