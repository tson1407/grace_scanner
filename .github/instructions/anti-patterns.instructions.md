---
description: "Use when: choosing dependencies, placing logic, or deciding patterns. Avoid prohibited approaches in ScanFlow."
---
# Avoid These Patterns

- Do not add packages without discussion; check existing deps first.
- Do not create global singletons; use Riverpod providers for DI.
- Do not use `GetX` or the `Provider` package; Riverpod only.
- Do not put business logic in widgets; use providers/notifiers.
- Do not write platform-specific Dart code; use native channels.
- Do not use `dynamic` types; prefer explicit types or generics.
- Do not skip code generation after model changes.
