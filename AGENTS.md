# AGENTS.md

## Non-negotiable platform
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- legacy iPhoneOS 6.1 SDK

Do not raise the deployment target or introduce modern-only APIs for convenience.

## Scope
This repository is the DOCX-reading specialist for the iPad1 suite.

Allowed:
- format-specific DOCX ZIP/XML parsing required for reading
- lightweight read-only typography/layout
- search and font controls
- bounded image support only after physical profiling

Not allowed:
- general file management
- general ZIP/archive UI
- download manager
- PDF reader features
- media playback
- Office/LibreOffice engine
- edit/save
- OCR/AI/ML

## Physical validation rule
Build success is not runtime PASS. Only the physical iPad 1 can mark a feature PASS.

## Memory rule
Prefer streaming/bounded processing, release disposable objects aggressively, and never keep document-wide heavyweight caches.
