# BumpReplies contributor guide

## Scope

BumpReplies is a local-only macOS menu-bar app. It identifies one-to-one Messages conversations that may need a follow-up.

## Privacy and data rules

- Keep all data local. Do not add networking, telemetry, analytics, cloud services, or an LLM/API integration without explicit approval.
- `~/Library/Messages/chat.db` is read-only. Open it with SQLite read-only mode and keep `PRAGMA query_only = ON`.
- Never query message bodies, attachments, message text, or handle/contact data from `chat.db`. Query only the minimal metadata needed for follow-up classification.
- Contacts access is optional and local. If denied, keep showing raw chat identifiers.
- Do not log identifiers, contact data, or message metadata.

## Follow-up semantics

- Rank messages per conversation by the latest non-reaction message overall, then decide whether it is outgoing.
- A newer incoming message means the conversation is not waiting on the recipient.
- Reactions/Tapbacks do not count as the latest conversation message.
- The Ghosting tab is the inverse view: its latest non-reaction message is incoming and older than the threshold.
- `Dismiss` hides the current outgoing message; `Ignore Conversation` hides the entire chat until it is unignored.

## Project constraints

- Preserve the app bundle identifier and signing settings unless the user explicitly asks to change them.
- Keep the deployment target at macOS 13.0 or later unless compatibility is intentionally revisited.
- Keep UI work in SwiftUI and prefer small, testable services for non-UI logic.

## Verification

Run unit tests only unless UI testing is specifically requested:

```sh
xcodebuild test \
  -project BumpReplies/BumpReplies.xcodeproj \
  -scheme BumpReplies \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:BumpRepliesTests
```

Use a temporary DerivedData path if an existing local build has stale nested test signatures. Do not clean or alter the user’s active app build merely to run tests.

Before committing, ensure `git diff --check` passes and no Finder/Xcode generated artifacts are staged.
