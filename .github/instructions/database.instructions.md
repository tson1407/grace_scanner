---
description: "Use when: updating the Drift/SQLite database schema or queries."
---
# Database Rules

- Use Drift DAOs for all queries; no raw SQL in app code.
- Run `build_runner` after any table change.
- Timestamps are Unix epoch milliseconds (`int`).
- Store file paths relative to the app documents directory; resolve at read time.
