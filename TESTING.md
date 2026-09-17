# TESTING.md

Physical iPad 1 / iOS 5.1.1 is the source of truth.

Status vocabulary:
- **COMPILE PASS**: builds successfully only.
- **PHYSICAL PASS**: verified on the real iPad 1.
- **FAIL**: physically reproduced failure.
- **PENDING**: not yet physically verified.

## Build
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```
Required: armv7, iOS 5.1 target, legacy iPhoneOS 6.1 SDK, MRC.

Current build status: **COMPILE PASS**.

## Open / routing
- [x] standalone app launches — **PHYSICAL PASS**
- [x] `ipad1docx://open?path=...` reaches the app — **PHYSICAL PASS**
- [x] tested percent-encoded spaces decode correctly — **PHYSICAL PASS**
- [ ] Turkish/Unicode path characters — **PENDING**
- [ ] nonexistent path fails safely — **PENDING**
- [ ] non-DOCX path is rejected — **PENDING**

## Parser pipeline
Tested with:
```text
/var/mobile/Media/iPad1Files/PDFs/Les Miresables.docx
```

Observed physical diagnostics:
- compressed file size: 97,844 bytes
- central directory found
- `word/document.xml` found
- compression method: deflate
- inflated XML size: 1,498,378 bytes
- NSXMLParser result: success
- extracted text: 77,740 chars
- style ranges: 898

Status:
- [x] ZIP central-directory scan — **PHYSICAL PASS**
- [x] document.xml extraction — **PHYSICAL PASS**
- [x] zlib raw inflate — **PHYSICAL PASS**
- [x] NSXMLParser parse — **PHYSICAL PASS**

## Rendering
- [x] parser result reaches renderer — **PHYSICAL PASS**
- [x] full document height can be calculated — **PHYSICAL PASS**
- [ ] long DOCX remains open and visible — **FAIL**
- [ ] beginning/middle/end scrolling — **PENDING**
- [ ] virtualized 3–5 live page window — **PENDING PHYSICAL TEST**

Known failure diagnostics:
```text
content height observed: ~85k–90k px
```
The initial giant-view renderer and the first all-pages-at-once paged renderer both closed on the physical iPad 1 after layout/render setup.

## Content quality
- [ ] paragraphs readable — **PENDING standalone render stability**
- [ ] Turkish characters readable — **PENDING**
- [ ] bold/italic visible — **PENDING**
- [ ] headings visually distinct — **PENDING**
- [ ] lists readable — **PENDING**
- [ ] table rows keep useful field/value pairs on one line where possible — **PENDING standalone**
- [ ] empty/NBSP-only cells do not create repeated separators — **PENDING standalone**

## Controls
- [ ] A-/A+ bounded and stable
- [ ] Find / Next / Previous works
- [ ] not-found message safe
- [ ] Info shows file/path/size
- [ ] rotation/relayout does not crash

## Safety limits
- [ ] >8 MiB compressed DOCX rejected before full parse
- [ ] >4 MiB `word/document.xml` rejected
- [ ] encrypted DOCX rejected
- [ ] unsupported compression rejected
- [ ] malformed ZIP/XML fails visibly without crash

## Stability
- [ ] open/close same DOCX 20 times
- [ ] open several DOCX files sequentially
- [ ] A+/A- repeatedly
- [ ] repeated search
- [ ] no progressive slowdown or crash
- [ ] memory warning while reader is offscreen clears disposable state

## Boundary
- [x] no file-manager behavior
- [x] no downloader
- [x] no PDF engine
- [x] no Office/LibreOffice runtime
- [x] no OCR/AI/ML

Do not convert any pending item to PASS without a physical-device test.