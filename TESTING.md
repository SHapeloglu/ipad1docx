# TESTING.md

Physical iPad 1 / iOS 5.1.1 is the source of truth.

## Build
```bash
make clean
rm -rf .theos packages
make package FINALPACKAGE=1
```
Required: armv7, iOS 5.1 target, legacy iPhoneOS 6.1 SDK, MRC.

## Open / routing
- [ ] app launches standalone
- [ ] `ipad1docx://open?path=...` opens existing `.docx`
- [ ] percent-encoded spaces decode correctly
- [ ] Turkish path characters decode correctly
- [ ] nonexistent path fails safely
- [ ] non-DOCX path is rejected

## Content
- [ ] paragraphs readable
- [ ] Turkish characters readable
- [ ] bold/italic visible
- [ ] headings visually distinct when derivable
- [ ] lists readable
- [ ] table rows keep useful field/value pairs on one line where possible
- [ ] empty/NBSP-only cells do not create repeated separators

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
- [ ] memory warning while reader is offscreen clears disposable rendered state

## Boundary
- [ ] no file-manager behavior
- [ ] no downloader
- [ ] no PDF engine
- [ ] no Office/LibreOffice runtime
- [ ] no OCR/AI/ML
