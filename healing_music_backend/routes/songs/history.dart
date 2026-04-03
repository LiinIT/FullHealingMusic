import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<dynamic> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json();

  switch (body['action'] as String?) {
    case 'getAll':
      return _handleGetAllHistory(body: body, connect: conn);
    case 'add':
      return _handlePushHistory(body: body, connect: conn);
    case 'delete':
      return _handleDeleteHistory(body: body, connect: conn);
    case 'update':
      return _handleUpdateHistory(body: body, connect: conn);
  }
}

Future<Response> _handleUpdateHistory({
  required dynamic body,
  required Connection connect,
}) async {
  // Validate input
  final userID = body['userID'];
  final songID = body['songID'];

  if (userID == null || songID == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID, songID or history'},
    );
  }

  try {
    await connect.execute(
      r'''
          UPDATE history
          SET played_at = NOW()
          WHERE user_id = $1 AND song_id = $2;''',
      parameters: [userID, songID],
    );
    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}

Future<Response> _handlePushHistory({
  required dynamic body,
  required Connection connect,
}) async {
  // Validate input
  final userID = body['userID'];
  final songID = body['songID'];

  if (userID == null || songID == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID, songID or history'},
    );
  }

  try {
    await connect.execute(
      r'''
        INSERT INTO 
          history (user_id, song_id)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING''',
      parameters: [userID, songID],
    );
    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}

Future<Response> _handleDeleteHistory({
  required dynamic body,
  required Connection connect,
}) async {
  // Validate input
  final userID = body['userID'];
  final songID = body['songID'];

  if (userID == null || songID == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID, songID or history'},
    );
  }

  try {
    await connect.execute(
      r'''
        DELETE FROM 
          history 
        WHERE 
          user_id = $1 
          AND song_id = $2''',
      parameters: [userID, songID],
    );
    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}

Future<Response> _handleGetAllHistory({
  required dynamic body,
  required Connection connect,
}) async {
  final userID = body['userID'] as String?;
  if (userID == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID'},
    );
  }

  try {
    final result = await connect.execute(
      r'''
      SELECT
          -- songs fields
          s.id              AS song_id,
          s.title,
          s.image_url,
          s.audio_url,
          s.duration_seconds,
          s.created_at      AS song_created_at,

          -- artists fields
          a.id              AS artist_id,
          a.full_name,
          a.avatar_url,
          a.follower_count,
          a.is_verified
      FROM history h
        JOIN songs   s ON s.id = h.song_id
        JOIN artists a ON a.id = s.artist_id
      WHERE h.user_id = $1
      ORDER BY h.played_at DESC
      ''',
      parameters: [userID],
    );

    if (result.isEmpty) {
      return Response.json(
        body: {'done': true, 'isEmpty': true, 'songs': <dynamic>[]},
      );
    }

    final songs = result
        .map(
          (row) => {
            // songs fields
            'song_id': row[0],
            'title': row[1],
            'image_url': row[2],
            'audio_url': row[3],
            'duration_seconds': row[4],
            'song_created_at': row[5]?.toString(),

            // artists fields
            'artist_id': row[6],
            'full_name': row[7],
            'avatar_url': row[8],
            'follower_count': row[9],
            'is_verified': row[10],
          },
        )
        .toList();

    return Response.json(
      body: {'done': true, 'isEmpty': false, 'songs': songs},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'ERROR => $e'},
    );
  }
}
