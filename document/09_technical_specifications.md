# Technical Specifications — Dependencies & Configuration

## Dart SDK & Flutter Version

```yaml
environment:
  sdk: ^3.12.0
  flutter: ">=3.29.0"
```

## Dependencies

### Core

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1

  # Navigation
  go_router: ^14.8.1

  # Database
  drift: ^2.23.1
  sqlite3_flutter_libs: ^0.5.28

  # Code Generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Camera & Image
  google_mlkit_text_recognition: ^0.14.0
  image: ^4.5.2                        # Dart image manipulation (thumbnails)

  # PDF
  pdf: ^3.11.2
  printing: ^5.14.2

  # File & Path
  path_provider: ^2.1.5
  path: ^1.9.1
  share_plus: ^10.1.4

  # Analytics & Monitoring
  posthog_flutter: ^4.7.1
  firebase_core: ^3.12.1
  firebase_crashlytics: ^4.3.5

  # UI
  cupertino_icons: ^1.0.8
  flutter_animate: ^4.5.2             # Micro-animations
  shimmer: ^3.0.0                      # Loading skeletons

  # Utils
  uuid: ^4.5.1
  permission_handler: ^11.3.1
  intl: ^0.20.2
```

### Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.13
  riverpod_generator: ^2.6.3
  freezed: ^2.5.7
  json_serializable: ^6.9.2
  drift_dev: ^2.23.1

  # Linting
  flutter_lints: ^6.0.0
  custom_lint: ^0.7.5
  riverpod_lint: ^2.6.3

  # Testing
  mocktail: ^1.0.4
  integration_test:
    sdk: flutter
```

## Code Generation

Run after modifying Drift tables, Freezed models, or Riverpod annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Android Configuration

### `android/app/build.gradle`

```groovy
android {
    compileSdk = 35
    
    defaultConfig {
        applicationId = "com.scanflow.app"
        minSdk = 24
        targetSdk = 35
        
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86_64'
        }
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### ProGuard Rules

```
# OpenCV
-keep class org.opencv.** { *; }

# ML Kit
-keep class com.google.mlkit.** { *; }

# CameraX
-keep class androidx.camera.** { *; }
```

## iOS Configuration

### `ios/Podfile`

```ruby
platform :ios, '15.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

### `Info.plist` Permissions

```xml
<key>NSCameraUsageDescription</key>
<string>ScanFlow needs camera access to scan documents.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ScanFlow needs photo library access to import images.</string>
```

## Minimum Platform Versions

| Platform | Minimum | Reason |
|---|---|---|
| Android | API 24 (7.0) | CameraX requirement |
| iOS | 15.0 | AVFoundation modern APIs, ML Kit support |

## App Signing

| Environment | Signing |
|---|---|
| Debug | Auto-generated debug key |
| Release Android | Upload keystore (stored in CI secrets) |
| Release iOS | Apple Distribution certificate + provisioning profile |
