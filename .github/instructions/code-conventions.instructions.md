---
description: "Use when: creating or editing Dart/Flutter files to follow ScanFlow code conventions."
---
# Code Conventions

- One class per file (except closely related types like Result + AppError).
- File names match class names in snake_case.
- Keep files under 200 lines; split when larger.
- Add `part` directives for generated files (`*.g.dart`, `*.freezed.dart`).
- Imports: relative within the same feature; `package:grace_scanner/...` across features.
