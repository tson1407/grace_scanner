# ScanFlow — Flutter Document Scanner App

## Overview

A modern CamScanner-like mobile application focused on:

- perfect document capture
- accurate edge detection
- perspective correction
- fast PDF generation
- offline-first architecture
- smooth mobile UX

Primary target:
- Android first
- iOS second

---

# Core Tech Stack

## Frontend
- Flutter
- Dart
- Riverpod
- GoRouter

## Native Layer
### Android
- Kotlin
- CameraX

### iOS
- Swift
- AVFoundation

## Image Processing
- OpenCV

## OCR
- Google ML Kit OCR

## Local Storage
- SQLite
- Drift ORM

## PDF
- pdf package
- printing package

## Analytics
- PostHog

## Crash Monitoring
- Firebase Crashlytics

---

# Architecture

```text
Flutter UI
    ↓
Application Layer
    ↓
Domain Layer
    ↓
Native Processing Layer
    ↓
OpenCV / Camera / OCR
```

---

# Folder Structure

```text
lib/
 ├── core/
 ├── shared/
 ├── features/
 │    ├── camera/
 │    ├── scanner/
 │    ├── pdf/
 │    ├── ocr/
 │    ├── storage/
 │    └── settings/
 └── main.dart
```

---

# Main Features

## MVP

### Scanner
- camera preview
- auto capture
- manual capture
- multi-page scan
- flash toggle

### Document Detection
- auto edge detection
- contour detection
- perspective correction
- manual crop adjustment

### Image Enhancement
- grayscale
- black & white
- adaptive threshold
- shadow cleanup
- sharpen text

### PDF
- generate PDF
- multi-page PDF
- compress PDF
- reorder pages
- export/share PDF

### Storage
- local save
- thumbnails
- rename/delete documents

### OCR
- offline OCR
- searchable PDFs
- copy text

---

# Camera Pipeline

```text
Camera Preview
→ Capture
→ Edge Detection
→ Perspective Transform
→ Image Enhancement
→ OCR
→ PDF Generation
→ Local Storage
```

---

# OpenCV Processing Pipeline

```text
Image
→ grayscale
→ denoise
→ edge detection
→ contour detection
→ perspective transform
→ enhancement
→ export
```

---

# Performance Targets

| Metric | Target |
|---|---|
| App startup | < 1.5 sec |
| Scan processing | < 2 sec |
| PDF export | < 5 sec |
| Scroll FPS | 60 FPS |
| OCR/page | < 4 sec |

---

# Important Engineering Decisions

## Use Flutter for:
- UI
- navigation
- gestures
- animations
- storage flow

## Use Native Code for:
- OpenCV
- heavy image processing
- camera optimization
- memory-heavy tasks

Reason:
Pure Flutter image processing becomes unstable with high-resolution images.

---

# State Management

## Riverpod

Reason:
- scalable
- testable
- async friendly
- clean dependency injection

Avoid:
- GetX
- overly global state

---

# Offline-First Strategy

Core features must work offline:
- scanning
- PDF generation
- OCR
- local search
- export/share

No mandatory login.

---

# Security Principles

- local-first
- no forced uploads
- minimum telemetry
- explicit permissions only

---

# CI/CD

## GitHub Actions

Pipeline:
```text
Lint
→ Unit Tests
→ Build
→ Integration Tests
→ Beta Deploy
```

Deployment:
- Google Play Internal Testing
- TestFlight

---

# Milestones

## Phase 1 — Foundation
- Flutter setup
- architecture
- Riverpod
- navigation
- CI/CD

## Phase 2 — Camera
- camera preview
- capture flow
- multi-page support

## Phase 3 — Detection
- edge detection
- contour detection
- perspective correction

## Phase 4 — Enhancement
- filters
- shadow cleanup
- adaptive threshold

## Phase 5 — PDF
- PDF generation
- compression
- export/share

## Phase 6 — Storage
- local database
- thumbnails
- document history

## Phase 7 — OCR
- text extraction
- searchable PDFs

## Phase 8 — Optimization
- memory optimization
- low-end Android support
- performance testing

---

# Technical Risks

## Android Fragmentation
Different camera behavior across OEMs.

Mitigation:
- test Samsung/Xiaomi/Oppo/Pixel

## Memory Pressure
Large images can crash app.

Mitigation:
- isolates
- compression
- native processing

## OpenCV Integration
Platform-specific native bugs.

Mitigation:
- isolate native layer

---

# Future Features

## V2
- cloud sync
- account system
- document search

## V3
- AI extraction
- invoice parsing
- smart naming
- receipt detection

---

# Recommended Team

## Minimum
- 1 Flutter engineer
- 1 mobile/native engineer
- 1 QA

## Ideal
- 2 Flutter engineers
- 1 CV/OpenCV engineer
- 1 QA
- 1 designer

---

# Final Goal

Build a scanner app that is:
- extremely fast
- lightweight
- offline-first
- privacy-focused
- professional-quality
- optimized for mobile devices