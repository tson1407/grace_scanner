---
description: "Use when: adding or updating tests for providers, repositories, or widgets."
---
# Testing Rules

- Every new provider needs a unit test.
- Every new repository method needs a unit test with mocked dependencies.
- Use `mocktail` for mocks: `class MockX extends Mock implements X {}`.
- Provider tests use `ProviderContainer` with overrides.
- Widget tests wrap in `ProviderScope` with overridden providers.
- Test file naming: `<source_file>_test.dart` in mirrored `test/` path.
