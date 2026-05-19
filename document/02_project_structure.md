# Flutter Project Structure — ScanFlow

## Full Directory Layout

```
lib/
├── main.dart                          # App entry point, ProviderScope, GoRouter
├── app.dart                           # MaterialApp.router configuration
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_sizes.dart             # Spacing, radius, breakpoints
│   │   └── app_strings.dart           # Static strings (non-i18n MVP)
│   ├── errors/
│   │   ├── app_error.dart             # Sealed error types
│   │   └── result.dart                # Result<T> type
│   ├── extensions/
│   │   ├── context_ext.dart           # BuildContext shortcuts
│   │   └── image_ext.dart             # Uint8List / image helpers
│   ├── router/
│   │   ├── app_router.dart            # GoRouter config
│   │   └── routes.dart                # Route path constants
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData definitions
│   │   └── text_styles.dart           # Typography
│   └── utils/
│       ├── file_utils.dart            # Path resolution, temp dirs
│       ├── image_utils.dart           # Compression, resize helpers
│       └── logger.dart                # Logging wrapper
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── loading_overlay.dart
│   │   ├── error_view.dart
│   │   └── thumbnail_card.dart
│   └── providers/
│       └── app_lifecycle_provider.dart
│
├── features/
│   ├── camera/
│   │   ├── data/
│   │   │   ├── camera_native_service.dart      # MethodChannel calls
│   │   │   └── camera_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── camera_repository.dart          # Abstract interface
│   │   │   └── camera_state.dart               # Entities
│   │   └── presentation/
│   │       ├── camera_screen.dart
│   │       ├── camera_controller_provider.dart  # Riverpod provider
│   │       └── widgets/
│   │           ├── capture_button.dart
│   │           ├── flash_toggle.dart
│   │           └── edge_overlay.dart
│   │
│   ├── scanner/
│   │   ├── data/
│   │   │   ├── opencv_native_service.dart
│   │   │   └── scanner_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── scanner_repository.dart
│   │   │   ├── scan_document.dart
│   │   │   └── edge_detection_result.dart
│   │   └── presentation/
│   │       ├── crop_screen.dart
│   │       ├── enhancement_screen.dart
│   │       ├── scanner_provider.dart
│   │       └── widgets/
│   │           ├── crop_handle.dart
│   │           ├── filter_selector.dart
│   │           └── page_thumbnail_strip.dart
│   │
│   ├── pdf/
│   │   ├── data/
│   │   │   └── pdf_generator_impl.dart
│   │   ├── domain/
│   │   │   ├── pdf_generator.dart
│   │   │   └── pdf_options.dart
│   │   └── presentation/
│   │       ├── pdf_preview_screen.dart
│   │       ├── pdf_provider.dart
│   │       └── widgets/
│   │           └── page_reorder_list.dart
│   │
│   ├── ocr/
│   │   ├── data/
│   │   │   └── ml_kit_ocr_service.dart
│   │   ├── domain/
│   │   │   ├── ocr_service.dart
│   │   │   └── ocr_result.dart
│   │   └── presentation/
│   │       ├── ocr_result_screen.dart
│   │       └── ocr_provider.dart
│   │
│   ├── storage/
│   │   ├── data/
│   │   │   ├── database/
│   │   │   │   ├── app_database.dart           # Drift database class
│   │   │   │   ├── tables.dart                 # Table definitions
│   │   │   │   └── daos/
│   │   │   │       ├── document_dao.dart
│   │   │   │       └── page_dao.dart
│   │   │   ├── file_storage_service.dart
│   │   │   └── document_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── document_repository.dart
│   │   │   ├── document.dart
│   │   │   └── document_page.dart
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       ├── document_detail_screen.dart
│   │       ├── document_list_provider.dart
│   │       └── widgets/
│   │           ├── document_card.dart
│   │           └── empty_state.dart
│   │
│   └── settings/
│       └── presentation/
│           ├── settings_screen.dart
│           └── settings_provider.dart
│
android/
├── app/src/main/
│   ├── kotlin/com/scanflow/
│   │   ├── MainActivity.kt
│   │   ├── camera/
│   │   │   ├── CameraPlugin.kt               # MethodChannel handler
│   │   │   └── CameraManager.kt              # CameraX lifecycle
│   │   └── opencv/
│   │       ├── OpenCvPlugin.kt                # MethodChannel handler
│   │       └── ImageProcessor.kt              # OpenCV JNI bridge
│   └── jniLibs/                               # OpenCV .so files
│
ios/
├── Runner/
│   ├── Camera/
│   │   ├── CameraPlugin.swift
│   │   └── CameraManager.swift
│   └── OpenCV/
│       ├── OpenCvPlugin.swift
│       └── ImageProcessor.mm                  # Obj-C++ bridge to OpenCV
│
test/
├── unit/
│   ├── features/
│   │   ├── scanner/
│   │   ├── pdf/
│   │   ├── ocr/
│   │   └── storage/
│   └── core/
├── widget/
│   └── features/
└── integration/
    ├── scan_flow_test.dart
    └── pdf_export_test.dart
```

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case` | `camera_screen.dart` |
| Classes | `PascalCase` | `CameraScreen` |
| Providers | `camelCase` + `Provider` suffix | `cameraControllerProvider` |
| Abstract repos | No `I` prefix | `CameraRepository` |
| Implementations | `Impl` suffix | `CameraRepositoryImpl` |
| Private members | `_` prefix | `_cameraState` |
| Constants | `camelCase` | `defaultJpegQuality` |
| Enums | `PascalCase` members | `FilterType.grayscale` |

## Feature Module Template

Every feature follows the same 3-folder structure:

```
feature_name/
├── data/           # Implementations, services, data sources
├── domain/         # Interfaces, entities, value objects
└── presentation/   # Screens, providers, widgets/
```

Rules:
- `domain/` has zero package imports (pure Dart only)
- `data/` implements interfaces from `domain/`
- `presentation/` depends only on `domain/` types + Riverpod providers
- Cross-feature communication goes through providers, never direct imports between features
