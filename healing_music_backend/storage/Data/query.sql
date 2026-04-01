--TRUNCATE TABLE history      CASCADE;

 
-- Xóa triggers trước
DROP TRIGGER IF EXISTS trg_increment_play_count ON history;
DROP FUNCTION IF EXISTS fn_increment_play_count();
 
-- Xóa các bảng theo thứ tự (phụ thuộc trước, cha sau)
DROP TABLE IF EXISTS history              CASCADE;
DROP TABLE IF EXISTS favorites            CASCADE;
DROP TABLE IF EXISTS playlist_songs       CASCADE;
DROP TABLE IF EXISTS playlists            CASCADE;
DROP TABLE IF EXISTS artist_album_songs   CASCADE;
DROP TABLE IF EXISTS artist_albums        CASCADE;
DROP TABLE IF EXISTS songs                CASCADE;
DROP TABLE IF EXISTS artists              CASCADE;
DROP TABLE IF EXISTS theme_user           CASCADE;
DROP TABLE IF EXISTS users                CASCADE;


 
-- ============================================================
--  MUSIC DATABASE SCHEMA
--  PostgreSQL
--  Generated: 2026-03-31
-- ============================================================

-- ------------------------------------------------------------
-- EXTENSIONS
-- ------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================
-- TABLE: users
-- ============================================================
CREATE TABLE users (
    id         VARCHAR(70)  PRIMARY KEY DEFAULT (
                   TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS_') ||
                   SUBSTRING(MD5(RANDOM()::TEXT), 1, 33)
               ),
    username   VARCHAR(50)  UNIQUE NOT NULL,
    password   TEXT         NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    full_name  VARCHAR(100),
    avatar_url TEXT,
    role       VARCHAR(20)  DEFAULT 'USER'
                   CHECK (role IN ('USER', 'ADMIN', 'MODERATOR')),
    is_active  BOOLEAN      DEFAULT TRUE,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- TABLE: theme_user
-- ============================================================
CREATE TABLE theme_user (
    id         SERIAL      PRIMARY KEY,
    user_id    VARCHAR(70) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    light_mode BOOLEAN     DEFAULT TRUE
);


-- ============================================================
-- TABLE: artists
-- ============================================================
CREATE TABLE artists (
    id             SERIAL       PRIMARY KEY,
    full_name      VARCHAR(255) NOT NULL,
    avatar_url     TEXT         NOT NULL,
    bio            TEXT,
    follower_count INTEGER      DEFAULT 0,
    is_verified    BOOLEAN      DEFAULT FALSE,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- TABLE: songs
-- ============================================================
CREATE TABLE songs (
    id               SERIAL       PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    artist_id        INTEGER      REFERENCES artists(id) ON DELETE SET NULL,
    image_url        TEXT,
    audio_url        TEXT         NOT NULL,
    rank             INTEGER      DEFAULT 0,
    duration_seconds INTEGER,
    play_count       BIGINT       DEFAULT 0,
    created_at       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- TABLE: artist_albums  (official albums released by artists)
-- ============================================================
CREATE TABLE artist_albums (
    id           SERIAL       PRIMARY KEY,
    artist_id    INTEGER      NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    title        VARCHAR(255) NOT NULL,
    cover_url    TEXT,
    album_type   VARCHAR(20)  DEFAULT 'album'
                     CHECK (album_type IN ('album', 'single', 'EP', 'live', 'compilation')),
    release_date DATE,
    created_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- TABLE: artist_album_songs  (songs belonging to an artist album)
-- ============================================================
CREATE TABLE artist_album_songs (
    album_id     INTEGER   NOT NULL REFERENCES artist_albums(id) ON DELETE CASCADE,
    song_id      INTEGER   NOT NULL REFERENCES songs(id)         ON DELETE CASCADE,
    track_number INTEGER,
    added_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (album_id, song_id)
);


-- ============================================================
-- TABLE: playlists  (personal playlists created by users)
-- ============================================================
CREATE TABLE playlists (
    id         SERIAL       PRIMARY KEY,
    user_id    VARCHAR(70)  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name       VARCHAR(255) NOT NULL,
    cover_url  TEXT,
    is_public  BOOLEAN      DEFAULT FALSE,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, name)
);


-- ============================================================
-- TABLE: playlist_songs
-- ============================================================
CREATE TABLE playlist_songs (
    playlist_id INTEGER   NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
    song_id     INTEGER   NOT NULL REFERENCES songs(id)     ON DELETE CASCADE,
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id)
);


-- ============================================================
-- TABLE: favorites
-- ============================================================
CREATE TABLE favorites (
    user_id    VARCHAR(70) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    song_id    INTEGER     NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    created_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, song_id)
);


-- ============================================================
-- TABLE: history  (listening history — multiple plays allowed)
-- ============================================================
CREATE TABLE history (
    id        SERIAL      PRIMARY KEY,
    user_id   VARCHAR(70) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    song_id   INTEGER     NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    played_at TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- INDEXES
-- ============================================================

-- users
CREATE INDEX idx_users_email    ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- songs
CREATE INDEX idx_songs_artist   ON songs(artist_id);
CREATE INDEX idx_songs_rank     ON songs(rank DESC);

-- artist_albums
CREATE INDEX idx_artist_albums_artist ON artist_albums(artist_id);

-- artist_album_songs
CREATE INDEX idx_album_songs_song  ON artist_album_songs(song_id);

-- playlists
CREATE INDEX idx_playlists_user ON playlists(user_id);

-- playlist_songs
CREATE INDEX idx_playlist_songs_song ON playlist_songs(song_id);

-- favorites
CREATE INDEX idx_favorites_song ON favorites(song_id);

-- history
CREATE INDEX idx_history_user      ON history(user_id);
CREATE INDEX idx_history_song      ON history(song_id);
CREATE INDEX idx_history_played_at ON history(played_at DESC);


-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-increment play_count on songs when a history row is inserted
CREATE OR REPLACE FUNCTION fn_increment_play_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE songs
    SET play_count = play_count + 1
    WHERE id = NEW.song_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_increment_play_count
AFTER INSERT ON history
FOR EACH ROW EXECUTE FUNCTION fn_increment_play_count();


-- ============================================================
-- END OF SCHEMA
-- ============================================================