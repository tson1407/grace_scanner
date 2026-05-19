---
description: "Use when: handling errors or writing native integrations/services for ScanFlow."
---
# Error Handling and Native Integration

- Repositories return `Result<T>` (Success/Failure); never throw.
- Presentation layer pattern-matches on `Result` to show error UI.
- Log errors via `logger.dart`; never use `print()`.
- All native communication goes through `*NativeService` classes in the data layer.
- Channel names follow `com.scanflow/<feature>`.
- Always handle `PlatformException` and wrap native errors into `AppError`.
- Release native resources in `ref.onDispose()` callbacks.
- Test native methods with mock channels in unit tests.
