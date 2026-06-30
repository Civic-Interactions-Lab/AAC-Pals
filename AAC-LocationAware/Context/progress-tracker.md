# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

- In progress

## Current Goal

- Awaiting next feature spec.

## Completed

---

- 00 — Project scaffolding: Xcode project initialized, SwiftUI, iPad-only, landscape-locked, no SwiftData. Folder structure set up: `App/`, `Core/`, `Components/`, `Services/`, `Data/`, `Models/`, `Extensions/`, `Context/`. Context docs written (`project-overview.md`, `architecture.md`, `code-standards.md`, `ui-context.md`, `ai-workflow-rules.md`, `progress-tracker.md`).

---

- 01 — AAC Board: Full word grid board ported from React Native reference project. `Word` model (`Models/Word.swift`). Fitzgerald Key color system (`Data/FitzgeraldKey.swift`). Static vocabulary — core words and room word sets (`Data/AACVocabulary.swift`). ARASAAC pictogram fetch with search aliases and best-match scoring (`Services/Pictogram/PictogramService.swift`). In-memory image cache with prefetch on room load (`Services/Pictogram/ImageCache.swift`). `PictogramTile` — single word tile with Fitzgerald color, image, fallback letter. `PaginatedWordSection` — paginated column of tiles with prev/next arrows. `WordGrid` — two-column layout, core words left, room words right, tile size computed from GeometryReader. `SentenceBar` — fixed-height bar with word chips, Clear/Back/Speak buttons and TTS via AVSpeechSynthesizer. `BoardView` — root board screen wiring all components, prefetches images on appear and room change. Multiple named previews on every component.

---

## In Progress

- None.

## Next Up

1. Add Supabase Swift SDK via Swift Package Manager
2. Configure Supabase client (URL + anon key via environment or plist)
3. Build User Selector screen
4. Wire Supabase — fetch real rooms and words
5. Add CoreBluetooth beacon detection and room switching
6. Build admin panel — rooms, words, beacons, students
7. Add interaction logging and analytics
8. Add AI word suggestions

## Open Questions

- Which AI provider for word suggestions — Groq (llama) or Claude?
- Self-hosted suggestion server or direct API call from the app?
- ARASAAC pictogram disk cache strategy — currently URL cached in UserDefaults, images in memory only

## Architecture Decisions

- SwiftUI + Swift, iPad only — no React Native, no Android
- Landscape orientation locked at AppDelegate level + Info.plist
- Supabase as the sole persistent backend; UserDefaults for device settings only
- No SwiftData or CoreData — Supabase handles all data
- ARASAAC pictogram URLs cached in UserDefaults across launches; images cached in memory per session via `ImageCache` actor singleton

## Session Notes

- Reference project (React Native) lives at `/Users/jaime168/Local/project-professional-group-one-llc`
- Board is fully functional with static vocabulary — ready to wire Supabase for dynamic rooms/words
