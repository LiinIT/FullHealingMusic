--TRUNCATE TABLE history      CASCADE;


-- ═══════════════════════════════════════════
-- RESET
-- ═══════════════════════════════════════════
DROP TABLE IF EXISTS favorites    CASCADE;
DROP TABLE IF EXISTS theme_user   CASCADE;
DROP TABLE IF EXISTS album_songs  CASCADE;
DROP TABLE IF EXISTS albums       CASCADE;
DROP TABLE IF EXISTS history      CASCADE;
DROP TABLE IF EXISTS songs        CASCADE;
DROP TABLE IF EXISTS artists      CASCADE;
DROP TABLE IF EXISTS users        CASCADE;


-- ═══════════════════════════════════════════
-- TABLES
-- ═══════════════════════════════════════════
CREATE TABLE users (
    id         VARCHAR(70) PRIMARY KEY DEFAULT (
                   TO_CHAR(NOW(), 'YYYYMMDD_HH24MISS_') ||
                   SUBSTRING(MD5(RANDOM()::TEXT), 1, 33)
               ),
    username   VARCHAR(50)  UNIQUE NOT NULL,
    password   TEXT         NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    full_name  VARCHAR(100),
    avatar_url TEXT,
    role       VARCHAR(20)  DEFAULT 'USER',
    is_active  BOOLEAN      DEFAULT true,
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artists (
    id             SERIAL PRIMARY KEY,
    full_name      VARCHAR(255) NOT NULL,
    avatar_url     TEXT         NOT NULL,
    follower_count INTEGER      DEFAULT 0,
    is_verified    BOOLEAN      DEFAULT false,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE songs (
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    artist_id        INTEGER REFERENCES artists(id) ON DELETE SET NULL,
    image_url        TEXT,
    audio_url        TEXT    NOT NULL,
    rank             INTEGER DEFAULT 0,
    duration_seconds INTEGER,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE favorites (
    user_id    VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    song_id    INTEGER     REFERENCES songs(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, song_id)
);

CREATE TABLE history (
    user_id   VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    song_id   INTEGER     REFERENCES songs(id) ON DELETE CASCADE,
    played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE history
ADD CONSTRAINT unique_user_song UNIQUE (user_id, song_id);

CREATE TABLE albums (
    id         SERIAL PRIMARY KEY,
    user_id    VARCHAR(70) REFERENCES users(id) ON DELETE CASCADE,
    name       VARCHAR(255) NOT NULL,
    cover_url  TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE album_songs (
    album_id INTEGER REFERENCES albums(id) ON DELETE CASCADE,
    song_id  INTEGER REFERENCES songs(id)  ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (album_id, song_id)
);


CREATE TABLE theme_user (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(70) UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    light_mode BOOLEAN DEFAULT TRUE
);

-- ═══════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════
CREATE INDEX idx_history_user_id  ON history(user_id);
CREATE INDEX idx_history_played_at ON history(played_at DESC);
CREATE INDEX idx_album_songs_album_id ON album_songs(album_id);


-- ═══════════════════════════════════════════
-- TRIGGER: giới hạn history 50 bài / user
-- ═══════════════════════════════════════════
CREATE OR REPLACE FUNCTION limit_history()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM history WHERE user_id = NEW.user_id) >= 50 THEN
    DELETE FROM history
    WHERE id = (
      SELECT id FROM history
      WHERE user_id = NEW.user_id
      ORDER BY played_at ASC
      LIMIT 1
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_limit_history
BEFORE INSERT ON history
FOR EACH ROW EXECUTE FUNCTION limit_history();


-- ═══════════════════════════════════════════
-- SEED DATA
-- ═══════════════════════════════════════════
INSERT INTO users (username, password, email, full_name, role)
VALUES ('admin', '1', 'asliin@healing.com', 'Ngoc Khanh Ho', 'ADMIN');


-- INSERT INTO history(user_id, song_id)
-- VALUES ('', '');

-- SELECT
--           songs fields
--           s.id              AS song_id,
--           s.title,
--           s.image_url,
--           s.audio_url,
--           s.rank,
--           s.duration_seconds,
--           s.created_at      AS song_created_at,

--           artists fields
--           a.id              AS artist_id,
--           a.full_name,
--           a.avatar_url,
--           a.follower_count,
--           a.is_verified
--       FROM history h
--         JOIN songs   s ON s.id = h.song_id
--         JOIN artists a ON a.id = s.artist_id
--       WHERE f.user_id = $1
--       ORDER BY f.created_at DESC


-- SELECT *
--         FROM users u
--         WHERE u.id = '20260323_085805_ec94206150e2e6c72f2337dbaa0e3070'