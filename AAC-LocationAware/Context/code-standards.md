# Code Standards

## General

- Keep files small and single-purpose — one view, one service, one model per file
- Fix root causes; do not layer workarounds or conditional hacks
- Do not mix UI, business logic, and data access in the same file

## Swift

- Use `struct` for models and views; use `class` only for services that need reference semantics
- Prefer `async/await` over callbacks or Combine for async operations
- Use explicit types at API boundaries; let inference work inside function bodies
- Never force-unwrap (`!`) outside of tests — use `guard let` or `if let`

## SwiftUI

- Views are dumb — they render state and fire actions; no business logic inside views
- Use `@StateObject` for service/manager instances owned by a view; `@ObservedObject` for injected ones
- Keep view bodies short — extract subviews or use `ViewModifier` when a view exceeds ~50 lines
- Previews are required for every screen-level view

## Services

- Each service owns one domain (auth, rooms, beacons, TTS, AI, logs)
- Services are injected via the SwiftUI environment — never instantiated inside views
- Services expose `async throws` functions; callers handle errors at the view layer

## Naming

- Views: `NounView` or `NounScreen` (e.g. `WordGridView`, `UserSelectorScreen`)
- Services: `NounService` or `NounManager` (e.g. `RoomService`, `BeaconManager`)
- Models: plain nouns (e.g. `Room`, `Student`, `Word`)
- Do not prefix with `I` for protocols — use descriptive protocol names

## File Organization

- `Core/[Feature]/` — screen views, sub-views, and view models for that feature
- `Components/` — shared UI components used across multiple features
- `Services/` — all external integrations and business logic
- `Models/` — plain data structs and enums, no logic
- `Extensions/` — extensions on standard Swift/SwiftUI types only
- `Utils/` — constants, validation helpers, and one-off utilities
