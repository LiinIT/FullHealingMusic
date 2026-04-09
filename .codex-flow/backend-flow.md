# Backend Flow

## Scope

- Path: `/Users/asliin/Documents/Healing_music/healing_music_backend`
- Stack: Dart Frog + PostgreSQL
- Main code path: `routes/`

## High-Level Tree

```text
healing_music_backend/routes
├── _middleware.dart
├── index.dart
├── upload.dart
├── auth
│   ├── change_pass.dart
│   ├── checked.dart
│   ├── checked_user.dart
│   ├── login.dart
│   └── register.dart
├── artists
│   ├── album.dart
│   ├── crud_artist.dart
│   ├── find_artist.dart
│   ├── find_artist_id.dart
│   ├── get_all.dart
│   ├── get_songs.dart
│   └── profiles.dart
├── songs
│   ├── by_artist.dart
│   ├── crud_song.dart
│   ├── handleFavorite.dart
│   ├── history.dart
│   ├── index.dart
│   ├── playlist_random.dart
│   ├── randoms.dart
│   ├── search.dart
│   └── top_rank.dart
└── users
    ├── crud_user.dart
    ├── folder_playlist.dart
    ├── id.dart
    └── theme.dart
```

## Likely Request Flow

1. Client sends request to route in `routes/`
2. Middleware prepares shared dependencies
3. Route validates input and auth state
4. Route reads or writes PostgreSQL data
5. Response returns to Flutter app or web frontend

## Where To Look First

- Login, register, token, password: `routes/auth`
- Song fetch, favorites, history, ranking: `routes/songs`
- Artist profile or artist content: `routes/artists`
- User identity, playlist folders, theme: `routes/users`
- Cross-cutting request setup: `routes/_middleware.dart`

## Edit Tracking Notes

- Prefer logging endpoint changes with request path and behavior impact in `change-log.md`
