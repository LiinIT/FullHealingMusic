import 'dart:developer';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<dynamic> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    log(
      'Invalid HTTP method: ${context.request.method}',
      name: 'HandleFavoriteRoute',
    );
    return Response(statusCode: 405);
  }
  final body = await context.request.json();

  switch (body['action'] as String?) {
    case 'getAll':
      return _handleGetAllFavorite(body: body, connect: conn);
    case 'toggle':
      return _handleToggleFavorite(body: body, connect: conn);
    default:
      return _handleGetFavorite(body: body, connect: conn);
  }
}

Future<Response> _handleGetAllFavorite({
  required dynamic body,
  required Connection connect,
}) async {
  final userID = body['userID'] as String?;

  if (userID == null) {
    log('Missing userID in _handleGetAllFavorite',
        name: '_handleGetAllFavorite');
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
          s.rank,
          s.duration_seconds,
          s.created_at      AS song_created_at,

          -- artists fields
          a.id              AS artist_id,
          a.full_name,
          a.avatar_url,
          a.follower_count,
          a.is_verified
      FROM favorites f
        JOIN songs   s ON s.id = f.song_id
        JOIN artists a ON a.id = s.artist_id
      WHERE f.user_id = $1
      ORDER BY f.created_at DESC
      ''',
      parameters: [userID],
    );

    if (result.isEmpty) {
      log(
        'No favorite songs found for user: $userID',
        name: '_handleGetAllFavorite',
      );
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
            'rank': row[4],
            'duration_seconds': row[5],
            'song_created_at': row[6]?.toString(),

            // artists fields
            'artist_id': row[7],
            'full_name': row[8],
            'avatar_url': row[9],
            'follower_count': row[10],
            'is_verified': row[11],
          },
        )
        .toList();

    return Response.json(
      body: {'done': true, 'isEmpty': false, 'songs': songs},
    );
  } catch (e) {
    log(e.toString(), name: '_handleGetAllFavorite');
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'ERROR => $e'},
    );
  }
}

Future<Response> _handleGetFavorite({
  required dynamic body,
  required Connection connect,
}) async {
  final userID = body['userID'];
  final songID = body['songID'];

  if (userID == null || songID == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID or songID'},
    );
  }

  try {
    final result = await connect.execute(
      r'SELECT 1 FROM favorites WHERE user_id = $1 AND song_id = $2',
      parameters: [userID, songID],
    );

    return Response.json(
      body: {
        'done': true,
        'isFavorite': result.isNotEmpty,
      },
    );
  } catch (e) {
    log(e.toString(), name: '_handleGetFavorite');
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'ERROR => $e'},
    );
  }
}

Future<Response> _handleToggleFavorite({
  required dynamic body,
  required Connection connect,
}) async {
  // Validate input
  final userID = body['userID'];
  final songID = body['songID'];
  final isFavorite = body['isFavorite'] as bool?;

  if (userID == null || songID == null || isFavorite == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing userID, songID or isFavorite'},
    );
  }

  try {
    if (isFavorite) {
      // Thêm favorite
      await connect.execute(
        'INSERT INTO favorites (user_id, song_id) '
        r'VALUES ($1, $2) ON CONFLICT DO NOTHING',
        parameters: [userID, songID],
      );
    } else {
      // Xóa favorite
      await connect.execute(
        r'DELETE FROM favorites WHERE user_id = $1 AND song_id = $2',
        parameters: [userID, songID],
      );
    }

    return Response.json(body: {'done': true});
  } catch (e) {
    log(e.toString(), name: '_handleToggleFavorite');
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}
