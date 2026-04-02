import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();

  switch (body['action']) {
    case 'addSong':
      return _addSong(conn, body);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

Future<Response> _addSong(Connection conn, dynamic body) async {
  final title = body['title'];
  final artistId = body['artistId'];
  final audioUrl = body['audioUrl'];
  final imageUrl = body['imageUrl'];
  final durationSeconds = body['durationSeconds'];

  // Validate
  if (title == null || title.toString().trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'title là bắt buộc'},
    );
  }
  if (audioUrl == null || audioUrl.toString().trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'audioUrl là bắt buộc'},
    );
  }
  if (artistId == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'artistId là bắt buộc'},
    );
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
        statusCode: 500,
        body: {'done': false, 'message': 'Insert thất bại'},
      );
    }

    final newId = rows.first[0]! as int;

    return Response.json(body: {
      'done': true,
      'id': newId,
      'message': 'Thêm bài hát thành công',
    });
  } catch (e) {
    print('Error addSong: $e');
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'Lỗi server: $e'},
    );
  }
}
