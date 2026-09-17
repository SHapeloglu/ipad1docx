# TASKS.md

## Priority 0 — make long DOCX rendering stable
- [x] create dedicated repository
- [x] migrate bounded DOCX parser
- [x] migrate read-only reader UI
- [x] add `ipad1docx://open?path=...` receiver
- [x] clean-build on legacy toolchain
- [x] install and launch on physical iPad 1
- [x] physically verify URL handoff
- [x] physically verify ZIP lookup / inflate / XML parse
- [x] identify giant full-document render surface as a memory risk
- [x] replace single giant render surface with paged CoreText design
- [x] constrain parent renderer container to viewport height locally
- [ ] wire virtualized page-window updates to scrolling
- [ ] keep only about 3–5 live page views
- [ ] physically re-test long DOCX (`Les Miresables.docx`)
- [ ] verify app remains open and document text is visible
- [ ] verify scrolling through beginning / middle / end without crash

## Priority 1 — reader controls after render stability
- [ ] A-/A+ reflows virtualized pages safely
- [ ] Find / Next / Previous scrolls to correct virtual page
- [ ] Info shows file/path/size
- [ ] rotation relayout is stable
- [ ] repeated open/close has no progressive slowdown

## Priority 2 — routing cutover
- [ ] change iPad1Files `.docx` registration from `ipad1pdf` to `ipad1docx`
- [ ] verify percent-encoded spaces through iPad1Files
- [ ] verify Turkish/Unicode paths
- [ ] verify missing/unsupported paths fail safely
- [ ] only after physical PASS, remove embedded DOCX code/routing from iPad1PDFReader

## Priority 3 — DOCX v1 quality
- [ ] improve table readability without full Word layout
- [ ] better numbered-list semantics
- [ ] evaluate `styles.xml` for more reliable headings
- [ ] hyperlinks as readable text
- [ ] header/footer feasibility

## Release hygiene
- [ ] remove or compile out verbose `/var/mobile/Media/iPad1Files/ipad1docx-debug.log` diagnostics
- [ ] update README with verified feature list
- [ ] update CHANGELOG for first stable beta

## Never add
- Office/LibreOffice engine
- editing/save
- macros
- remote relationship fetching
- general ZIP/file-manager features
- OCR/AI/ML