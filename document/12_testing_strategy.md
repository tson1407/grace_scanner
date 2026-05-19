# Testing Strategy

## Testing Pyramid

```
         ┌──────────┐
         │Integration│   ~5%  — Full scan-to-PDF flows on device
         │  Tests    │
        ┌┴──────────┴┐
        │   Widget   │   ~25% — Screen rendering, user interactions
        │   Tests    │
       ┌┴────────────┴┐
       │    Unit       │  ~70% — Providers, repositories, utils, domain
       │    Tests      │
       └──────────────┘
```

## Unit Tests

### What to Test

| Layer | What | Tool |
|---|---|---|
| Domain | Entities, value objects, validation | `flutter_test` |
| Data (repos) | Repository logic with mocked services | `mocktail` |
| Providers | State transitions, async flows | `ProviderContainer` + `mocktail` |
| Utils | File utils, image compression, formatting | `flutter_test` |

### Provider Testing Pattern

```dart
void main() {
  late MockScannerRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockScannerRepository();
    container = ProviderContainer(
      overrides: [
        scannerRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('scan session transitions to processing on capture', () async {
    when(() => mockRepo.processImage(any()))
        .thenAnswer((_) async => Success(processedPage));

    final notifier = container.read(scanSessionProvider.notifier);
    await notifier.capture('/path/to/image.jpg');

    final state = container.read(scanSessionProvider);
    expect(state, isA<ScanStateDone>());
  });
}
```

### Repository Testing Pattern

```dart
void main() {
  late MockOpenCvNativeService mockOpenCv;
  late ScannerRepositoryImpl repo;

  setUp(() {
    mockOpenCv = MockOpenCvNativeService();
    repo = ScannerRepositoryImpl(mockOpenCv);
  });

  test('returns notFound when no contour detected', () async {
    when(() => mockOpenCv.detectEdges(any(), any()))
        .thenAnswer((_) async => {'found': false});

    final result = await repo.detectEdges('/path/image.jpg');
    expect(result, isA<Success<EdgeDetectionResult>>());
    expect((result as Success).data.found, false);
  });
}
```

## Widget Tests

### What to Test

| Screen | Key Assertions |
|---|---|
| Home | Document list renders, empty state shows, pull-to-refresh works |
| Camera | Capture button visible, flash toggle works, preview placeholder |
| Crop | Drag handles move, confirm/cancel buttons work |
| Enhancement | Filter selector shows options, preview updates |
| PDF Preview | Page list renders, reorder works, export button enabled |

### Widget Test Pattern

```dart
void main() {
  testWidgets('home screen shows empty state when no documents', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          documentListProvider.overrideWith((_) async => []),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('Scan your first document'), findsOneWidget);
  });
}
```

## Integration Tests

### Critical Flows

| Flow | Steps | Verification |
|---|---|---|
| Scan to Save | Open camera → capture → crop → enhance → save | Document appears in home list |
| Scan to PDF | Scan → generate PDF → verify file exists | PDF file > 0 bytes, correct page count |
| Multi-page | Scan 3 pages → reorder → export PDF | PDF has 3 pages in new order |
| OCR | Scan text document → run OCR → copy text | Extracted text matches expected |
| Delete | Create document → delete → confirm | Document removed from list and DB |

### Integration Test Setup

```dart
// integration_test/scan_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete scan to PDF flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to camera
    await tester.tap(find.byKey(const Key('fab_scan')));
    await tester.pumpAndSettle();

    // ... interaction steps

    // Verify document saved
    expect(find.byType(DocumentCard), findsOneWidget);
  });
}
```

## Native Code Tests

| Platform | Framework | Scope |
|---|---|---|
| Android | JUnit 5 | `ImageProcessor` unit tests (corner sorting, contour validation) |
| iOS | XCTest | `ImageProcessor` unit tests |

```kotlin
// ImageProcessorTest.kt
@Test
fun `sortCorners returns TL-TR-BR-BL order`() {
    val unsorted = listOf(Point(100, 100), Point(0, 0), Point(100, 0), Point(0, 100))
    val sorted = processor.sortCorners(unsorted)
    assertEquals(Point(0, 0), sorted[0])     // TL
    assertEquals(Point(100, 0), sorted[1])   // TR
    assertEquals(Point(100, 100), sorted[2]) // BR
    assertEquals(Point(0, 100), sorted[3])   // BL
}
```

## Test Data

Store test fixtures in `test/fixtures/`:

```
test/
├── fixtures/
│   ├── images/
│   │   ├── document_straight.jpg      # Clean document photo
│   │   ├── document_skewed.jpg        # Perspective-distorted
│   │   ├── no_document.jpg            # Background only
│   │   └── low_quality.jpg            # Blurry/noisy
│   └── expected/
│       ├── edge_detection_result.json
│       └── ocr_result.json
```

## Coverage Target

| Layer | Target |
|---|---|
| Domain | 100% |
| Data (repos) | > 90% |
| Providers | > 85% |
| Widgets | > 70% (critical paths) |
| Integration | Top 5 user flows |
| Overall | > 80% |

## CI Test Execution

```yaml
# In GitHub Actions
- name: Run tests
  run: flutter test --coverage --reporter=github

- name: Check coverage
  run: |
    flutter test --coverage
    # Fail if below 80%
    lcov --summary coverage/lcov.info | grep -P 'lines.*: \d+' | awk '{if ($2 < 80) exit 1}'
```
