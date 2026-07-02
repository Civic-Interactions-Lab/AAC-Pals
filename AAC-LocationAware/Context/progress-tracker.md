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

- 02 — Service Layer & Build Configuration: Refactored pictogram fetching into Model/Service/Manager pattern. `PictogramService` protocol with `MockPictogramService` (instant hardcoded URLs, supports delay/error) and `ArasaacPictogramService` (real API, URL cache in UserDefaults, image cache in memory). `PictogramManager` (`@Observable`) holds both pictogram fetching and sentence state (`sentence`, `addWord`, `removeLast`, `remove(at:)`, `clearSentence`) — injected via SwiftUI environment. `BuildConfiguration` enum (mock/development/production) with `Dependency` struct wiring the right service per build. Three Xcode schemes (`Mock`, `Dev`, `Prod`) with `Active Compilation Conditions` (`MOCK`, `DEV`) in Build Settings. `previewAllEnvironments()` extension injects mock managers into every preview. iPad orientation locked to landscape via Info.plist (`UISupportedInterfaceOrientations~ipad`).

---

- 03 — Auth Service Layer + Login/Register UI: `AuthService` protocol with `MockAuthService` (accepts admin/admin, configurable delay/error) and `SupabaseAuthService` (real Supabase auth — signIn, signUp, signOut, getCurrentUser). `AuthManager` (`@Observable`) holds `currentUser`, `isSignedIn`, `isLoading`, `error` — injected via environment. `RootView` routes between `LoginView` and `BoardView` based on auth state, restores session on launch. `LoginView` — gradient background, centered white card, keyboard-avoiding ScrollView, links to RegisterView via fullScreenCover. `RegisterView` — same style, email/password/confirm password with mismatch validation. Supabase Swift SDK added via SPM. `Config.swift` holds Supabase URL and anon key. `previewAllEnvironments` updated with `isSignedIn` and `authError` params. Interactive `@Previewable` preview on RootView for sign in/out flow.

---

---

- 04 — User Selector Screen + User Service Layer: Full `UserSelectorView` with warm `#FFF7EE` background, decorative blob background, animated floating shapes (bottom-right), hero section with admin name from email, lazy card grid. `UserCard` — gradient avatar circle, select button, long-press context menu for edit/delete. `AddUserCard` — dashed border card to add new user. `AddEditProfileModal` — centered ZStack overlay (no sheet), orange-focus text field, instant focus via `Task`, smooth `easeOut(0.18)` fade animation. `EmptyState` for zero-user case. Orange spinner shown while loading. `UserService` protocol with `LocalUserService` (UserDefaults, keyed per admin), `MockUserService`, and `SupabaseUserService` (scoped by `admin_id`, individual CRUD ops that re-fetch after mutation). `UserManager` (`@Observable`) holds `profiles`, `activeProfile`, `isLoading`; `clearProfiles()` prevents flashing previous account data. `UserProfile` model with `UserRole` enum (`user`/`admin`). `RootView` routes to `UserSelectorView` when `activeProfile == nil`. `UserSelectorView` uses `.task(id: adminId)` to re-fetch on account switch. Auth/Register views redesigned to match — same warm background, `AuthTextField` with orange focus border, `AuthFloatingShapes`, shared via `AuthComponents.swift`. BoardView has bottom-right `person.2.fill` button to return to user selector via `userManager.exitProfile()`. All "student/learner" terminology renamed to "user".

---

---

- 05 — BLE Beacon Service Layer + Room Detection: `BeaconConfig` model with `DetectionRadius` enum (veryClose/close/medium/far/custom) mapping to RSSI thresholds. `DetectedBeacon` model with optional `name`, `major`, `minor`, `rssi`. `BeaconService` protocol with callback pattern (`onBeaconDetected`). `MockBeaconService` — timer-based simulation firing every 3s, immediate fire on start. `CoreBluetoothBeaconService` — scans all peripherals with `AllowDuplicatesKey: true`, parses Apple iBeacon manufacturer data (`0x4C 0x00 0x02 0x15`) and falls back to peripheral name matching for non-iBeacon hardware. `BeaconManager` (`@Observable`) holds `currentRoomId` (defaults to "common"), `knownBeacons` config, watchdog timer polling every 3s — falls back to "common" after `fallbackDelay` (8s) with no matching signal. Kitchen beacon configured by peripheral name `"Kitchen"` with `.medium` radius. `BoardView` wired to read `beaconManager.currentRoomId`, starts/stops scanning on appear/disappear. `"common": []` fallback room added to `AACVocabulary`. `NSBluetoothAlwaysUsageDescription` added to build settings. App forced to light mode via `.preferredColorScheme(.light)` on `AppView`. All components refactored into individual files: `Core/Auth/Components/` (AuthBackground, AuthTextField, AuthFloatingShapes), `Core/UserSelector/Components/` (DecorativeBackground, HeroSection, FloatingShapes, UserGrid, UserCard, AddUserCard, EmptyState, AddEditProfileModal). `AuthBackground` and `DecorativeBackground` animate blobs across the screen. Previews added to all components.

---

---

- 06 — Interaction Logging Service Layer: `InteractionLog` model with `InsertRow` (no id, for Supabase insert) and `Record` (has id, for decoding fetched results) nested structs. `toRow()` returns `InsertRow`. `InteractionService` protocol with `log(userId:adminId:word:roomId:)` and two `fetchLogs` overloads (by admin, by admin+user). `MockInteractionService` (no-op log, returns empty). `SupabaseInteractionService` — inserts via `InsertRow`, fetches via `[InteractionLog.Record]`. `InteractionManager` (`@Observable`) with `logWord`, `fetchLogs(adminId:)`, `fetchLogs(adminId:userId:)`. `activeAdminId` added to `UserManager` (set during `loadProfiles`). `BoardView` calls `interactionManager.logWord` on every word tap. `UserProfile.Row` renamed to `UserProfile.Record`. `InteractionManager` injected into app dependencies and `previewAllEnvironments`. Supabase table: `interaction_logs` with RLS policy scoped to `admin_id = auth.uid()`.

---

## In Progress

- None.

## Next Up

1. Wire Supabase — fetch real rooms and words, replace static vocabulary
2. Build admin panel — rooms, words, beacons, users
3. Add analytics dashboard (top words, top rooms, per-user breakdown)
4. Add AI word suggestions

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
