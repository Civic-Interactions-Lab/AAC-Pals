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

- 04 — User Selector Screen + User Service Layer: Full `UserSelectorView` with warm `#FFF7EE` background, decorative blob background, animated floating shapes (bottom-right), hero section with admin name from email, lazy card grid. `UserCard` — gradient avatar circle, select button, long-press context menu for edit/delete. `AddUserCard` — dashed border card to add new user. `AddEditProfileModal` — centered ZStack overlay (no sheet), orange-focus text field, instant focus via `Task`, smooth `easeOut(0.18)` fade animation. `EmptyState` for zero-user case. Orange spinner shown while loading. `UserService` protocol with `LocalUserService` (UserDefaults, keyed per admin), `MockUserService`, and `SupabaseUserService` (scoped by `admin_id`, individual CRUD ops that re-fetch after mutation). `UserManager` (`@Observable`) holds `profiles`, `activeProfile`, `isLoading`; `clearProfiles()` prevents flashing previous account data. `UserProfile` model with `UserRole` enum (`user`/`admin`). `RootView` routes to `UserSelectorView` when `activeProfile == nil`. `UserSelectorView` uses `.task(id: adminId)` to re-fetch on account switch. Auth/Register views redesigned to match — same warm background, `AuthTextField` with orange focus border, `AuthFloatingShapes`, shared via `AuthComponents.swift`. BoardView has bottom-right `person.2.fill` button to return to user selector via `userManager.exitProfile()`. All "student/learner" terminology renamed to "user".

---

- 05 — BLE Beacon Service Layer + Room Detection: `BeaconConfig` model with `DetectionRadius` enum (veryClose/close/medium/far/custom) mapping to RSSI thresholds. `DetectedBeacon` model with optional `name`, `major`, `minor`, `rssi`. `BeaconService` protocol with callback pattern (`onBeaconDetected`). `MockBeaconService` — timer-based simulation firing every 3s, immediate fire on start. `CoreBluetoothBeaconService` — scans all peripherals with `AllowDuplicatesKey: true`, parses Apple iBeacon manufacturer data (`0x4C 0x00 0x02 0x15`) and falls back to peripheral name matching for non-iBeacon hardware. `BeaconManager` (`@Observable`) holds `currentRoomId` (defaults to "common"), `knownBeacons` config, watchdog timer polling every 3s — falls back to "common" after `fallbackDelay` (8s) with no matching signal. Kitchen beacon configured by peripheral name `"Kitchen"` with `.medium` radius. `BoardView` wired to read `beaconManager.currentRoomId`, starts/stops scanning on appear/disappear. `"common": []` fallback room added to `AACVocabulary`. `NSBluetoothAlwaysUsageDescription` added to build settings. App forced to light mode via `.preferredColorScheme(.light)` on `AppView`. All components refactored into individual files: `Core/Auth/Components/` (AuthBackground, AuthTextField, AuthFloatingShapes), `Core/UserSelector/Components/` (DecorativeBackground, HeroSection, FloatingShapes, UserGrid, UserCard, AddUserCard, EmptyState, AddEditProfileModal). `AuthBackground` and `DecorativeBackground` animate blobs across the screen. Previews added to all components.

---

- 06 — Interaction Logging Service Layer: `InteractionLog` model with `InsertRow` (no id, for Supabase insert) and `Record` (has id, for decoding fetched results) nested structs. `toRow()` returns `InsertRow`. `InteractionService` protocol with `log(userId:adminId:word:roomId:)` and two `fetchLogs` overloads (by admin, by admin+user). `MockInteractionService` (no-op log, returns empty). `SupabaseInteractionService` — inserts via `InsertRow`, fetches via `[InteractionLog.Record]`. `InteractionManager` (`@Observable`) with `logWord`, `fetchLogs(adminId:)`, `fetchLogs(adminId:userId:)`. `activeAdminId` added to `UserManager` (set during `loadProfiles`). `BoardView` calls `interactionManager.logWord` on every word tap. `UserProfile.Row` renamed to `UserProfile.Record`. `InteractionManager` injected into app dependencies and `previewAllEnvironments`. Supabase table: `interaction_logs` with RLS policy scoped to `admin_id = auth.uid()`.

---

- 07 — Admin Panel + Tab Navigation: `MainTabView` with Users and Admin tabs using SwiftUI `TabView`, tinted orange. Gear button (`Menu`) moved from `UserSelectorView` into `MainTabView` as a top-right overlay — not a tab, triggers sign-out confirmation. `AdminView` built with warm background matching app design: 4 stat cards (interactions, users, rooms, words), horizontal user filter chips, ranked sections (top words, top rooms, top users), recent activity log feed. `AdminAnalytics` model computed client-side from logs. `InteractionManager.loadAnalytics(adminId:userId:)` fetches and computes analytics. `AdminStatCard`, `AdminRankedSection`, `AdminUserFilterBar`, `AdminRecentLogRow` components in `Core/Admin/Components/`. `AppView` merged with `RootView` — single routing view, `RootView.swift` deleted. `UserProfile.Record` rename: `toRecord` reverted back to `toRow` (returns `Record`). Auth views keyboard fix: removed `.ignoresSafeArea(.keyboard)`, made `ScrollView` the root with `AuthBackground` as `.background`, added `ScrollViewReader` + `proxy.scrollTo("form")` with spring animation on field focus. Same fix applied to `AddEditProfileModal`.

---

- 08 — Rooms Tab (Admin CRUD): `Room` model with `Insert`/`Record` nested structs and snake_case `CodingKeys`. `RoomWord` model same pattern with `position`, `category`, `toInsert()`. `AdminService` protocol: `fetchRooms`, `addRoom`, `updateRoom`, `deleteRoom`, `fetchWords`, `addWord`, `updateWord`, `deleteWord`. `MockAdminService` — in-memory, seeded with `Room.mocks` and real AAC vocab via `RoomWord.mocks(for:)`. `SupabaseAdminService` — full Supabase CRUD for `rooms` and `room_words` tables. `AdminManager` (`@Observable`) holds `rooms: [Room]` and `wordsByRoom: [String: [RoomWord]]`. Supabase RLS policies added: `auth.uid() = admin_id` for both tables. `MainTabView` updated with Rooms tab. `RoomsView` — top-left header matching UserSelectorView, card grid `minimum: 200`, empty state with Create Room button. `RoomCard` — 100pt gradient avatar, word count, Open/Edit/Delete buttons inline. `AddRoomCard` — matches RoomCard height. `AddEditRoomModal` — label + roomId fields. `RoomDetailView` — renders words as `PictogramTile` grid (8 columns) matching the board, context menu for edit/delete. `AddEditWordModal` — label field + Fitzgerald category picker. `previewAllEnvironments` updated with `adminService` and `preloadRooms` params.

---

- 09 — Beacon Management + Live Room Detection: `AppBeacon` model with `Insert`/`Record` nested structs for Supabase `beacons` table (`beacon_uuid unique`, `room_id`, `radius`, `label`). `AdminService` protocol extended with `fetchAllBeacons(adminId:)`, `fetchBeacons(roomId:)`, `addBeacon`, `updateBeacon`, `deleteBeacon`. `MockAdminService` updated with beacon CRUD and `beacons` init param for seeding previews. `SupabaseAdminService` full CRUD against `beacons` table using typed `Payload` struct for mixed-type updates. `AdminManager` extended with `beaconsByRoom`, `loadAllBeacons`, `loadBeacons(for:)`, `addBeacon`, `updateBeacon`, `deleteBeacon`. `BeaconService` protocol updated with `scannedBeacons: [String: DetectedBeacon]`. `MockBeaconService` seeds `scannedBeacons` on start. `DetectedBeacon` updated with `uuid: String?`, `Identifiable`, `displayName`, `signalLabel`, `signalColor`. `CoreBluetoothBeaconService` parses iBeacon UUID from manufacturer data bytes 4-19 and accumulates `scannedBeacons`. `BeaconConfig` extended with `beaconUuid` field and UUID-first matching. `BeaconManager.loadBeacons([AppBeacon])` detects UUID vs name identifier via `UUID(uuidString:)` and sets `beaconUuid` or `peripheralName` accordingly. `RoomDetailView` redesigned with beacon section (linked beacons list + Add Beacon button) above word grid. `BeaconRow` component with label, UUID, radius display and Edit/Delete buttons. `BeaconScannerModal` — split panel: left shows live BLE scan filtered to ≥-55 dBm (~3ft), right slides in on selection to set label/radius (in feet, 3–66ft range) and link to room. `EditBeaconModal` — edit label and radius of existing beacon. `BoardView` updated to load all beacons from Supabase on appear via `loadAllBeacons`, push into `BeaconManager.knownBeacons`, then start scanning. Room words now sourced from `AdminManager.words(for: currentRoomId)` instead of static `AACVocabulary`. Words loaded dynamically on room change via `.task(id: currentRoom)`. Supabase `beacons` table: RLS policy `auth.uid() = admin_id`.

---

- 10 — Board Improvements + User Passcode System: `WordGrid` updated from 4/4 to 6/2 column split (`coreFraction = 6/8`), separate `coreTileSize` and `roomTileSize` computed per section. `AACVocabulary.coreWords` expanded from 20 → 72 words across pronouns, verbs, social, feelings, descriptors, location, questions, misc. Room selector banner added above right word column — tappable capsule showing current room name with chevron. `RoomPickerPopover` — popover anchored to banner, lists General + all rooms, shows beacon antenna icon on auto-detected room, checkmark on selected. `BoardView` loads rooms on appear so picker is populated on first launch; manual room override stored in `@State manualRoomId`, clears on beacon room change. `AVSpeechSynthesizer` warm-up on board appear (silent utterance) eliminates first-tap speech delay. Word tap now speaks individual word; Speak button reads full sentence. Sentence bar clears on board disappear. `RoomDetailView` words section shows styled empty state (icon + headline + CTA) when no words, matching rooms/users screen style. `UserProfile` model updated with `passcode: String` field throughout — model, `Record`, `makeNew`, `mocks`. `UserService` protocol and all implementations (`Mock`, `Supabase`, `Local`) updated: `addProfile` takes `passcode` param; new `updateProfile(id:displayName:passcode:)` method added for editing both name and passcode. `UserManager` wires new methods. `AddEditProfileModal` updated — passcode shown as plain 4-digit numeric text field in both Add and Edit modes; validates uniqueness against existing profiles with inline error message; Save button disabled if passcode is taken. `UserCard` updated — visible Edit/Delete buttons below Continue button, matching `RoomCard` style; passcode shown with lock icon below name. `AddUserCard` — `Color.clear` spacer added to match `UserCard` height. `PasscodeModal` (new) — full-screen overlay with 4-dot entry, shake animation on wrong code, tap-backdrop to dismiss, configurable message. `UserGrid` wires `onSelectPending` — passcode modal shown full-screen in `UserSelectorView` before entering board. `BoardView` shows passcode modal on exit button tap; saves active `userId` to `UserDefaults` on appear, removes on successful exit. `AppView` checks `UserDefaults` on cold start — if saved userId matches a loaded profile, auto-selects it and skips user selector. Supabase migration: `ALTER TABLE user_profiles ADD COLUMN passcode TEXT NOT NULL DEFAULT '0000'`.

---

## In Progress

- None.

## Next Up

1. Interaction log viewer UI in Admin tab
2. Admin password protection for Admin tab
3. Admin analytics

## Open Questions

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
