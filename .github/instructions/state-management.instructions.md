---
description: "Use when: working with Riverpod providers, state, or lifecycle in ScanFlow."
---
# State Management (Riverpod)

- Use `AsyncNotifier` for stateful providers with async operations (not `StateNotifier`).
- Use `ref.watch()` in `build()` and `ref.read()` in callbacks.
- Use `AutoDispose` by default; only `keepAlive` for data that must persist across screens.
- Provider files live in `features/<feature>/presentation/`.
- Provider naming: `<noun><Purpose>Provider` (e.g., `documentListProvider`).
