-- ============================================================
-- HEALING MUSIC — FULL RESET & IMPORT SCRIPT
-- ============================================================

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
-- INDEXES
-- ============================================================
CREATE INDEX idx_users_email          ON users(email);
CREATE INDEX idx_users_username       ON users(username);
CREATE INDEX idx_songs_artist         ON songs(artist_id);
CREATE INDEX idx_songs_rank           ON songs(rank DESC);
CREATE INDEX idx_songs_play           ON songs(play_count DESC);
CREATE INDEX idx_artist_albums_artist ON artist_albums(artist_id);
CREATE INDEX idx_album_songs_song     ON artist_album_songs(song_id);
CREATE INDEX idx_playlists_user       ON playlists(user_id);
CREATE INDEX idx_playlist_songs_song  ON playlist_songs(song_id);
CREATE INDEX idx_favorites_song       ON favorites(song_id);
CREATE INDEX idx_history_user         ON history(user_id);
CREATE INDEX idx_history_song         ON history(song_id);
CREATE INDEX idx_history_played_at    ON history(played_at DESC);

-- ============================================================
-- TRIGGER — auto increment play_count
-- ============================================================
CREATE OR REPLACE FUNCTION fn_increment_play_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE songs SET play_count = play_count + 1 WHERE id = NEW.song_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_increment_play_count
AFTER INSERT ON history
FOR EACH ROW EXECUTE FUNCTION fn_increment_play_count();

-- ============================================================
-- INSERT ARTISTS
-- ============================================================
INSERT INTO artists (id,full_name,avatar_url,bio,follower_count,is_verified,created_at) VALUES
(1,'Mây Trắng Studio','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_01.jpg','Nhà sản xuất âm nhạc chuyên về thể loại Ambient và Healing Music giúp thư giãn tâm trí',15420,true,'2023-01-15 08:30:00'),
(2,'Sóng Biển','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_02.jpg','Nghệ sĩ độc lập với những bản nhạc lấy cảm hứng từ thiên nhiên biển cả',8750,false,'2023-02-20 10:15:00'),
(3,'Rừng Xanh Collective','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_03.jpg','Nhóm nhạc sĩ sáng tác nhạc thiên nhiên và tiếng rừng',12340,false,'2023-03-10 14:20:00'),
(4,'Ánh Trăng','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_04.jpg','Nghệ sĩ nhạc thiền định với phong cách nhẹ nhàng sâu lắng',9820,false,'2023-01-05 09:45:00'),
(5,'Gió Nhẹ','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_05.jpg','Nhạc sĩ instrumental chuyên tạo ra không gian âm thanh bình yên',11250,false,'2023-02-28 16:30:00'),
(6,'Hơi Thở','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_06.jpg','Nghệ sĩ âm nhạc thiền với các bài tập thở và thư giãn',7890,false,'2023-03-15 11:00:00'),
(7,'Bình Yên','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_07.jpg','Nhạc sĩ sáng tác với những giai điệu êm dịu và chữa lành',14560,true,'2023-01-20 13:15:00'),
(8,'Thiên Nhiên','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_08.jpg','Producer chuyên về nhạc thiên nhiên và soundscape thư giãn',20450,true,'2022-12-10 08:00:00'),
(9,'Tĩnh Lặng','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_09.jpg','Nghệ sĩ âm nhạc tối giản với triết lý âm thanh chữa lành',38520,true,'2022-11-05 10:30:00'),
(10,'Hoa Sen','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_01.jpg','Nhạc sĩ truyền thống kết hợp nhạc cụ dân tộc với âm thanh hiện đại',6540,false,'2023-02-14 15:45:00');

-- ============================================================
-- INSERT SONGS
-- ============================================================
INSERT INTO songs (id,title,artist_id,image_url,audio_url,rank,duration_seconds,play_count,created_at) VALUES
(1,'Sớm Mai Bình Yên',1,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_01.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00001.mp3',9,210,543210,'2023-03-25 09:30:00'),
(2,'Giấc Ngủ Nhẹ',1,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_02.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00002.mp3',8,195,987654,'2023-03-20 14:15:00'),
(3,'Tiếng Mưa Rừng',3,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_03.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00003.mp3',7,225,123456,'2023-03-18 11:00:00'),
(4,'Gió Chiều Thổi Nhẹ',5,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_04.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00004.mp3',10,205,876543,'2023-03-15 16:20:00'),
(5,'Ánh Trăng Thu',7,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_05.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00005.mp3',6,215,654321,'2023-03-10 10:45:00'),
(6,'Mùa Thu Tĩnh Lặng',8,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_06.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00006.mp3',5,198,345678,'2023-03-05 13:30:00'),
(7,'Sen Nở Bình Minh',10,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_07.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00007.mp3',4,185,789012,'2023-02-28 09:15:00'),
(8,'Hương Đất Sau Mưa',10,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_08.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00008.mp3',3,192,234567,'2023-02-25 15:00:00'),
(9,'Về Bên Thiên Nhiên',4,'https://fullhealingmusic-production.up.railway.app/public/images/song/song_09.jpg','https://fullhealingmusic-production.up.railway.app/public/audios/00009.mp3',7,208,912345,'2023-02-20 12:00:00');

-- ============================================================
-- INSERT ARTIST ALBUMS
-- ============================================================
INSERT INTO artist_albums (id,artist_id,title,cover_url,album_type,release_date,created_at) VALUES
(1,1,'Healing Lofi Vol.1','https://fullhealingmusic-production.up.railway.app/public/images/song/song_01.jpg','album','2023-03-25','2023-03-25 08:00:00'),
(2,1,'Morning Calm','https://fullhealingmusic-production.up.railway.app/public/images/song/song_02.jpg','album','2023-02-20','2023-02-20 10:00:00'),
(3,3,'Forest Sounds','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_03.jpg','EP','2023-03-18','2023-03-18 14:00:00'),
(4,5,'Gentle Breeze','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_05.jpg','single','2023-03-15','2023-03-15 09:00:00'),
(5,7,'Moonlight Meditation','https://fullhealingmusic-production.up.railway.app/public/images/song/song_05.jpg','album','2023-03-10','2023-03-10 11:00:00'),
(6,8,'Autumn Silence','https://fullhealingmusic-production.up.railway.app/public/images/song/song_06.jpg','EP','2023-03-05','2023-03-05 16:00:00'),
(7,10,'Lotus Garden','https://fullhealingmusic-production.up.railway.app/public/images/song/song_07.jpg','album','2023-02-28','2023-02-28 13:00:00'),
(8,10,'Earth & Rain','https://fullhealingmusic-production.up.railway.app/public/images/song/song_08.jpg','EP','2023-02-25','2023-02-25 15:00:00'),
(9,4,'Return to Nature','https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_04.jpg','single','2023-02-20','2023-02-20 12:00:00'),
(10,1,'Best of Healing','https://fullhealingmusic-production.up.railway.app/public/images/song/song_09.jpg','compilation','2023-03-01','2023-03-01 08:00:00');

-- ============================================================
-- INSERT ARTIST ALBUM SONGS
-- ============================================================
INSERT INTO artist_album_songs (album_id,song_id,track_number,added_at) VALUES
(1,1,1,'2023-03-25 08:30:00'),
(1,2,2,'2023-03-25 08:30:00'),
(2,1,1,'2023-02-20 10:30:00'),
(2,2,2,'2023-02-20 10:30:00'),
(3,3,1,'2023-03-18 14:30:00'),
(4,4,1,'2023-03-15 09:30:00'),
(5,5,1,'2023-03-10 11:30:00'),
(6,6,1,'2023-03-05 16:30:00'),
(7,7,1,'2023-02-28 13:30:00'),
(7,8,2,'2023-02-28 13:30:00'),
(8,7,1,'2023-02-25 15:30:00'),
(8,8,2,'2023-02-25 15:30:00'),
(9,9,1,'2023-02-20 12:30:00'),
(10,1,1,'2023-03-01 08:30:00'),
(10,2,2,'2023-03-01 08:30:00'),
(10,5,3,'2023-03-01 08:30:00');

-- ============================================================
-- FIX SEQUENCES
-- ============================================================
SELECT setval('artists_id_seq',       (SELECT MAX(id) FROM artists));
SELECT setval('songs_id_seq',         (SELECT MAX(id) FROM songs));
SELECT setval('artist_albums_id_seq', (SELECT MAX(id) FROM artist_albums));
SELECT setval('playlists_id_seq',     1);
SELECT setval('history_id_seq',       1);

-- ============================================================
-- DONE
-- ============================================================
