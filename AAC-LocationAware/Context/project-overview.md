# AAC Beacon — iPad App

## Overview

AAC Beacon is a location-aware Augmentative and Alternative Communication (AAC) app for iPad. It automatically switches the on-screen word grid based on which room the user is in, detected via Bluetooth iBeacons. Designed for non-verbal users — primarily children with communication disabilities — so they see context-relevant vocabulary without any manual navigation. Caregivers manage rooms, vocabulary, beacons, and students through a built-in admin interface.

## Goals

1. Auto-switch word grids based on room detection with no user action required
2. Provide reliable text-to-speech output for AAC communication
3. Give caregivers full control over rooms, vocabulary, and students without touching code

## Core User Flow

1. Caregiver sets up rooms, assigns vocabulary, and pairs iBeacons via admin panel
2. Student is selected on the User Selector screen
3. App detects the nearest iBeacon and switches to that room's word grid
4. Student taps pictogram tiles to build a sentence
5. Student taps Speak to play the sentence via text-to-speech
6. Caregiver can review per-student interaction analytics from the admin panel

## Features

### Word Grid & Communication
- Pictogram-based word tiles with Fitzgerald Key color coding
- Sentence builder bar with speak and clear actions
- Paginated grid for large vocabulary sets
- AI-generated next-word suggestions (toggleable)

### Location Awareness
- iBeacon detection via CoreBluetooth
- Automatic room switching based on nearest beacon
- Tunable detection radius per room

### Admin Interface
- Password-protected admin panel
- Manage rooms, vocabulary, and beacon pairings
- Manage student profiles
- Per-student usage analytics

## Scope

### In Scope
- iPad-only native SwiftUI app
- iBeacon room detection via CoreBluetooth
- Supabase backend for all persistent data
- Text-to-speech via AVSpeechSynthesizer
- AI word suggestions via external API
- Admin panel for caregivers

### Out of Scope
- iPhone or Android support
- Multi-device sync or real-time collaboration
- Custom symbol sets (uses ARASAAC pictograms)

## Success Criteria

1. Beacon detection switches the word grid within 3 seconds of entering a room
2. Tapping a word and pressing Speak plays the sentence aloud
3. Admin can create a room, assign words, and pair a beacon without developer help
4. App functions correctly on iPad with Supabase as the backend
