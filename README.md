# BumpReplies

BumpReplies is a private, local-first macOS menu-bar app for finding one-to-one Messages conversations that may need a follow-up. It shows a conversation only when its latest non-reaction message was sent by you and is older than your chosen threshold.

Nothing leaves your Mac: BumpReplies has no backend, networking, telemetry, analytics, or message-content access.

## What it does

- Chooses the latest message overall for each conversation before considering direction.
- Excludes chats with a newer incoming message, so replied-to conversations do not appear as waiting.
- Ignores reactions/Tapbacks when determining the latest conversation message.
- Optionally resolves phone numbers and email addresses to local Contacts names.
- Opens a listed phone-number conversation in Messages when you click its row.
- Includes a **Ghosting** tab for conversations whose latest non-reaction message is an older incoming message.
- Supports configurable follow-up thresholds, notifications, group-chat filtering, launch at login, dismissal, and permanent conversation ignoring.

## Run locally

1. Open [BumpReplies.xcodeproj](BumpReplies/BumpReplies.xcodeproj) in Xcode.
2. Select the **BumpReplies** scheme and **My Mac**, then run it.
3. In **System Settings → Privacy & Security → Full Disk Access**, enable the Development-signed BumpReplies app.
4. Open the menu-bar item and choose **Refresh**.

The app requires Full Disk Access because Apple stores Messages data in a protected local database. It is intentionally not sandboxed. You may also see optional system prompts for Contacts (to display names) and Notifications.

## Using the list

- Click a row to open that recipient in Messages. The **Dismiss** button and `…` menu remain separate actions.
- **Dismiss** hides only the current outgoing message. A later outgoing message in that chat may appear again.
- **Ignore Conversation** hides that chat until you unignore it in Settings.
- If Contacts access is denied or no matching contact exists, BumpReplies shows the original phone number or email address.

## Privacy and Messages database access

The local Messages database is `~/Library/Messages/chat.db`, an undocumented Apple implementation detail that can change between macOS releases. BumpReplies opens it with SQLite read-only mode and `PRAGMA query_only = ON`.

The query reads only the metadata necessary for follow-up classification: chat IDs/identifiers/display names, message IDs, dates, direction, reaction metadata, and participant-count metadata. It never reads message bodies, attachments, or contact handles, and never writes to the database.

For a detailed inventory of locally stored settings and Contacts use, see [PRIVACY.md](PRIVACY.md). Contribution and engineering guidance is in [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md).

## Test

Run the unit-test target without executing UI tests:

```sh
xcodebuild test \
  -project BumpReplies/BumpReplies.xcodeproj \
  -scheme BumpReplies \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:BumpRepliesTests
```

## Open issues

<!-- open-issues:start -->
- [#1: TODO: publish/package](https://github.com/LooseEndsLab/Bump-Replies/issues/1)
<!-- open-issues:end -->
