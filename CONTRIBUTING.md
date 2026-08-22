# Contributing

Keep the app local-first: do not add networking, telemetry, analytics, message-body access, or writes to `chat.db`. See [AGENTS.md](AGENTS.md) for the complete contributor rules.

Changes to Messages database queries must remain read-only, select only necessary metadata, and include SQLite-backed regression tests. In particular, test the latest-message ordering whenever query logic changes.

Build and run unit tests before submitting changes:

```sh
xcodebuild test \
  -project Spark/Spark.xcodeproj \
  -scheme Spark \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:SparkTests
```

Do not change the app bundle identifier or signing configuration unless the work explicitly calls for it.
