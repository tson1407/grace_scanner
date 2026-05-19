# AI Agent Coding Guidelines

Rules and patterns for AI coding agents working on this codebase.

---

## 1. Architecture Rules

- **Never bypass the layer hierarchy**: Presentation → Application → Domain → Data.
- **Domain layer is pure Dart** — no Flutter imports, no package imports.
- **Data layer implements domain interfaces** — never reference concrete implementations from presentation.
- **Cross-feature communication via Riverpod providers only** — never import directly between feature folders.

## 2. File & Code Conventions

- One class per file (except closely related types like `Result` + `AppError`).
- File names match class names in `snake_case`.
- Always add `part` directives for generated files (`*.g.dart`, `*.freezed.dart`).
- Use relative imports within the same feature, package imports (`package:grace_scanner/...`) across features.
- Keep files under 200 lines. If longer, split.

## 3. State Management

- **Use `AsyncNotifier`** for stateful providers with async operations (not `StateNotifier`).
- **Use `ref.watch()` in `build()`**, `ref.read()` in callbacks — never the reverse.
- **Use `AutoDispose`** by default. Only `keepAlive` for data that persists across screens.
- All provider files go in `features/<feature>/presentation/`.
- Name providers: `<noun><Purpose>Provider` (e.g., `documentListProvider`, `scanSessionProvider`).

## 4. Error Handling

- Return `Result<T>` (Success/Failure) from repositories — never throw.
- Presentation layer pattern-matches on Result to show error UI.
- Log errors via `logger.dart` — don't use `print()`.
- Native errors are caught at the Data layer boundary and wrapped into `AppError`.

## 5. Native Code

- All native communication goes through `*NativeService` classes in `data/`.
- Channel names: `com.scanflow/<feature>` (e.g., `com.scanflow/camera`).
- Always handle `PlatformException` — native code can fail at any time.
- Release native resources in `ref.onDispose()` callbacks.
- Test native methods with mock channels in unit tests.

## 6. Image Handling

- **Never hold more than 2 full-resolution images in memory.**
- Always process images at ≤ 2048px on longest edge.
- Thumbnails at 256px.
- Use `compute()` / Isolates for any image operation > 50ms.
- Delete temp files after pipeline completes.

## 7. Database

- Use Drift DAOs for all queries — no raw SQL in app code.
- Run `build_runner` after any table change.
- Timestamps are Unix epoch milliseconds (`int`).
- File paths in DB are relative to app documents directory — resolve at read time.

## 8. Testing

- Every new provider needs a unit test.
- Every new repository method needs a unit test with mocked dependencies.
- Use `mocktail` for mocks — `class MockX extends Mock implements X {}`.
- Use `ProviderContainer` with overrides for provider tests.
- Widget tests: wrap in `ProviderScope` with overridden providers.
- Name test files: `<source_file>_test.dart` in mirrored `test/` path.

## 9. Adding a New Feature

Follow this checklist:

```
1. Create feature folder: lib/features/<name>/
2. Create domain layer:
   - Entity/model classes (pure Dart)
   - Abstract repository interface
3. Create data layer:
   - Repository implementation
   - Native service (if needed)
   - DB DAO (if needed)
4. Create presentation layer:
   - Provider (AsyncNotifier or FutureProvider)
   - Screen widget
   - Sub-widgets in widgets/ folder
5. Add route in core/router/app_router.dart
6. Write tests:
   - Unit: provider + repository
   - Widget: screen with mocked provider
7. Run: flutter analyze && flutter test
```

## 10. Performance Guardrails

- No synchronous file I/O on main thread.
- No `setState` — use Riverpod exclusively.
- Use `ListView.builder` for any list > 10 items.
- Use `Image.file` with `cacheWidth`/`cacheHeight` for display.
- Wrap animated widgets in `RepaintBoundary`.

## 11. What NOT to Do

| Don't | Do Instead |
|---|---|
| Add packages without discussing | Check if existing deps solve it |
| Create global singletons | Use Riverpod providers for DI |
| Use `GetX` or `Provider` package | Riverpod only |
| Put business logic in widgets | Put it in providers/notifiers |
| Write platform-specific Dart code | Use native code via channels |
| Store absolute paths in DB | Store relative paths, resolve at runtime |
| Catch and ignore errors | Catch, log, and surface via Result |
| Use `dynamic` types | Use proper types or generics |
| Skip code generation step | Always run `build_runner` after model changes |

## 12. Commit Conventions

```
feat: add edge detection overlay
fix: resolve memory leak in camera preview
refactor: extract scan session into separate provider
test: add unit tests for PdfGenerator
chore: update OpenCV to 4.9.1
docs: add OCR system design document
```

## 13. PR Checklist (for agents)

Before marking work complete:
- [ ] `flutter analyze` — zero warnings
- [ ] `dart format lib/ test/` — no changes
- [ ] `flutter test` — all pass
- [ ] `build_runner` — no pending generation
- [ ] No `TODO` comments left without a tracking issue
- [ ] New code follows existing patterns (check adjacent files)
