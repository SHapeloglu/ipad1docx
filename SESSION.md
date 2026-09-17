# SESSION.md

## Project
`iPad1DOCXReader` — dedicated lightweight read-only DOCX reader for the original iPad 1.

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

Canonical shared storage remains under:
```text
/var/mobile/Media/iPad1Files
```

## Migrated core
Migrated from the physically working DOCX path that had been embedded in iPad1PDFReader:
- DOCX package read via bounded ZIP central-directory scan;
- only `word/document.xml` is inflated/read;
- store/deflate only;
- compressed file guard: 8 MiB;
- main XML guard: 4 MiB;
- NSXMLParser streaming parse;
- plain text + bounded style ranges;
- bold / italic / basic heading;
- basic bullets;
- simple table row rendering with `│` separators;
- empty/NBSP-only table cells suppressed;
- CoreText rendering;
- A-/A+;
- Find / Next / Previous;
- Info path/size;
- read-only only.

## Current status
Source has been migrated to this repository, but the standalone app has NOT yet been clean-built or physically tested. Do not mark standalone runtime PASS until it is installed and opened on the physical iPad 1.

The previous embedded DOCX implementation in iPad1PDFReader remains a temporary fallback until this standalone app passes physical testing.

## Immediate next action
1. Clone/pull `SHapeloglu/ipad1docx`.
2. Clean build with Theos legacy SDK.
3. Fix compile/MRC issues only; do not raise target.
4. Install on physical iPad 1.
5. Open the known CV DOCX through `ipad1docx://open?path=...`.
6. After physical PASS, change iPad1Files `.docx` registry from `ipad1pdf` to `ipad1docx`.
7. Only after routing PASS, remove DOCX code/routing from iPad1PDFReader.

## Build
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```

Expected package name:
```text
packages/com.olap.ipad1docxreader_0.1.0_iphoneos-arm.deb
```
