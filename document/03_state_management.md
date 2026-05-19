# State Management — Riverpod Strategy

## Provider Taxonomy

| Provider Type | Use Case | Example |
|---|---|---|
| `Provider` | Static/computed values, repo instances | `documentRepositoryProvider` |
| `FutureProvider` | One-shot async data | `documentListProvider` |
| `StreamProvider` | Reactive data streams | `cameraFrameStreamProvider` |
| `NotifierProvider` | Mutable state with logic | `scanSessionProvider` |
| `AsyncNotifierProvider` | Mutable state with async operations | `pdfExportProvider` |

## State Modeling

Use `freezed`-generated sealed classes for complex states:

```dart
@freezed
sealed class ScanState with _$ScanState {
  const factory ScanState.idle() = _Idle;
  const factory ScanState.capturing() = _Capturing;
  const factory ScanState.processing({required double progress}) = _Processing;
  const factory ScanState.done({required List<ScannedPage> pages}) = _Done;
  const factory ScanState.error({required AppError error}) = _Error;
}
```

For simpler states, use plain data classes — don't over-engineer.

## Provider Organization Per Feature

```dart
// features/scanner/presentation/scanner_provider.dart

// 1. Repository provider (injected via override in tests)
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl(ref.read(openCvNativeServiceProvider));
});

// 2. State notifier for the scan session
final scanSessionProvider =
    NotifierProvider<ScanSessionNotifier, ScanState>(ScanSessionNotifier.new);

// 3. Derived/computed providers
final currentPageCountProvider = Provider<int>((ref) {
  final state = ref.watch(scanSessionProvider);
  return switch (state) {
    ScanStateDone(:final pages) => pages.length,
    _ => 0,
  };
});
```

## Cross-Feature Communication

Features never import each other's internals. Shared state flows through providers:

```
camera_provider ──emits frame──→ scanner_provider ──emits pages──→ pdf_provider
                                                                        │
                                                  storage_provider ◄────┘
```

Mechanism: Downstream providers `ref.watch()` upstream providers.

## Lifecycle Management

| Concern | Strategy |
|---|---|
| Camera resources | `ref.onDispose()` to release CameraX/AVFoundation |
| Scan session | `AutoDisposeNotifier` — cleared when user leaves scan flow |
| Document list | `keepAlive` — persists across navigation |
| PDF generation | `AutoDispose` — freed after export completes |

## Provider Scoping

```dart
// main.dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Override for testing or flavor-specific implementations
      ],
      child: const ScanFlowApp(),
    ),
  );
}
```

## State Persistence

Transient state (scan session, camera mode) → Riverpod only, not persisted.
Persistent state (documents, settings) → Drift DB, surfaced via providers.

```
User Action → Provider → Repository → Drift DB
                                          ↓
                          Provider watches → UI rebuilds
```

## Rules for AI Agents

1. **One provider file per feature** — don't scatter providers.
2. **Always use `ref.watch()` for reactive UI** — never `ref.read()` inside `build()`.
3. **Use `ref.read()` only in callbacks** (button taps, lifecycle hooks).
4. **Prefer `AsyncNotifier` over `StateNotifier`** — it's the modern Riverpod pattern.
5. **Test providers in isolation** by overriding dependencies in `ProviderContainer`.
