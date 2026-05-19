---
description: "Use when: modifying architecture, feature boundaries, or cross-feature dependencies in ScanFlow."
---
# Architecture Rules

- Keep the layer order: Presentation -> Application -> Domain -> Data; never bypass.
- Domain layer is pure Dart (no Flutter or package imports).
- Data layer implements domain interfaces; presentation never references concrete data implementations.
- Cross-feature communication uses Riverpod providers only; no direct feature imports.
