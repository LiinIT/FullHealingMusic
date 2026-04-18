-- ============================================================
-- HEALING MUSIC — FULL IMPORT SCRIPT FOR RAILWAY
-- Generated: 2026-04-18
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
CREATE INDEX idx_users_email       ON users(email);
CREATE INDEX idx_users_username    ON users(username);
CREATE INDEX idx_songs_artist      ON songs(artist_id);
CREATE INDEX idx_songs_rank        ON songs(rank DESC);
CREATE INDEX idx_songs_play        ON songs(play_count DESC);
CREATE INDEX idx_artist_albums_artist ON artist_albums(artist_id);
CREATE INDEX idx_album_songs_song  ON artist_album_songs(song_id);
CREATE INDEX idx_playlists_user    ON playlists(user_id);
CREATE INDEX idx_playlist_songs_song ON playlist_songs(song_id);
CREATE INDEX idx_favorites_song    ON favorites(song_id);
CREATE INDEX idx_history_user      ON history(user_id);
CREATE INDEX idx_history_song      ON history(song_id);
CREATE INDEX idx_history_played_at ON history(played_at DESC);

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
-- INSERT USERS (5 rows)
-- ============================================================
INSERT INTO users (id,taguser,username,password,email,full_name,avatar_url,role,is_active,created_at) VALUES
('20260403_a1','user001','liin','123456','liin@gmail.com','Liin Nguyen','https://i.pravatar.cc/150?img=1','USER',true,'2026-04-03 10:15:00'),
('20260403_a2','user002','anhtuan','123456','anhtuan@gmail.com','Anh Tuan','https://i.pravatar.cc/150?img=2','USER',true,'2026-04-03 10:16:00'),
('20260403_a3','user003','admin','admin123','admin@gmail.com','Admin','https://i.pravatar.cc/150?img=3','ADMIN',true,'2026-04-03 10:17:00'),
('20260403_a4','user004','mod1','mod123','mod@gmail.com','Moderator One','https://i.pravatar.cc/150?img=4','USER',true,'2026-04-03 10:18:00'),
('20260403_a5','user005','user5','123456','user5@gmail.com','User Five','https://i.pravatar.cc/150?img=5','USER',false,'2026-04-03 10:19:00');

-- ============================================================
-- INSERT ARTISTS (10 rows)
-- ============================================================
INSERT INTO artists (id,full_name,avatar_url,bio,follower_count,is_verified,created_at) VALUES
(1,'CaoTri Official','https://i.pravatar.cc/150?img=10','Nhà sản xuất âm nhạc và ca sĩ trẻ với nhiều sản phẩm Lofi chất lượng cao',15420,true,'2023-01-15 08:30:00'),
(2,'Nguyễn Vĩ','https://i.pravatar.cc/150?img=11','Ca sĩ sở hữu giọng hát ấm áp thường xuyên hợp tác với CaoTri Official',8750,false,'2023-02-20 10:15:00'),
(3,'F47','https://i.pravatar.cc/150?img=12','Nghệ sĩ cover với phong cách trẻ trung năng động',12340,false,'2023-03-10 14:20:00'),
(4,'Đặng Thanh Tuyền','https://i.pravatar.cc/150?img=13','Giọng ca nội lực với nhiều bản cover được yêu thích',9820,false,'2023-01-05 09:45:00'),
(5,'Yamix Hầu Ca','https://i.pravatar.cc/150?img=14','Rapper và nhạc sĩ với phong cách Lofi độc đáo',11250,false,'2023-02-28 16:30:00'),
(6,'Gấu','https://i.pravatar.cc/150?img=15','Nữ ca sĩ trẻ với chất giọng ngọt ngào',7890,false,'2023-03-15 11:00:00'),
(7,'Hùng Quân','https://i.pravatar.cc/150?img=16','Ca sĩ sáng tác với những ca khúc Lofi sâu lắng',14560,true,'2023-01-20 13:15:00'),
(8,'Mr T','https://i.pravatar.cc/150?img=17','Rapper và producer với nhiều năm kinh nghiệm',20450,true,'2022-12-10 08:00:00'),
(9,'Yanbi','https://i.pravatar.cc/150?img=18','Rapper nổi tiếng với phong cách âm nhạc đa dạng',38520,true,'2022-11-05 10:30:00'),
(10,'Duy Khiêm','https://i.pravatar.cc/150?img=19','Ca sĩ trẻ với giọng hát truyền cảm',6540,false,'2023-02-14 15:45:00');

-- ============================================================
-- INSERT SONGS (9 rows)
-- NOTE: thay YOUR_SERVER_URL bằng URL Railway sau khi deploy
-- ============================================================
INSERT INTO songs (id,title,artist_id,image_url,audio_url,duration_seconds,play_count,created_at) VALUES
(1,'Có Mình Và Ta',1,'YOUR_SERVER_URL/public/images/song/40b825abe1245b6573c03a8f47cfea49.jpg','YOUR_SERVER_URL/public/audios/00001.mp3',210,543210,'2023-03-25 09:30:00'),
(2,'Em Có Ổn Không',1,'YOUR_SERVER_URL/public/images/song/40096b96dd2369253bff23c0d86cbd07.jpg','YOUR_SERVER_URL/public/audios/00002.mp3',195,987654,'2023-03-20 14:15:00'),
(3,'Khách Mời',3,'YOUR_SERVER_URL/public/images/song/ca31d0fa1a7cf6e7f7bc7e2b0bb7d2f5.jpg','YOUR_SERVER_URL/public/audios/00003.mp3',225,123456,'2023-03-18 11:00:00'),
(4,'Lưới Phù Hoa',5,'YOUR_SERVER_URL/public/images/song/ab67616d0000b27352c7247d705ee97f4006c9c0.jpeg','YOUR_SERVER_URL/public/audios/00004.mp3',205,876543,'2023-03-15 16:20:00'),
(5,'Ngày Em Biết Nhớ Thương Một Người',7,'YOUR_SERVER_URL/public/images/song/tiengphaotiengnguoi.jpeg','YOUR_SERVER_URL/public/audios/00005.mp3',215,654321,'2023-03-10 10:45:00'),
(6,'Thu Cuối',8,'YOUR_SERVER_URL/public/images/song/artworks-000528353961-lo0sor-t500x500.jpg','YOUR_SERVER_URL/public/audios/00006.mp3',198,345678,'2023-03-05 13:30:00'),
(7,'Ví Dầu Đưa Dâu',10,'YOUR_SERVER_URL/public/images/song/43327c3c1913b136d577905e93e29bd4.jpg','YOUR_SERVER_URL/public/audios/00007.mp3',185,789012,'2023-02-28 09:15:00'),
(8,'Xin Má Rước Dâu',10,'YOUR_SERVER_URL/public/images/song/c44c3822217d8775780358df759f126d.jpg','YOUR_SERVER_URL/public/audios/00008.mp3',192,234567,'2023-02-25 15:00:00'),
(9,'Yên Phận Đi Nhé',4,'YOUR_SERVER_URL/public/images/song/f04876c1657a88baf7a76f0c58c67513.jpg','YOUR_SERVER_URL/public/audios/00009.mp3',208,912345,'2023-02-20 12:00:00');

-- ============================================================
-- INSERT ARTIST ALBUMS (10 rows)
-- ============================================================
INSERT INTO artist_albums (id,artist_id,title,cover_url,album_type,release_date,created_at) VALUES
(1,1,'Chill Lofi Vol.1','YOUR_SERVER_URL/public/images/artist/caotri.jpg','album','2023-03-25','2023-03-25 08:00:00'),
(2,1,'Lofi Healing','YOUR_SERVER_URL/public/images/artist/caotri.jpg','album','2023-02-20','2023-02-20 10:00:00'),
(3,3,'F47 Cover Collection','YOUR_SERVER_URL/public/images/artist/f47s.png','EP','2023-03-18','2023-03-18 14:00:00'),
(4,5,'Phù Hoa','YOUR_SERVER_URL/public/images/artist/7d00355583c6571daabb6ec3e541af1c.jpg','single','2023-03-15','2023-03-15 09:00:00'),
(5,7,'Lofi Tình Yêu','YOUR_SERVER_URL/public/images/artist/e2b19f291479da26e3cabf61ff637318.jpg','album','2023-03-10','2023-03-10 11:00:00'),
(6,8,'Mùa Thu','YOUR_SERVER_URL/public/images/artist/IMG_2114_zing.jpg','EP','2023-03-05','2023-03-05 16:00:00'),
(7,10,'Duy Khiêm Collection','YOUR_SERVER_URL/public/images/artist/channels4_profile.jpg','album','2023-02-28','2023-02-28 13:00:00'),
(8,10,'Dân Ca Remix','YOUR_SERVER_URL/public/images/artist/channels4_profile.jpg','EP','2023-02-25','2023-02-25 15:00:00'),
(9,4,'Yên Phận','YOUR_SERVER_URL/public/images/artist/16e3429b1d4e43e1996269f0cf40c0a2.jpg','single','2023-02-20','2023-02-20 12:00:00'),
(10,1,'Best of CaoTri','YOUR_SERVER_URL/public/images/artist/caotri.jpg','compilation','2023-03-01','2023-03-01 08:00:00');

-- ============================================================
-- INSERT ARTIST ALBUM SONGS (15 rows)
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
-- INSERT PLAYLISTS (8 rows)
-- ============================================================
INSERT INTO playlists (id,user_id,name,cover_url,is_public,created_at) VALUES
(1,'20260403_a1','Nhạc Chill','https://picsum.photos/400',true,'2026-04-03 11:00:00'),
(2,'20260403_a1','Workout','https://picsum.photos/401',false,'2026-04-03 11:05:00'),
(3,'20260403_a2','Top Hits','https://picsum.photos/402',true,'2026-04-03 11:10:00'),
(4,'20260403_a2','Relax','https://picsum.photos/403',false,'2026-04-03 11:15:00'),
(5,'20260403_a1','Night Vibes','https://picsum.photos/404',true,'2026-04-03 11:20:00'),
(6,'20260403_a2','EDM Mix','https://picsum.photos/405',true,'2026-04-03 11:25:00'),
(7,'20260403_a1','Love Songs','https://picsum.photos/406',false,'2026-04-03 11:30:00'),
(8,'20260403_a2','Focus','https://picsum.photos/407',true,'2026-04-03 11:35:00');

-- ============================================================
-- INSERT PLAYLIST SONGS (10 rows)
-- ============================================================
INSERT INTO playlist_songs (playlist_id,song_id,added_at) VALUES
(1,1,'2026-04-03 11:01:00'),
(1,2,'2026-04-03 11:02:00'),
(2,1,'2026-04-03 11:06:00'),
(3,2,'2026-04-03 11:11:00'),
(4,1,'2026-04-03 11:16:00'),
(5,2,'2026-04-03 11:21:00'),
(6,1,'2026-04-03 11:26:00'),
(7,2,'2026-04-03 11:31:00'),
(8,1,'2026-04-03 11:36:00'),
(8,2,'2026-04-03 11:37:00');

-- ============================================================
-- INSERT FAVORITES (4 rows)
-- ============================================================
INSERT INTO favorites (user_id,song_id,created_at) VALUES
('20260403_a1',1,'2026-04-03 12:00:00'),
('20260403_a1',2,'2026-04-03 12:01:00'),
('20260403_a2',1,'2026-04-03 12:02:00'),
('20260403_a5',2,'2026-04-03 12:03:00');

-- ============================================================
-- FIX SEQUENCES
-- ============================================================
SELECT setval('artists_id_seq',       (SELECT MAX(id) FROM artists));
SELECT setval('songs_id_seq',         (SELECT MAX(id) FROM songs));
SELECT setval('artist_albums_id_seq', (SELECT MAX(id) FROM artist_albums));
SELECT setval('playlists_id_seq',     (SELECT MAX(id) FROM playlists));
SELECT setval('history_id_seq',       1);

-- ============================================================
-- DONE ✓
-- ============================================================
