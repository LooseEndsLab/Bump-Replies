# BumpReplies

A private, local-first macOS menu-bar app that spots one-to-one Messages conversations needing a follow-up.

## What it does

- Shows chats whose latest non-reaction message is yours and older than your selected threshold.
- Keeps replied-to chats out of the list, and includes a **Ghosting** view for older incoming messages.
- Supports likely-follow-up filtering, notifications, dismissing, ignored conversations, optional Contacts names, and configurable settings.

## Likely follow-ups

Likely is a local priority filter, not a separate definition of a pending chat. BumpReplies first finds each one-to-one chat’s latest non-reaction message, applies the response and age rules, then marks it Likely when that latest message is a question, asks for a decision, or makes a direct request. Messages without those signals remain under **All**. The **Follow up after** setting is the minimum age of that latest message; the maximum-age setting excludes stale conversations.

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
| [#2](https://github.com/LooseEndsLab/Bump-Replies/issues/2) | Tune Likely follow-up rules from real-world feedback | — |
| [#1](https://github.com/LooseEndsLab/Bump-Replies/issues/1) | TODO: publish/package | — |
<!-- open-issues:end -->
