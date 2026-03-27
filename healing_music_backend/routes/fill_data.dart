import 'dart:convert';
import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();
  final apis = <String>[
    // V-Pop (Việt Nam)
    'Son Tung M-TP', 'Hoang Thuy Linh', 'Den Vau', 'HIEUTHUHAI', 'tlow',
    'Suni Ha Linh', 'Mono', 'TLinh', 'Grey D', 'Phuong Ly',
    'Duc Phuc', 'Erik', 'Min', 'Noo Phuoc Thinh', 'Suboi',

    // US-UK (Quốc tế)
    'Taylor Swift', 'Ed Sheeran', 'Adele',
    'Billie Eilish', 'Dua Lipa', 'Charlie Puth', 'Maroon 5',
  ];

  int count = 0;
  // Gọi sang Deezer
  for (final nameArtist in apis) {
    final deezerUrl = Uri.parse('https://api.deezer.com/search?q=$nameArtist');

    final response = await http.get(deezerUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data'][0]['artist']['id'].toString();
      final fullName = data['data'][0]['artist']['name'].toString();
      final avatarUrl = data['data'][0]['artist']['picture_xl'].toString();
      final random = Random();
      final int followerCount = 1000 + random.nextInt(1000000 - 1000 + 1);
      final bool isVerified = followerCount > 500000;

      await conn.execute(
        r'''
        INSERT INTO 
          artists(id, full_name, avatar_url, follower_count, is_verified) 
        VALUES 
          ($1, $2, $3, $4, $5) 
        ON CONFLICT (id) DO UPDATE 
        SET full_name = EXCLUDED.full_name, 
        avatar_url = EXCLUDED.avatar_url;''',
        parameters: [id, fullName, avatarUrl, followerCount, isVerified],
      );
      count++;
      print('✅ ✅ ✅ Fill artist [action]: $fullName ');
    } else {
      final data = jsonDecode(response.body);
      final fullName = data['data'][0]['artist']['name'].toString();
      print('❌ ❌ ❌ Fill artist [break]: $fullName ');
    }
  }

  print('🏆 🏆 🏆 Fill artist: END. We having $count artists 🧑‍🎨. 🏆 🏆 🏆 ');
  Future.delayed(const Duration(milliseconds: 2), () => _handleFillSong(conn));

  return Response.json(
    body: {
      'status': 'success',
      'message': '😎 Fill artist: END. We having $count artists 🧑‍🎨!',
    },
  );
}

Future<void> _handleFillSong(Connection conn) async {
  // 1. Lấy danh sách nghệ sĩ từ DB
  final result = await conn.execute('SELECT id, full_name FROM artists');

  // Convert result sang List để dễ xử lý
  final artists = result.map((row) => row.toColumnMap()).toList();
  int songsAdded = 0;
  // 2. Duyệt qua từng nghệ sĩ để lấy bài hát từ Deezer
  for (final artist in artists) {
    final artistId = artist['id'] as int;
    final artistName = artist['name'].toString();

    // Encode tên nghệ sĩ để search chính xác
    final query = Uri.encodeComponent(artistId.toString());
    final deezerUrl =
        Uri.parse('https://api.deezer.com/artist/$query/top?limit=50');

    final response = await http.get(deezerUrl);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Bây giờ bạn có thể lấy 'data' (danh sách bài hát) mà không bị lỗi
      final List tracks = data['data'] as List;

      for (final track in tracks) {
        final artistData = track['artist'] as Map<String, dynamic>;
        final trackTitle = track['title'].toString();
        final apiArtistName = artistData['name'].toString().toLowerCase();

        // Tên nghệ sĩ bạn đang duyệt từ danh sách apis của mình
        final targetName = artistName.toLowerCase();

        await conn.execute(
          r'''
              INSERT INTO 
                  songs (
                    title, 
                    artist_id, 
                    image_url, 
                    audio_url, 
                    duration_seconds)
              VALUES ($1, $2, $3, $4, $5)
              ON CONFLICT DO NOTHING
            ''',
          parameters: [
            track['title'],
            artistId,
            track['album']['cover_medium'],
            track['preview'],
            track['duration'],
          ],
        );
        songsAdded++;
        print('✅ Thêm bài hát: 📀 $trackTitle 👉 $apiArtistName');
      }
    }
    // Nghỉ 1 chút để không bị Deezer chặn
    await Future.delayed(const Duration(milliseconds: 100));
  }

  print('😎 Đã cập nhật $songsAdded '
      'bài hát cho ${artists.length} nghệ sĩ! 🏆 🏆 🏆');
}
