# AAC Pals

iPad AAC (Augmentative and Alternative Communication) app for non-verbal children. Kids tap pictogram tiles to build sentences that are spoken aloud. Bluetooth beacons detect which room the iPad is in and add that room's words to the board. Caregivers sign in once to manage profiles, rooms, words, and beacons, and to review usage.

> **UI status:** built to the "AAC Board" Xcode handoff (iPad landscape, 1194×834 design canvas). Board: cream top bar (profile chip, room pill, ⚙), sentence row (chips, DELETE / CLEAR / SPEAK), always-visible 366pt room panel + main board. Settings: Words (tile size, read-only board words), Rooms & beacons (rooms → Room edit, heard beacons → "Use it" → New room), Voice (system English voices, rate/pitch/volume, speak each tap), Profiles (switch / new). Sign in screen.

## Tech Stack

- **Swift + SwiftUI**, iPad only, landscape only, iOS 26.4+
- **Supabase** (`supabase-swift`): auth, child profiles, tap logs. Everything else is stored on the iPad
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
│   ├── Admin/        Rooms, room words, beacon pairings (CRUD, stored on the iPad via LocalAdminService)
│   ├── Beacon/       BLE scanning → current room
│   ├── Pictogram/    ARASAAC lookup, image cache, sentence state
│   ├── InteractionLog/  Word-tap logging, analytics
│   └── Speech/       SpeechManager (TTS)
├── Data/         AACVocabulary (default board words, core/room words, search aliases), FitzgeraldKey (category → colour asset)
├── Models/       Word, BoardGridSize, VoiceSettings (UserDefaults keys + defaults)
├── Extensions/   Color(hex:), Font.fredoka / Font.figtree (registers bundled fonts on first use)
├── Resources/Fonts/  Fredoka + Figtree variable TTFs (SIL OFL licences alongside)
├── Pictograms.xcassets/  Bundled ARASAAC pictograms `pic-<word>`; PictogramImage checks these before the API
└── Assets.xcassets/Colors/  Palette (Ink, Paper, Butter = cream, ActionBlue, SignalGreen = mint, Category*); use `.signalGreen`, not `.mint` (clashes with SwiftUI)
```

## Architecture

- Managers are `@Observable`, created in `Dependency`, and injected with `.environment(...)`. Views read managers, never services.
- `AppView` routes by state: loading → not signed in (login) → signed in (board). The board is the home screen.
- Supabase tables: `user_profiles` and `interaction_logs` only. Each log points to a child (`user_id` → `user_profiles.id`) and records word, category, board section, room id/label, matched beacon id/RSSI, and device details. Schema change: `supabase/migrations/20261105_interaction_logs_details.sql`.
- Stored on the iPad (UserDefaults): rooms, room words and beacon pairings (`LocalAdminService`, seeded with mock rooms in the Mock scheme), each child's board words and the caregiver's My default set (`LocalBoardWordsService`), voice settings, tile size, last active profile.
- `kCommonRoomId` (`"common"`) is the room shown when no beacon matches. `kActiveUserIdKey` stores the last active profile in UserDefaults.
- `kBoardGridSizeKey` stores the tile density (`BoardGridSize`: Standard = panel 2 / board 4 across; Roomy = 1 / 2) via `@AppStorage`. `BoardContent` sizes one shared tile width from the screen width so the room card takes 1/3 and the main card 2/3; tile height = width × `tileAspect`.
- Shared design pieces live in `Core/Shared/Components/Sticker.swift` (`.sticker()`, `StickerPressStyle`, `PillButton`, `SectionLabel`, `Caption`, `AvatarCircle`…).
- The project uses folder-synced groups: add or delete files on disk without editing `project.pbxproj`.

## Features

- **Board:** core-word grid plus the current room's words; tapping a tile adds it to the sentence and speaks it; play the full sentence; remove or clear words.
- **Board layout:** room words (left 1/3) and main words (right 2/3) each sit on a cream `BoardCard`; the room card shows a dashed wifi-off placeholder when no room is detected. The main board never changes. The board owns beacon scanning.
- **Room detection:** each paired beacon's RSSI is smoothed per room. Strongest room ≥ -70 wins; the current room is kept while ≥ -85 and only replaced when another room is 6 dB stronger. A room is dropped 8s after its last reading (checked every second). The CoreBluetooth scan restarts every 4s so iOS keeps reporting readings steadily. RSSI 127 ("unavailable") is ignored. Pairing changes reload into `BeaconManager` automatically.
- **Pictograms:** ARASAAC search with aliases and a last-word fallback; URLs and images cached; tiles coloured by Fitzgerald Key category.
- **Profiles:** caregiver creates, renames, and deletes child profiles.
- **Admin:** CRUD for rooms, room words, and beacons (with a live beacon scanner).
- **Analytics:** logs every word tap (user, room, word); totals, top words/rooms/users, recent activity.
