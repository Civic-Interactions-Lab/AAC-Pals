# AAC Pals

iPad AAC (Augmentative and Alternative Communication) app for non-verbal children. Kids tap pictogram tiles to build sentences that are spoken aloud. Bluetooth beacons detect which room the iPad is in and add that room's words to the board. Caregivers sign in once to manage profiles, rooms, words, and beacons, and to review usage.

> **UI status:** rebuilding against the "AAC Sticker" design. Done: board (home) with the room panel (opens when a beacon room is detected, HIDE/reopen chip); settings with a tab sidebar: Words (grid size, read-only words) and Rooms & beacons (room list, live heard beacons, + New room: pick an unpaired beacon → name → create room paired to it). Login is a placeholder.

## Tech Stack

- **Swift + SwiftUI**, iPad only, landscape only, iOS 26.4+
- **Supabase** (`supabase-swift`): auth and data
- **CoreBluetooth**: beacon detection
- **AVFoundation**: text-to-speech
- **ARASAAC API**: pictogram images
- **Swift Charts**: analytics

## Build Configurations

The app is selected by scheme. Compile flags pick the service implementations in `Dependency` (`App/AAC_LocationAwareApp.swift`).

| Scheme | Flags | Services |
|---|---|---|
| `AAC-LocationAware-Mock` | `MOCK` | Mock services, auto signed in |
| `AAC-LocationAware-Dev` | `DEV` | Supabase |
| `AAC-LocationAware-Prod` | none | Supabase (TestFlight/App Store) |

## File Structure

```
AAC-LocationAware/
├── Core/         UI, one folder per screen: Views/ + Components/ (Boards/ = home board, Settings/, Shared/ = cross-screen pieces)
├── App/          Entry point, AppDelegate (landscape lock), Dependency wiring, AppView routing, Config (Supabase URL)
├── Services/     One folder per domain: Service/ (protocol + Mock + Supabase/real), Manager/ (@Observable), Model/
│   ├── Auth/         Caregiver sign in/up/out
│   ├── User/         Child profiles (name), active profile
│   ├── Admin/        Rooms, room words, beacons (CRUD)
│   ├── Beacon/       BLE scanning → current room
│   ├── Pictogram/    ARASAAC lookup, image cache, sentence state
│   ├── InteractionLog/  Word-tap logging, analytics
│   └── Speech/       SpeechManager (TTS)
├── Data/         AACVocabulary (default board words, core/room words, search aliases), FitzgeraldKey (category → colour asset)
├── Models/       Word, BoardGridSize
├── Extensions/   Color(hex:)
└── Assets.xcassets/Colors/  Sticker palette (Ink, Paper, Butter, ActionBlue, Category*); same in light and dark
```

## Architecture

- Managers are `@Observable`, created in `Dependency`, and injected with `.environment(...)`. Views read managers, never services.
- `AppView` routes by state: loading → not signed in (login) → signed in (board). The board is the home screen.
- Supabase tables: `user_profiles`, `rooms`, `room_words`, `beacons`, `interaction_logs`.
- `kCommonRoomId` (`"common"`) is the room shown when no beacon matches. `kActiveUserIdKey` stores the last active profile in UserDefaults.
- `kBoardGridSizeKey` stores the board grid size (`BoardGridSize`: Roomy 3 / Medium 5 / Tight 7 per row) locally via `@AppStorage`; the board and the Words tab read it.
- The project uses folder-synced groups: add or delete files on disk without editing `project.pbxproj`.

## Features

- **Board:** core-word grid plus the current room's words; tapping a tile adds it to the sentence and speaks it; play the full sentence; remove or clear words.
- **Room panel layout:** panel closed → `columns` per row (3/5/7). Panel open → panel gets `panelColumns` (1/2/3) and the main grid `panelColumns + 1` (2/3/4); one shared tile size fills the width so both line up. The board owns beacon scanning.
- **Room detection:** matches beacons by name or UUID above an RSSI threshold; falls back to `common` after 8s without a match; the board can override the room by hand.
- **Pictograms:** ARASAAC search with aliases and a last-word fallback; URLs and images cached; tiles coloured by Fitzgerald Key category.
- **Profiles:** caregiver creates, renames, and deletes child profiles.
- **Admin:** CRUD for rooms, room words, and beacons (with a live beacon scanner).
- **Analytics:** logs every word tap (user, room, word); totals, top words/rooms/users, recent activity.
