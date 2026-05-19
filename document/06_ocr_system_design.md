# OCR System Design — Google ML Kit

## Architecture

```
Processed Page Image
    │
    ▼
ML Kit Text Recognition API (on-device)
    │
    ▼
TextRecognitionResult
    │
    ├── extractedText (full string)
    ├── textBlocks[] (positioned paragraphs)
    │     ├── boundingBox
    │     ├── lines[]
    │     │     ├── text
    │     │     ├── boundingBox
    │     │     └── elements[] (words)
    │     └── recognizedLanguage
    └── confidence scores
    │
    ▼
Store in OCR_RESULTS table
    │
    ▼
Embed in searchable PDF
```

## Integration Strategy

### Package
```yaml
dependencies:
  google_mlkit_text_recognition: ^0.14.0
```

### Service Interface

```dart
abstract class OcrService {
  Future<OcrResult> recognizeText(String imagePath);
  void dispose();
}
```

### Implementation

```dart
class MlKitOcrService implements OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<OcrResult> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);

    return OcrResult(
      fullText: recognized.text,
      blocks: recognized.blocks.map(_mapBlock).toList(),
      language: _detectPrimaryLanguage(recognized.blocks),
    );
  }

  @override
  void dispose() => _recognizer.close();
}
```

## Data Model

```dart
class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;
  final String language;
}

class OcrBlock {
  final String text;
  final Rect boundingBox;        // normalized to image dimensions
  final List<OcrLine> lines;
  final double confidence;
}
```

## Processing Strategy

| Scenario | Approach |
|---|---|
| Single page scan | Process immediately after enhancement |
| Multi-page scan | Queue OCR; process pages sequentially in background |
| Re-edit (filter change) | Discard old OCR result; re-process |
| Batch OCR (existing docs) | Background isolate, one page at a time |

## Language Support (MVP)

ML Kit's on-device Latin script recognizer covers:
- English, Spanish, French, German, Italian, Portuguese, Vietnamese

For CJK/Devanagari: Use script-specific recognizers — add as V2 feature.

## Searchable PDF Integration

OCR text blocks with bounding boxes are embedded as an invisible text layer in the PDF:

```
PDF Page
├── Visible Layer: scanned image
└── Invisible Layer: positioned text blocks (selectable/searchable)
```

See `06_pdf_generation.md` for implementation details.

## Performance

| Metric | Target | Notes |
|---|---|---|
| OCR per page | < 4 sec | Per SRS requirement |
| Memory | < 50MB additional | ML Kit model is ~5MB |
| Accuracy | > 95% on printed text | Assumes good scan quality |

## Error Handling

| Error | Action |
|---|---|
| Image too blurry | Return partial result + quality warning |
| No text found | Return empty result (not an error) |
| ML Kit init failure | Retry once; if fail, mark OCR unavailable |
| Out of memory | Downscale image to 1024px, retry |
