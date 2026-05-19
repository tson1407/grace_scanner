# ScanFlow — Technical Documentation Index

## Documents

| # | Document | Description |
|---|---|---|
| — | [SRS](srd.md) | Software Requirements Specification (existing) |
| 01 | [Architecture Design](01_architecture_design.md) | Clean Architecture layers, native bridge, data flow, isolate strategy |
| 02 | [Project Structure](02_project_structure.md) | Full directory layout, naming conventions, feature module template |
| 03 | [State Management](03_state_management.md) | Riverpod provider taxonomy, state modeling, lifecycle, cross-feature comms |
| 04 | [Database Schema](04_database_schema.md) | Drift/SQLite ER diagram, table definitions, file storage layout, indexing |
| 05 | [Image Processing Pipeline](05_image_processing_pipeline.md) | OpenCV stages, algorithms, parameters, native API contracts, memory mgmt |
| 06 | [OCR System Design](06_ocr_system_design.md) | ML Kit integration, service interface, searchable PDF, error handling |
| 07 | [PDF Generation](07_pdf_generation.md) | PDF builder, OCR text layer, compression, page reorder, export |
| 08 | [Native Integration](08_native_integration.md) | Platform channels, CameraX/AVFoundation, OpenCV bridges, build config |
| 09 | [Technical Specifications](09_technical_specifications.md) | Dependencies, platform config, code gen, min versions, signing |
| 10 | [Security Design](10_security_design.md) | Threat model, data storage, permissions, analytics privacy, hardening |
| 11 | [Performance Optimization](11_performance_optimization.md) | Startup, image processing, memory, UI, low-end device strategy |
| 12 | [Testing Strategy](12_testing_strategy.md) | Test pyramid, unit/widget/integration patterns, coverage targets |
| 13 | [CI/CD](13_cicd.md) | GitHub Actions workflows, secrets, branch strategy, deployment |
| 14 | [Roadmap](14_roadmap.md) | 8-phase implementation plan with tasks, acceptance criteria, timeline |
| 15 | [AI Agent Guidelines](15_ai_agent_guidelines.md) | Coding rules, patterns, anti-patterns, checklists for AI agents |

## Reading Order

**For new contributors**: SRS → 01 → 02 → 15 → start coding.

**For AI agents**: SRS → 15 (guidelines) → 14 (roadmap) → relevant technical doc for current phase.
