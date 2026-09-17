# ARCHITECTURE.md

## Goal
Provide the lightest practical DOCX reading experience for iPad 1 / iOS 5.1.1 without attempting desktop Word fidelity.

## Components
```text
AppDelegate
  -> receives ipad1docx://open?path=...
  -> pushes DocumentReaderViewController

DocumentReaderViewController
  -> file guards / controls / search
  -> DOCXReader
  -> DocumentRichTextView

DOCXReader
  -> bounded ZIP central directory scan
  -> word/document.xml only
  -> NSXMLParser streaming extraction

DocumentRichTextView
  -> CoreText rendering
  -> no WebView / HTML / JavaScript
```

## Memory guards
- compressed DOCX <= 8 MiB
- `word/document.xml` <= 4 MiB
- style ranges <= 4096
- no whole-package extraction
- no image cache
- no background index
- no remote relationship fetch

## Supported v1 semantics
- paragraphs / line breaks
- bold / italic
- basic headings
- simple list indication
- simple tables flattened into readable rows
- empty/NBSP-only cells removed from visual separators

## Explicit non-goals
- editing/save
- tracked changes/comments editor
- pixel-perfect pagination
- full Word styles/theme engine
- macros
- Office/LibreOffice SDK
- general ZIP browser
- OCR / AI / ML

## Suite boundary
`iPad1Files` owns browsing, copy/move/rename/delete and file routing. `iPad1DOCXReader` receives a path and reads the same physical file in-place.
