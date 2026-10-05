# CLAUDE.md — iPad1DOCXReader (ipad1docx)

Lightweight **read-only DOCX reader** for the original **iPad 1 (A4, 256 MB RAM, iOS 5.1.1, armv7)** — Objective-C, **MRC/non-ARC**, Theos + legacy iPhoneOS 6.1 SDK. Goal is readable content, not Word layout fidelity: bounded ZIP reader (`word/document.xml` only) → NSXMLParser text/style extraction (paragraphs, breaks, bold/italic/headings, simple lists, lightweight tables) → CoreText rendering, A-/A+, Find/Next/Previous, file info. Package `com.olap.ipad1docxreader` **0.1.0** (`control`).

- GitHub: https://github.com/SHapeloglu/ipad1docx
- Read first: `AGENTS.md` (platform + scope, authoritative) → `ARCHITECTURE.md` → `TASKS.md` → `SESSION.md` → `TESTING.md` → `BACKLOG.md` / `CHANGELOG.md`.
- Open contract: `ipad1docx://open?path=<percent-encoded-absolute-path>` (called by iPad1Files).

## Current priority (TASKS.md)

P0 — make long DOCX rendering stable: virtualized page window wired to scrolling, only ~3–5 live page views, physical re-test with a long document (beginning/middle/end without crash). Then P1 reader controls on virtualized pages → P2 routing cutover (iPad1Files `.docx` → `ipad1docx` instead of `ipad1pdf`; remove embedded DOCX code from iPad1PDFReader only after physical PASS) → P3 quality.

## Build

```bash
make clean && make package FINALPACKAGE=1      # ARCHS=armv7, TARGET=iphone:clang:6.1:5.1, -fno-objc-arc
```

Install over SSH with legacy `ssh-rsa` options (same as other iPad1 apps).

## Rules (AGENTS.md)

- Don't raise the deployment target or add modern-only APIs.
- In scope: format-specific DOCX ZIP/XML parsing, lightweight read-only typography, search, font controls; images only after physical profiling.
- **Not allowed:** general file management, general ZIP/archive UI, download manager, PDF features, media playback, Office/LibreOffice engine, editing/saving.
- Keep strict memory/file-size bounds; never build whole-document bitmaps.
- Physical-device PASS is the definition of done; record results in `SESSION.md` and `TESTING.md`.
