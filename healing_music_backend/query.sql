-- ============================================================
-- RESET DATABASE
-- ============================================================

DROP TRIGGER IF EXISTS trg_increment_play_count ON history;
DROP FUNCTION IF EXISTS fn_increment_play_count();

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
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id VARCHAR(70) PRIMARY KEY DEFAULT (
        TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS_') ||
        SUBSTRING(MD5(RANDOM()::TEXT), 1, 33)
    ),
    taguser VARCHAR(50) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    role VARCHAR(20) DEFAULT 'USER'
        CHECK (role IN ('USER', 'ADMIN', 'MODERATOR')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- THEME USER
-- ============================================================
CREATE TABLE theme_user (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(70) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    light_mode BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- ARTISTS
-- ============================================================
CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT NOT NULL,
    bio TEXT,
    follower_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- SONGS
-- ============================================================
CREATE TABLE songs (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INTEGER REFERENCES artists(id) ON DELETE SET NULL,
    image_url TEXT,
    audio_url TEXT NOT NULL,
    rank INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    play_count BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ARTIST ALBUMS
-- ============================================================
CREATE TABLE artist_albums (
    id SERIAL PRIMARY KEY,
    artist_id INTEGER NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    cover_url TEXT,
    album_type VARCHAR(20) DEFAULT 'album'
        CHECK (album_type IN ('album','single','EP','live','compilation')),
    release_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ARTIST ALBUM SONGS
-- ============================================================
CREATE TABLE artist_album_songs (
    album_id INTEGER REFERENCES artist_albums(id) ON DELETE CASCADE,
    song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
    track_number INTEGER,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (album_id, song_id)
);

-- ============================================================
-- PLAYLISTS
-- ============================================================
CREATE TABLE playlists (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    cover_url TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, name)
);

-- ============================================================
-- PLAYLIST SONGS
-- ============================================================
CREATE TABLE playlist_songs (
    playlist_id INTEGER REFERENCES playlists(id) ON DELETE CASCADE,
    song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, song_id)
);

-- ============================================================
-- FAVORITES
-- ============================================================
CREATE TABLE favorites (
    user_id VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, song_id)
);

-- ============================================================
-- HISTORY
-- ============================================================
CREATE TABLE history (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- INDEXES (FULL)
-- ============================================================

CREATE INDEX idx_users_email    ON users(email);
CREATE INDEX idx_users_username ON users(username);

CREATE INDEX idx_songs_artist   ON songs(artist_id);
CREATE INDEX idx_songs_rank     ON songs(rank DESC);
CREATE INDEX idx_songs_play     ON songs(play_count DESC);

CREATE INDEX idx_artist_albums_artist ON artist_albums(artist_id);
CREATE INDEX idx_album_songs_song ON artist_album_songs(song_id);

CREATE INDEX idx_playlists_user ON playlists(user_id);
CREATE INDEX idx_playlist_songs_song ON playlist_songs(song_id);

CREATE INDEX idx_favorites_song ON favorites(song_id);

CREATE INDEX idx_history_user      ON history(user_id);
CREATE INDEX idx_history_song      ON history(song_id);
CREATE INDEX idx_history_played_at ON history(played_at DESC);

-- ============================================================
-- TRIGGER
-- ============================================================
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
-- FULL IMPORT SCRIPT (READY TO RUN)
-- ============================================================

COPY users(id,taguser,username,password,email,full_name,avatar_url,role,is_active,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/users_db.csv' CSV HEADER;

COPY artists(id,full_name,avatar_url,bio,follower_count,is_verified,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/artist_db.csv' CSV HEADER;

COPY songs(id,title,artist_id,image_url,audio_url,rank,duration_seconds,play_count,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/songs_db.csv' CSV HEADER;

COPY artist_albums(id,artist_id,title,cover_url,album_type,release_date,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/artist_albums.csv' CSV HEADER;

COPY artist_album_songs(album_id,song_id,track_number,added_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/artist_album_songs.csv' CSV HEADER;

COPY playlists(id,user_id,name,cover_url,is_public,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/playlists.csv' CSV HEADER;

COPY playlist_songs(playlist_id,song_id,added_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/playlist_songs.csv' CSV HEADER;

COPY favorites(user_id,song_id,created_at)
FROM '/Users/asliin/Documents/Healing_music/healing_music_web/public/favorites.csv' CSV HEADER;


-- ============================================================
-- RESET PLAY COUNT (OPTIONAL)
-- ============================================================
UPDATE songs SET play_count = 0;

-- ============================================================
-- FIX SEQUENCE
-- ============================================================
SELECT setval('songs_id_seq', (SELECT MAX(id) FROM songs));
SELECT setval('artists_id_seq', (SELECT MAX(id) FROM artists));
SELECT setval('artist_albums_id_seq', (SELECT MAX(id) FROM artist_albums));
SELECT setval('playlists_id_seq', (SELECT MAX(id) FROM playlists));
SELECT setval('history_id_seq', (SELECT MAX(id) FROM history));

-- ============================================================
-- DONE
-- ============================================================