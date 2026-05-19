---
description: "Use when: preparing changes for completion or summarizing work."
---
# Workflow Checklist

- Commit format: `feat|fix|refactor|test|chore|docs: <summary>`.
- Verify `flutter analyze` has zero warnings.
- Verify `dart format lib/ test/` produces no changes.
- Verify `flutter test` passes.
- Verify `build_runner` is up to date.
- Do not leave `TODO` comments without a tracking issue.
- New code follows adjacent patterns and project conventions.
