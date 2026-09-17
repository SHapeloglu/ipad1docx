# SESSION.md

## Project
`iPad1DOCXReader` — dedicated lightweight, read-only DOCX reader for the original iPad 1.

Repository: `SHapeloglu/ipad1docx`
Branch: `main`

## Immutable target
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- legacy iPhoneOS 6.1 SDK

```make
ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
```

## Ownership
This app owns DOCX reading only. It must not become a general file manager, archive manager, downloader, media player, terminal, or PDF reader.

Suite routing:
```text
.docx -> iPad1Files -> ipad1docx://open?path=<encoded absolute path> -> iPad1DOCXReader
```

Canonical shared storage:
```text
/var/mobile/Media/iPad1Files
```

## Current physical status
- Standalone application launch: **PHYSICAL PASS**
- `ipad1docx://open?path=...` URL handoff: **PHYSICAL PASS**
- Percent-encoded spaces in tested path: **PHYSICAL PASS**
- File existence/path validation: **PHYSICAL PASS**
- DOCX ZIP central-directory scan: **PHYSICAL PASS**
- `word/document.xml` lookup: **PHYSICAL PASS**
- raw deflate inflate via zlib: **PHYSICAL PASS**
- NSXMLParser parse on long test DOCX: **PHYSICAL PASS**
- parser output on test file: 77,740 text chars / 898 style ranges
- long-document display: **FAIL — app closes after layout/render setup**

Known test file:
```text
/var/mobile/Media/iPad1Files/PDFs/Les Miresables.docx
```
Test file size observed on device: 97,844 bytes.
Inflated `word/document.xml`: 1,498,378 bytes.

## Current renderer diagnosis
The original renderer created one very tall CoreText view. Physical logging showed a calculated content height around 85k–90k px, which is unsuitable for the 256 MB iPad 1 memory budget.

A first paged renderer split content into roughly 900 px page views, but still instantiated all page views up front. The parent view was then constrained to viewport height, yet the app still closed after layout. Current direction is therefore true virtualization/recycling: compute all page ranges, but keep only a small visible window of page views alive.

## Repository vs local working tree
Repository `main` now contains the virtualized `DocumentRichTextView` work in progress.

The developer workstation currently has a local modification to:
```text
DocumentReaderViewController.m
```
This local change contains viewport/layout diagnostics and must not be overwritten accidentally.

Before continuing, run:
```bash
git status -sb
```
and preserve that local modification while pulling or wiring the virtualized renderer.

## Immediate next action
1. Pull latest `main` while preserving local `DocumentReaderViewController.m` changes.
2. Wire the controller/scroll view to the virtualized renderer update method.
3. Keep only a small visible page window alive (target: about 3–5 views).
4. Clean build.
5. Install on the physical iPad 1.
6. Re-test `Les Miresables.docx`.
7. Only after long-document display is physically stable, test A-/A+, search, rotation and repeated open/close.
8. Only after standalone routing/display PASS, switch iPad1Files `.docx` routing from PDFReader to DOCXReader.
9. Only after iPad1Files cutover PASS, remove embedded DOCX fallback code from iPad1PDFReader.

## Build
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```

Expected package:
```text
packages/com.olap.ipad1docxreader_0.1.0_iphoneos-arm.deb
```

## Debug log
Temporary diagnostics currently write to:
```text
/var/mobile/Media/iPad1Files/ipad1docx-debug.log
```
Remove or compile out verbose logging before a release build.