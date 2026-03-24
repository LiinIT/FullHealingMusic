import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  try {
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

    return Response.json(
      body: {
        'status': 'success',
        'message': '😎 Đã cập nhật $songsAdded '
            'bài hát cho ${artists.length} nghệ sĩ! 🏆 🏆 🏆',
      },
    );
  } catch (e) {
    return Response.json(
      body: {'status': 'error', 'message': e.toString()},
      statusCode: 500,
    );
  }
}
