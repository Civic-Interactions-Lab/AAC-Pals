# Architecture Context

## Stack

| Layer        | Technology                  | Role                                      |
| ------------ | --------------------------- | ----------------------------------------- |
| Platform     | iPad (iOS 17+)              | Target device                             |
| UI Framework | SwiftUI                     | All screens and components                |
| Language     | Swift                       | Entire codebase                           |
| Backend      | Supabase (PostgreSQL + RLS) | Rooms, words, students, interaction logs  |
| Auth         | Supabase Auth               | Caregiver authentication                  |
| BLE          | CoreBluetooth               | iBeacon detection and room switching      |
| TTS          | AVSpeechSynthesizer         | Text-to-speech output                     |
| AI           | External API (Groq / Claude)| Next-word suggestions                     |
| Local Storage| UserDefaults                | Device settings only (AI toggle, admin code) |

## Folder Structure

```
AAC-LocationAware/
├── App/          # @main entry point, AppDelegate, root SwiftUI view
├── Core/         # One folder per screen or major feature. Each feature folder may contain:
│               #   Views/       — screen-level SwiftUI views
│               #   Components/  — UI pieces local to that feature
│               #   ViewModels/  — @Observable classes holding state and business logic for the feature
│               #   Models/      — data models scoped to that feature only
├── Components/   # Shared reusable UI pieces used across multiple features
├── Services/     # One folder per external integration or business domain (Supabase, BLE, TTS, AI, etc.)
├── Data/         # Static app data and domain logic (vocabulary, color rules)
├── Models/       # Plain Swift structs and enums — no logic
├── Extensions/   # Extensions on Swift and SwiftUI built-in types
└── Context/      # AI and developer context docs
```

## Storage Model

- **Supabase (PostgreSQL)**: All app data — rooms, words, beacons, students, interaction logs
- **UserDefaults**: Device-only settings — AI suggestions toggle, admin passcode cache, beacon sensitivity

## Auth and Access Model

- Caregivers sign in via Supabase Auth to access the admin panel
- Students do not authenticate — they are selected from a profile list
- Admin panel is additionally gated by a local passcode for quick lockout
- All Supabase mutations go through service-role RPCs; reads use RLS for authenticated users

## Invariants

1. BLE scanning runs only while the app is in the foreground
2. No student data is stored on-device — always fetched from Supabase
3. UserDefaults holds settings only — never business data
4. AI suggestions are optional and the app must work fully without them
