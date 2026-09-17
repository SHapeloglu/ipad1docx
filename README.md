# iPad1DOCXReader

Lightweight read-only DOCX reader for the original iPad 1.

Target platform:
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / MRC
- Theos / legacy iPhoneOS 6.1 SDK

Open contract:

```text
ipad1docx://open?path=<percent-encoded-absolute-path>
```

Scope: readable DOCX content, not Microsoft Word layout fidelity. The app parses only the DOCX parts required for reading and keeps strict memory/file-size bounds.

Current migrated core:
- bounded DOCX ZIP reader (`word/document.xml` only)
- NSXMLParser text/style extraction
- paragraphs and line breaks
- basic bold / italic / heading styles
- simple lists
- lightweight table rows with empty-cell suppression
- CoreText rendering
- A- / A+
- Find / Next / Previous
- file info

Out of scope: editing, save, macros, remote relationships, Office/LibreOffice engine, OCR, AI/ML, general ZIP/file-manager features.
