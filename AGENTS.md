# AGENTS.md

## Non-negotiable platform
- iPad 1 / Apple A4 / 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- legacy iPhoneOS 6.1 SDK

Do not raise the deployment target or introduce modern-only APIs for convenience.

## Scope
This repository is the DOCX-reading specialist for the iPad1 suite.

Allowed:
- format-specific DOCX ZIP/XML parsing required for reading
- lightweight read-only typography/layout
- search and font controls
- bounded image support only after physical profiling

Not allowed:
- general file management
- general ZIP/archive UI
- download manager
- PDF reader features
- media playback
- Office/LibreOffice engine
- edit/save
- OCR/AI/ML

## Suite ownership rule
Every application remains a specialist. If another suite app owns a capability, use URL handoff/callback instead of reimplementing that subsystem here.

Current routing contract:
```text
ipad1docx://open?path=<percent-encoded absolute path>
```

## Physical validation rule
Build success is not runtime PASS. Only the physical iPad 1 can mark a feature **PHYSICAL PASS**.

Use these terms consistently:
- COMPILE PASS
- PHYSICAL PASS
- FAIL
- PENDING

Never mark a feature PASS from simulator assumptions, code inspection or successful compilation alone.

## Memory rule
The 256 MB device limit dominates architecture decisions.

Required behavior:
- prefer streaming/bounded processing;
- release disposable objects aggressively;
- never keep document-wide heavyweight caches;
- never create a full-document-height backing store;
- never instantiate all long-document page views at once;
- virtualize/recycle expensive render views;
- keep live CoreText page views to a small visible window, roughly 3–5 when possible;
- treat memory warnings as first-class behavior, not an edge case.

## Change discipline
Before editing:
1. read `SESSION.md`;
2. read `ARCHITECTURE.md`;
3. read `TASKS.md`;
4. read `TESTING.md`;
5. check `git status -sb` so local device-debug changes are not overwritten.

When physical testing changes a known fact, update `SESSION.md` and `TESTING.md` in the same work session.

## Debugging rule
Prefer lightweight file logging over adding heavyweight runtime tooling on the device. Current temporary debug path:
```text
/var/mobile/Media/iPad1Files/ipad1docx-debug.log
```
Remove or compile out verbose diagnostics before release.