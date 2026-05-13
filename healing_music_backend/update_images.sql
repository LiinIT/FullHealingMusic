-- Cập nhật avatar URL của artists
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_01.jpg' WHERE id = 1;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_02.jpg' WHERE id = 2;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_03.jpg' WHERE id = 3;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_04.jpg' WHERE id = 4;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_05.jpg' WHERE id = 5;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_06.jpg' WHERE id = 6;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_07.jpg' WHERE id = 7;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_08.jpg' WHERE id = 8;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_09.jpg' WHERE id = 9;
UPDATE artists SET avatar_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_01.jpg' WHERE id = 10;

-- Cập nhật tên artists
UPDATE artists SET full_name = 'Mây Trắng Studio' WHERE id = 1;
UPDATE artists SET full_name = 'Sóng Biển'        WHERE id = 2;
UPDATE artists SET full_name = 'Rừng Xanh Collective' WHERE id = 3;
UPDATE artists SET full_name = 'Ánh Trăng'        WHERE id = 4;
UPDATE artists SET full_name = 'Gió Nhẹ'          WHERE id = 5;
UPDATE artists SET full_name = 'Hơi Thở'          WHERE id = 6;
UPDATE artists SET full_name = 'Bình Yên'          WHERE id = 7;
UPDATE artists SET full_name = 'Thiên Nhiên'       WHERE id = 8;
UPDATE artists SET full_name = 'Tĩnh Lặng'         WHERE id = 9;
UPDATE artists SET full_name = 'Hoa Sen'           WHERE id = 10;

-- Cập nhật image_url và title của songs
UPDATE songs SET
  title     = 'Sớm Mai Bình Yên',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_01.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00001.mp3'
WHERE id = 1;

UPDATE songs SET
  title     = 'Giấc Ngủ Nhẹ',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_02.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00002.mp3'
WHERE id = 2;

UPDATE songs SET
  title     = 'Tiếng Mưa Rừng',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_03.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00003.mp3'
WHERE id = 3;

UPDATE songs SET
  title     = 'Gió Chiều Thổi Nhẹ',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_04.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00004.mp3'
WHERE id = 4;

UPDATE songs SET
  title     = 'Ánh Trăng Thu',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_05.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00005.mp3'
WHERE id = 5;

UPDATE songs SET
  title     = 'Mùa Thu Tĩnh Lặng',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_06.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00006.mp3'
WHERE id = 6;

UPDATE songs SET
  title     = 'Sen Nở Bình Minh',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_07.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00007.mp3'
WHERE id = 7;

UPDATE songs SET
  title     = 'Hương Đất Sau Mưa',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_08.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00008.mp3'
WHERE id = 8;

UPDATE songs SET
  title     = 'Về Bên Thiên Nhiên',
  image_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_09.jpg',
  audio_url = 'https://fullhealingmusic-production.up.railway.app/public/audios/00009.mp3'
WHERE id = 9;

-- Cập nhật cover_url của artist_albums
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_01.jpg', title = 'Healing Lofi Vol.1' WHERE id = 1;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_02.jpg', title = 'Morning Calm'       WHERE id = 2;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_03.jpg', title = 'Forest Sounds'    WHERE id = 3;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_05.jpg', title = 'Gentle Breeze'    WHERE id = 4;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_05.jpg', title = 'Moonlight Meditation' WHERE id = 5;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_06.jpg', title = 'Autumn Silence'       WHERE id = 6;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_07.jpg', title = 'Lotus Garden'         WHERE id = 7;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_08.jpg', title = 'Earth & Rain'         WHERE id = 8;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/artist/artist_04.jpg', title = 'Return to Nature'  WHERE id = 9;
UPDATE artist_albums SET cover_url = 'https://fullhealingmusic-production.up.railway.app/public/images/song/song_09.jpg', title = 'Best of Healing'       WHERE id = 10;
