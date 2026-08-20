# BumpReplies

A private, local-first macOS menu-bar app that spots one-to-one Messages conversations needing a follow-up.

## What it does

- Shows chats whose latest non-reaction message is yours and older than your selected threshold.
- Keeps replied-to chats out of the list, and includes a **Ghosting** view for older incoming messages.
- Supports likely-follow-up filtering, notifications, dismissing, ignored conversations, optional Contacts names, and configurable settings.

## Likely follow-ups

BumpReplies uses a small, local algorithm to prioritize conversations that are *likely* to need a reply. It is a helpful ranking, not a separate definition of a pending conversation: every eligible conversation remains available under **All**, while **Likely** surfaces the ones with stronger reply signals first.

First, the app examines the latest non-reaction message in each one-to-one conversation. If that message is yours, the chat can appear in **Waiting**; if it is theirs, it can appear in **Ghosting**. A newer normal reply removes the conversation from the pending side. By default, a newer reaction from the other person is also treated as an acknowledgement. Group chats, dismissed messages, and ignored conversations are excluded according to your settings.

Next, the app applies your age settings. **Follow up after** is the minimum age of the latest message, and **Ignore conversations older than** is the maximum age. For example, with a 7-day follow-up threshold and a 90-day maximum age, a message sent 8 days ago can be included, a message sent 3 days ago cannot, and a message sent 100 days ago is excluded as stale.

For each eligible conversation, the latest message is checked transiently on your Mac for simple reply signals. It is marked **Likely** when it contains a question, a direct request, or a request for a decision. For example:

- “Are you free Thursday?” → likely: asked a question
- “Can you send me the deck?” or “Please confirm the time.” → likely: made a request
- “Should we meet next week?” or “Let me know what works.” → likely: asked for a decision or made a request
- “Sounds good, thanks!” → **Review**, so it stays under **All** but is not prioritized as Likely

This check uses only the latest eligible message and never saves or transmits its text.

## Run

1. Open [BumpReplies.xcodeproj](BumpReplies/BumpReplies.xcodeproj) in Xcode and run the **BumpReplies** scheme.
2. Give the development app Full Disk Access in **System Settings → Privacy & Security**.
3. Open the menu-bar item and choose **Refresh**.

## Privacy

Everything stays on your Mac: no backend, networking, telemetry, or analytics. BumpReplies reads the local Messages database in read-only mode; its optional likelihood filter uses only the latest eligible message content transiently and never stores or transmits it. See [PRIVACY.md](PRIVACY.md) for details.

## Test

    xcodebuild test \
      -project BumpReplies/BumpReplies.xcodeproj \
      -scheme BumpReplies \
      -destination 'platform=macOS,arch=arm64' \
      -only-testing:BumpRepliesTests

## Open issues

<!-- open-issues:start -->
| Issue | Title | Labels |
| --- | --- | --- |
| [#1](https://github.com/LooseEndsLab/Bump-Replies/issues/1) | TODO: publish/package | — |
| [#2](https://github.com/LooseEndsLab/Bump-Replies/issues/2) | Tune Likely follow-up rules from real-world feedback | — |
| [#3](https://github.com/LooseEndsLab/Bump-Replies/issues/3) | Add a queue review tab | — |
<!-- open-issues:end -->
