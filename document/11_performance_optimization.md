# Performance Optimization

## Performance Targets (from SRS)

| Metric | Target | Measurement Method |
|---|---|---|
| App startup (cold) | < 1.5 sec | `flutter run --trace-startup` |
| Scan processing (full pipeline) | < 2 sec | Stopwatch around native call |
| PDF export (10 pages) | < 5 sec | Stopwatch around PDF generation |
| Scroll FPS (home list) | 60 FPS | DevTools Performance overlay |
| OCR per page | < 4 sec | Stopwatch around ML Kit call |

## Startup Optimization

| Strategy | Implementation |
|---|---|
| Lazy initialization | Don't init camera/OpenCV/ML Kit until first use |
| Deferred provider loading | Use `AutoDispose` — only alive when watched |
| Minimal main() | Only `ProviderScope` + `MaterialApp.router` in `main()` |
| Precompile shaders | `flutter build --bundle-sksl-path` for known animations |
| Splash screen | Native splash (no Flutter rendering delay) via `flutter_native_splash` |

## Image Processing Performance

### Resolution Management

```dart
// Never process raw camera output at full resolution
class ImageResizer {
  static const int maxProcessingDimension = 2048;
  static const int thumbnailDimension = 256;
  static const int previewEdgeDetection = 640;

  static Future<String> resizeForProcessing(String inputPath) async {
    // Downscale to maxProcessingDimension on longest edge
    // Preserves aspect ratio
  }
}
```

### Processing Thread Strategy

| Operation | Thread | Why |
|---|---|---|
| Edge detection (live preview) | Native background thread | Must not block UI or camera |
| Perspective transform | Native background thread | CPU-intensive |
| Enhancement filters | Native background thread | CPU-intensive |
| Thumbnail generation | Dart Isolate | Moderate CPU, pure Dart |
| PDF generation | Dart Isolate | I/O + CPU mix |
| OCR | ML Kit managed thread | SDK handles threading |

### Frame Throttling for Live Detection

```dart
// Process every 3rd frame, skip if previous still processing
class EdgeDetectionThrottle {
  int _frameCount = 0;
  bool _processing = false;

  bool shouldProcess() {
    _frameCount++;
    if (_frameCount % 3 != 0) return false;
    if (_processing) return false;
    _processing = true;
    return true;
  }

  void onComplete() => _processing = false;
}
```

## Memory Optimization

### Image Memory Budget

```
Rule of thumb: A 4000x3000 image = ~48MB uncompressed in memory (RGBA)

Strategy:
- Never hold more than 2 full-res images in memory simultaneously
- Process → save → dispose immediately
- Thumbnails for UI lists (256px = ~260KB each)
- Preview frames at 640px for edge detection
```

### Memory Monitoring

```dart
// Log memory pressure in debug builds
if (kDebugMode) {
  WidgetsBinding.instance.addObserver(
    _MemoryObserver(onMemoryPressure: () {
      // Evict thumbnail cache, dispose unused images
    }),
  );
}
```

### Thumbnail Cache

```dart
// LRU cache with max 50 thumbnails (~13MB)
class ThumbnailCache {
  final _cache = LinkedHashMap<String, Uint8List>();
  static const maxEntries = 50;

  Uint8List? get(String key) { /* ... */ }

  void put(String key, Uint8List data) {
    if (_cache.length >= maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = data;
  }
}
```

## UI Performance

### List Rendering

```dart
// Home screen document list — always use builder
ListView.builder(
  itemCount: documents.length,
  itemBuilder: (context, index) {
    return DocumentCard(document: documents[index]);
  },
)
```

### Image Display

```dart
// Use ResizeImage to limit decode resolution
Image.file(
  File(thumbnailPath),
  cacheWidth: 256,     // Decode at display size, not file size
  cacheHeight: 256,
  filterQuality: FilterQuality.low,
)
```

### Animation Performance

- Use `RepaintBoundary` around animated widgets (edge overlay, capture button)
- Keep animations at 60fps by using only opacity/transform (composited layers)
- No complex `CustomPaint` during animation frames

## Database Performance

| Strategy | Implementation |
|---|---|
| Index hot queries | See `04_database_schema.md` — indexed on `updated_at`, `document_id` |
| Batch operations | Use Drift's `batch()` for multi-page inserts |
| Pagination | Load 20 documents at a time, load more on scroll |
| Background writes | OCR results written async, not blocking UI |

## Low-End Device Support

Target: Devices with 2GB RAM, mid-range SoC (e.g., Snapdragon 665)

| Adaptation | Trigger |
|---|---|
| Reduce preview resolution to 480p | Available RAM < 3GB |
| Disable live edge detection overlay | FPS drops below 24 |
| Lower JPEG quality to 70% | Storage < 500MB free |
| Sequential page processing only | RAM < 3GB |

Detection at startup:
```dart
final totalMemory = SysInfo.getTotalPhysicalMemory();  // via platform channel
final isLowEnd = totalMemory < 3 * 1024 * 1024 * 1024; // < 3GB
```

## Profiling Checklist

Before each release:
- [ ] `flutter run --profile` — check Timeline for jank
- [ ] DevTools Memory tab — no unbounded growth over 10+ scans
- [ ] `flutter test --coverage` — identify untested hot paths
- [ ] Native memory: Android Profiler / Xcode Instruments — check for OpenCV leaks
- [ ] Startup trace: < 1.5s on Pixel 4a / iPhone SE 2
