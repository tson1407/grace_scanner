---
description: "Use when: making performance-sensitive UI, file I/O, or rendering changes."
---
# Performance Guardrails

- No synchronous file I/O on the main thread.
- No `setState`; use Riverpod exclusively.
- Use `ListView.builder` for any list over 10 items.
- Use `Image.file` with `cacheWidth`/`cacheHeight` for display.
- Wrap animated widgets in `RepaintBoundary`.
