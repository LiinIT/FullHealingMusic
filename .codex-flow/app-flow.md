# App Flow

## Scope

- Path: `/Users/asliin/Documents/Healing_music/healing_music_app`
- Stack: Flutter
- Main code path: `lib/`

## High-Level Tree

```text
healing_music_app/lib
├── main.dart
├── core
│   ├── constants
│   ├── models
│   ├── services
│   ├── themes
│   └── utils
└── features
    ├── ads
    ├── album
    ├── artist
    ├── auth
    ├── home
    ├── player
    ├── profile
    └── search
```

## Likely Primary User Flow

1. App boot from `main.dart`
2. Auth flow in `features/auth`
3. Home discovery flow in `features/home`
4. Playback flow in `features/player`
5. Content exploration through `artist`, `album`, and `search`
6. User settings and personal data in `profile`

## Where To Look First

- Login or registration bug: `features/auth`
- Home screen or feed issue: `features/home`
- Audio controls or playback state bug: `features/player`
- Search mismatch: `features/search`
- Artist or album detail issue: `features/artist`, `features/album`
- Theme or shared helper issue: `core/themes`, `core/utils`, `core/services`

## Edit Tracking Notes

- Add important edits to `change-log.md`
- Record file paths, purpose, and risk after each meaningful change
