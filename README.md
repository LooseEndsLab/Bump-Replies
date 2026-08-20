# BumpReplies

A private, local macOS menu-bar app for finding one-to-one Messages chats that may need a follow-up.

## What it does

- **Waiting:** chats where your latest non-reaction message is still awaiting a reply.
- **Ghosting:** chats where the other person's latest non-reaction message is awaiting you.
- **Suggested:** prioritizes questions and requests; **All** includes every eligible chat.
- Dismiss a message or ignore a conversation to keep the queue tidy.

Set a minimum follow-up age and a maximum age for stale conversations in Settings. Group chats and reactions are excluded from the latest-message calculation.

## Get started

1. Open [BumpReplies.xcodeproj](BumpReplies/BumpReplies.xcodeproj) in Xcode and run the **BumpReplies** scheme.
2. Grant the development app **Full Disk Access** in **System Settings → Privacy & Security**.
3. Open the menu-bar item and choose **Refresh**.

## Privacy

BumpReplies reads Messages locally and in read-only mode. It has no backend, networking, telemetry, or analytics. Latest-message text is used only transiently for optional local ranking and is never stored or sent.

[Read the privacy policy.](PRIVACY.md)

## Develop and test

Run the unit tests:

```sh
xcodebuild test \
  -project BumpReplies/BumpReplies.xcodeproj \
  -scheme BumpReplies \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:BumpRepliesTests
```
