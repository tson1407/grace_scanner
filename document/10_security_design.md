# Security Design

## Threat Model

ScanFlow is an offline-first, local-only app. The attack surface is minimal compared to cloud-connected apps.

| Threat | Risk Level | Mitigation |
|---|---|---|
| Sensitive document data on disk | **Medium** | App-private storage, no external access |
| Malicious PDF import (future) | **Low** | Input validation, sandboxed rendering |
| Analytics data leakage | **Low** | Minimal telemetry, no PII in events |
| Reverse engineering | **Low** | ProGuard/obfuscation on release builds |
| Permission over-request | **Medium** | Request only camera; photo library only on import |

## Data Storage Security

### File System

| Rule | Implementation |
|---|---|
| All scan data in app-private directory | `getApplicationDocumentsDirectory()` — not accessible to other apps |
| No data in external/shared storage | Never use `getExternalStorageDirectory()` |
| Temp files cleaned on startup | Delete `temp/` contents in `main.dart` init |
| Exported PDFs go to user-chosen location | Share sheet or SAF (Storage Access Framework) |

### Database

| Rule | Implementation |
|---|---|
| SQLite in app-private directory | Default Drift location |
| No encryption for V1 | Overhead not justified for local-only app |
| V2 consideration | `sqlcipher_flutter_libs` if cloud sync is added |

## Permissions

### Requested Permissions

| Permission | When | Why | Fallback |
|---|---|---|---|
| Camera | On first scan | Core functionality | Block scan, show rationale |
| Photo Library (iOS) | On import | Import existing photos | Graceful disable |

### Not Requested

- Location — not needed
- Microphone — not needed
- Contacts — not needed
- Internet — only for analytics/crash reports (non-blocking)

### Permission Flow

```dart
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status.isPermanentlyDenied) {
    // Show dialog directing user to app settings
    await openAppSettings();
    return false;
  }
  return status.isGranted;
}
```

## Analytics & Telemetry (PostHog)

### What We Track

```dart
// Only anonymous usage events — no document content, no PII
enum AnalyticsEvent {
  scanStarted,
  scanCompleted,
  pdfExported,
  ocrUsed,
  filterApplied,
  appOpened,
}
```

### What We Never Track

- Document content or images
- OCR extracted text
- File names
- User identity (no auth)
- Location
- Device contacts

### Opt-Out

Users can disable analytics in Settings. Implementation:

```dart
final analyticsEnabledProvider = StateProvider<bool>((ref) => true);

void trackEvent(String event, Map<String, dynamic>? properties) {
  if (!ref.read(analyticsEnabledProvider)) return;
  Posthog().capture(eventName: event, properties: properties);
}
```

## Crash Reporting (Firebase Crashlytics)

- Enabled only in release builds
- Stack traces only — no user data attached
- No custom keys with sensitive content

```dart
if (kReleaseMode) {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

## Release Build Hardening

| Measure | Platform | Config |
|---|---|---|
| Code obfuscation | Both | `flutter build --obfuscate --split-debug-info=symbols/` |
| ProGuard | Android | `minifyEnabled true` + custom rules |
| Bitcode | iOS | Enabled by default |
| Debug info | Both | Stripped from release, uploaded to Crashlytics |

## Content Security

- No WebViews → no XSS surface
- No deep links in V1 → no URL injection
- No user-generated content shared to server → no injection attacks
- PDF generation uses typed API (`pdf` package) → no raw PDF manipulation
