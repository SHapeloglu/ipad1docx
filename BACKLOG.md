# BACKLOG.md

Items here are intentionally deferred. They are not part of the current stability milestone.

## DOCX fidelity
- richer numbered-list semantics
- more complete `styles.xml` interpretation
- header/footer reading
- hyperlink display and optional safe handoff
- improved table readability without implementing full Word layout
- section/page-break semantics if they can remain lightweight

## Images
Consider embedded images only after the text renderer is physically stable.

Required before implementation:
- strict compressed/uncompressed byte limits
- strict pixel-dimension limits
- downsampling strategy compatible with iOS 5.1.1
- no document-wide image cache
- physical iPad 1 memory profiling

## Navigation
- lightweight document outline derived from headings
- optional last-read position
- optional recent-document list only if ownership does not conflict with iPad1Files

## Inter-app integration
- callback URL contract after successful handoff
- stronger iPad1Files routing integration
- graceful fallback when DOCXReader is not installed

## Format feasibility
- legacy `.doc` text extraction feasibility as a separate, bounded investigation

Do not add Office/LibreOffice, editing/save, macros, general archive management, OCR, AI or ML.