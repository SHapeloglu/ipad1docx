# TASKS.md

## Priority 0 — standalone migration validation
- [x] create dedicated repository
- [x] migrate bounded DOCX parser
- [x] migrate read-only reader UI
- [x] migrate CoreText renderer as standalone component
- [x] add `ipad1docx://open?path=...` receiver
- [x] add Theos armv7 / iOS 5.1 build files
- [ ] clean-build on legacy toolchain
- [ ] install on physical iPad 1
- [ ] open known CV DOCX
- [ ] verify A-/A+, search and Info
- [ ] repeat open/close and watch for slowdown/crash

## Priority 1 — routing cutover
- [ ] change iPad1Files `.docx` registration from `ipad1pdf` to `ipad1docx`
- [ ] verify percent-encoded spaces/Turkish paths
- [ ] verify missing/unsupported paths fail safely
- [ ] only after physical PASS, remove embedded DOCX code from iPad1PDFReader

## Priority 2 — DOCX v1 quality
- [ ] improve table readability without full Word layout
- [ ] better numbered-list semantics
- [ ] styles.xml feasibility for more reliable headings
- [ ] hyperlinks as readable text
- [ ] header/footer feasibility

## Deferred
- [ ] embedded images only after strict dimension/byte bounds and physical profiling
- [ ] legacy `.doc` only as separate text-extraction feasibility

## Never add
- Office/LibreOffice engine
- editing/save
- macros
- remote relationship fetching
- general ZIP/file-manager features
- OCR/AI/ML
