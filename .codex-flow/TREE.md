# Healing Music Flow Tree

## Root

- Project root: `/Users/asliin/Documents/Healing_music`
- Main parts:
  - `healing_music_app`: Flutter mobile and desktop app
  - `healing_music_backend`: Dart Frog REST API
  - `healing_music_web`: static web frontend
  - `Overview document HealingMusic`: supporting docs

## Navigation Tree

```text
Healing_music
├── .codex-flow
│   ├── TREE.md
│   ├── app-flow.md
│   ├── backend-flow.md
│   ├── web-flow.md
│   └── change-log.md
├── healing_music_app
│   └── lib
│       ├── core
│       │   ├── constants
│       │   ├── models
│       │   ├── services
│       │   ├── themes
│       │   └── utils
│       └── features
│           ├── ads
│           ├── album
│           ├── artist
│           ├── auth
│           ├── home
│           ├── player
│           ├── profile
│           └── search
├── healing_music_backend
│   ├── lib
│   └── routes
│       ├── auth
│       ├── artists
│       ├── songs
│       ├── users
│       ├── upload.dart
│       └── _middleware.dart
└── healing_music_web
    ├── components
    ├── css
    ├── js
    ├── pages
    └── public
```

## Main Flow Map

- User-facing app flow starts in `healing_music_app`
- Data and authentication flow through `healing_music_backend/routes`
- Web folder is a separate frontend surface, likely lighter than the Flutter app

## Fast Resume Rules

- UI or playback issue: start with `app-flow.md`
- API, auth, database, or route issue: start with `backend-flow.md`
- Static website issue: start with `web-flow.md`
- To find previous important edits: read `change-log.md`
