# 🎧 Healing Music — Backend

[![style: dart frog lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

A REST API backend for the **Healing Music** app, built with [Dart Frog](https://dart-frog.dev) and PostgreSQL.

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT

---

## 📦 Tech Stack

| Package | Purpose |
|---|---|
| `dart_frog` | REST API framework |
| `postgres` | PostgreSQL database driver |
| `dart_jsonwebtoken` | JWT generation & verification |
| `dotenv` | Environment variable loading |

---

## 🚀 Getting Started

### Prerequisites

- Dart SDK `≥ 3.0.0`
- Dart Frog CLI
- PostgreSQL

```bash
# Install Dart Frog CLI
dart pub global activate dart_frog_cli
```

### Installation

```bash
# Clone the repo
git clone https://github.com/LiinIT/healingmusic.git
cd healingmusic/healing_music_backend

# Install dependencies
dart pub get

# Copy and configure environment variables
cp .env.example .env
```

### Environment Variables

Create a `.env` file in the project root:

```env
DB_HOST=127.0.0.1
DB_NAME=healing_music_db
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_PORT=5432
JWT_KEY=your_secret_jwt_key
```

> ⚠️ **Never commit `.env` to version control.** Use `.env.example` with placeholder values instead.

### Database Setup

```bash
# Create the database
createdb healing_music_db

# Run the schema
psql -U postgres -d healing_music_db -f schema.sql
```

### Run the Server

```bash
# Development (hot reload)
dart_frog dev

# Production build
dart_frog build
cd build && dart main.dart
```

The server starts at `http://localhost:8080` by default.

---

## 📡 API Reference

### Auth

| Method | Endpoint | Body | Description |
|---|---|---|---|
| `POST` | `/auth/register` | `{ username, password }` | Register a new user |
| `POST` | `/auth/login` | `{ username, password }` | Login → returns JWT token |

### Songs

| Method | Endpoint | Body | Description |
|---|---|---|---|
| `GET` | `/songs` | — | Get all songs |
| `GET` | `/songs/randoms` | — | Get random songs |
| `GET` | `/songs/top_rank` | — | Get top ranked songs |
| `POST` | `/songs/search` | `{ keyword }` | Search songs by keyword |
| `POST` | `/songs/by_artist` | `{ artist_id }` | Get songs by artist |
| `POST` | `/songs/handleFavorite` | `{ user_id, song_id }` | Toggle / get favorites |

### Artists

| Method | Endpoint | Body | Description |
|---|---|---|---|
| `POST` | `/artists/find_artist_id` | `{ artist_id }` | Get artist by ID |
| `POST` | `/artists/get_all` | — | Get all artists |

### Users

| Method | Endpoint | Body | Description |
|---|---|---|---|
| `POST` | `/users/id` | `{ user_id }` | Get user by ID |

---

## 🏗 Project Structure

```
healing_music_backend/
├── routes/
│   ├── auth/
│   │   ├── login.dart          # POST /auth/login
│   │   └── register.dart       # POST /auth/register
│   ├── songs/
│   │   ├── index.dart          # GET /songs
│   │   ├── randoms.dart        # GET /songs/randoms
│   │   ├── top_rank.dart       # GET /songs/top_rank
│   │   ├── search.dart         # POST /songs/search
│   │   ├── by_artist.dart      # POST /songs/by_artist
│   │   └── handleFavorite.dart # POST /songs/handleFavorite
│   ├── artists/
│   │   ├── find_artist_id.dart # POST /artists/find_artist_id
│   │   └── get_all.dart        # POST /artists/get_all
│   └── users/
│       └── id.dart             # POST /users/id
├── middleware.dart              # DB connection injection
├── pubspec.yaml
└── .env                        # Local only — never commit
```

---

## 🔐 Authentication

JWT tokens are issued on login with a **7-day expiry**, signed using the `JWT_KEY` environment variable.

```
POST /auth/login
→ { "token": "<jwt>" }
```

Include the token in subsequent requests:

```
Authorization: Bearer <token>
```

The middleware layer verifies the token and injects a `Connection` (PostgreSQL) into each request context via Dart Frog's dependency injection.

---

## 🗄 Database Schema

| Table | Description |
|---|---|
| `users` | User accounts & profiles |
| `artists` | Artist information |
| `songs` | Song metadata & audio URLs |
| `favorites` | User favorite songs |
| `history` | Listening history (max 50/user) |
| `albums` | User-created playlists |
| `album_songs` | Songs within albums |

---

## 👤 Author

**Ngoc Khanh Ho**
- GitHub: [@LiinIT](https://github.com/LiinIT)
- Email: hongockhanh.it@gmail.com

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).