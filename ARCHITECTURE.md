# ARCHITECTURE.md

## Goal
Provide the lightest practical DOCX reading experience for iPad 1 / iOS 5.1.1 without attempting desktop Word fidelity.

## Components
```text
AppDelegate
  -> receives ipad1docx://open?path=...
  -> validates path/extension
  -> pushes DocumentReaderViewController

DocumentReaderViewController
  -> file guards / controls / search
  -> owns UIScrollView and toolbar
  -> DOCXReader
  -> DocumentRichTextView

DOCXReader
  -> bounded ZIP central-directory scan
  -> reads only word/document.xml
  -> zlib store/deflate support
  -> NSXMLParser streaming extraction
  -> plain text + bounded style ranges

DocumentRichTextView
  -> CoreText attributed-string framesetter
  -> page-range calculation
  -> virtualized small page-view window
  -> no WebView / HTML / JavaScript
```

## URL contract
Primary open contract:
```text
ipad1docx://open?path=<percent-encoded absolute path>
```

The reader opens the original file in place. It does not copy, move or own the file lifecycle.

## Shared storage boundary
Canonical shared storage remains under:
```text
/var/mobile/Media/iPad1Files
```

`iPad1Files` owns browsing, copy/move/rename/delete and file routing. `iPad1DOCXReader` only receives a path and reads the DOCX.

## Memory architecture
The iPad 1 has only 256 MB RAM. The renderer must therefore avoid document-height backing stores and document-wide live page views.

Required rules:
- compressed DOCX <= 8 MiB
- `word/document.xml` <= 4 MiB
- style ranges <= 4096
- no whole-package extraction
- no image cache in v1
- no background index
- no remote relationship fetch
- no single giant render view sized to full document height
- page geometry may be precomputed, but only a small visible page window should own live `UIView` instances
- target live render window: about 3–5 page views
- release offscreen page views aggressively

## Renderer flow
```text
DOCXReader
  -> plainText + styles
  -> DocumentRichTextView builds one CTFramesetter
  -> calculate page character ranges with CTFrameGetVisibleStringRange
  -> keep lightweight range metadata for the full document
  -> instantiate only visible/near-visible IP1DOCXPageView objects
  -> recycle/remove page views as scrolling changes
```

This architecture intentionally separates:
- document metadata/ranges: cheap and persistent;
- CoreText framesetter: one shared object;
- page views/backing stores: expensive and virtualized.

## Supported v1 semantics
- paragraphs / line breaks
- bold / italic
- basic headings
- simple list indication
- simple tables flattened into readable rows
- empty/NBSP-only cells removed from visual separators
- read-only search and font-size controls

## Explicit non-goals
- editing/save
- tracked changes/comments editor
- pixel-perfect Word pagination
- full Word styles/theme engine
- macros
- Office/LibreOffice SDK/runtime
- general ZIP browser
- OCR / AI / ML

## Suite ownership rule
Every app remains a specialist. If another suite capability is needed, use URL handoff/callback rather than copying that subsystem into this app.