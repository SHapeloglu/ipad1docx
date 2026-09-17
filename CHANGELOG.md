# CHANGELOG.md

## Unreleased

### Added
- standalone `iPad1DOCXReader` application for iPad 1 / iOS 5.1.1
- `ipad1docx://open?path=...` URL handoff
- bounded DOCX ZIP reader
- raw deflate support through zlib
- `word/document.xml` extraction
- NSXMLParser-based text/style extraction
- basic bold, italic, heading, list and table-row semantics
- read-only search controls
- font-size controls
- file/path/size info view
- temporary device-side debug logging

### Verified on physical iPad 1
- standalone application launch
- URL scheme handoff
- percent-encoded space decoding on tested path
- file path resolution
- ZIP central-directory scan
- `word/document.xml` lookup
- deflate inflate
- NSXMLParser parse on a long DOCX

### In progress
- memory-safe long-document rendering
- virtualized/recycled CoreText page views

### Known issue
Long DOCX documents currently close the application after layout/render setup on the physical iPad 1. Parser stages complete successfully; renderer memory usage is the active investigation.

## 0.1.0
Initial standalone package identity and Theos application skeleton.