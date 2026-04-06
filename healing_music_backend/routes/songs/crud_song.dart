import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();

  switch (body['action']) {
    case 'getSongByID':
      return _getSongById(conn, body);
    case 'addSong':
      return _addSong(conn, body);
    case 'update':
      return _updateSong(conn, body);
    case 'delete':
      return _deleteSong(conn, body);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

Future<Response> _getSongById(Connection conn, dynamic body) async {
  final rawId = body['songId'];

  if (rawId == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'songId là bắt buộc'},
    );
  }

  // ✅ Parse sang int trong Dart, không dùng ::int trong SQL
  final int songId = int.parse(rawId.toString());

  try {
    final result = await conn.execute(
      r'''
    SELECT 
      s.id, s.title, s.audio_url, s.image_url, 
      s.duration_seconds, s.created_at,
      a.id as artist_id, a.full_name, a.avatar_url
    FROM songs s
    LEFT JOIN artists a ON s.artist_id = a.id
    WHERE s.id = $1
  ''',
      parameters: [songId],
    );

    if (result.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'done': false, 'message': 'Không tìm thấy bài hát'},
      );
    }

    final row = result.first;
    return Response.json(body: {
      'id': row[0],
      'title': row[1],
      'audio_url': row[2],
      'image_url': row[3],
      'duration_seconds': row[4],
      'created_at': row[5]?.toString(),
      'artist_id': row[6],
      'full_name': row[7],
      'avatar_url': row[8],
    });
  } catch (e, stackTrace) {
    print('Error getSongById: $e');
    print('StackTrace: $stackTrace');
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'Lỗi server: $e'},
    );
  }
}

// ─── ADD ─────────────────────────────────────────────────────────────────────
Future<Response> _addSong(Connection conn, dynamic body) async {
  final title = body['title'];
  final artistId = body['artistId'];
  final audioUrl = body['audioUrl'];
  final imageUrl = body['imageUrl'];
  final durationSeconds = body['durationSeconds'];

  if (title == null || title.toString().trim().isEmpty) {
    return Response.json(
        statusCode: 400, body: {'done': false, 'message': 'title là bắt buộc'});
  }
  if (audioUrl == null || audioUrl.toString().trim().isEmpty) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'audioUrl là bắt buộc'});
  }
  if (artistId == null) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'artistId là bắt buộc'});
  }

  try {
    final result = await conn.execute(
      r'''
        INSERT INTO songs (title, artist_id, audio_url, image_url, duration_seconds, created_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id
      ''',
      parameters: [
        title.toString().trim(),
        artistId,
        audioUrl.toString().trim(),
        imageUrl?.toString().trim(),
        durationSeconds,
        DateTime.now(),
      ],
    );

    final rows = result.toList();
    if (rows.isEmpty) {
      return Response.json(
          statusCode: 500, body: {'done': false, 'message': 'Insert thất bại'});
    }

    return Response.json(body: {
      'done': true,
      'id': rows.first[0]! as int,
      'message': 'Thêm bài hát thành công',
    });
  } catch (e) {
    print('Error addSong: $e');
    return Response.json(
        statusCode: 500, body: {'done': false, 'message': 'Lỗi server: $e'});
  }
}

// ─── UPDATE ──────────────────────────────────────────────────────────────────
Future<Response> _updateSong(Connection conn, dynamic body) async {
  final songId = body['songID'];
  final title = body['title'];
  final artistId = body['artistId'];
  final audioUrl = body['audioUrl'];
  final imageUrl = body['imageUrl'];
  final durationSeconds = body['durationSeconds'];

  if (songId == null) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'songID là bắt buộc'});
  }
  if (title == null || title.toString().trim().isEmpty) {
    return Response.json(
        statusCode: 400, body: {'done': false, 'message': 'title là bắt buộc'});
  }
  if (artistId == null) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'artistId là bắt buộc'});
  }
  if (audioUrl == null || audioUrl.toString().trim().isEmpty) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'audioUrl là bắt buộc'});
  }

  try {
    final result = await conn.execute(
      r'''
        UPDATE songs
        SET
          title = $1,
          artist_id = $2,
          audio_url = $3,
          image_url = COALESCE($4, image_url),
          duration_seconds = $5
        WHERE id = $6
        RETURNING id
      ''',
      parameters: [
        title.toString().trim(),
        artistId,
        audioUrl.toString().trim(),
        imageUrl?.toString().trim(),
        durationSeconds,
        songId,
      ],
    );

    if (result.isEmpty) {
      return Response.json(statusCode: 404, body: {
        'done': false,
        'message': 'Không tìm thấy bài hát ID: $songId'
      });
    }

    return Response.json(body: {
      'done': true,
      'id': songId,
      'message': 'Cập nhật thành công',
    });
  } catch (e) {
    print('Error updateSong: $e');
    return Response.json(
        statusCode: 500, body: {'done': false, 'message': 'Lỗi server: $e'});
  }
}

// ─── DELETE ──────────────────────────────────────────────────────────────────
Future<Response> _deleteSong(Connection conn, dynamic body) async {
  final songId = body['songID'];

  if (songId == null) {
    return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'songID là bắt buộc'});
  }

  try {
    final result = await conn.execute(
      r'DELETE FROM songs WHERE id = $1 RETURNING id',
      parameters: [songId],
    );

    if (result.isEmpty) {
      return Response.json(statusCode: 404, body: {
        'done': false,
        'message': 'Không tìm thấy bài hát ID: $songId'
      });
    }

    return Response.json(body: {
      'done': true,
      'id': songId,
      'message': 'Xoá bài hát thành công',
    });
  } catch (e) {
    print('Error deleteSong: $e');
    return Response.json(
        statusCode: 500, body: {'done': false, 'message': 'Lỗi server: $e'});
  }
}
