import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();

  switch (body['action']) {
    case 'addArtist':
      return _addArtist(conn, body);
    case 'updateArtist':
      return _updateArtist(conn, body);
    case 'deleteArtist':
      return _deleteArtist(conn, body);
    case 'getAll':
      return _getAll(conn);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

// ─── ADD ─────────────────────────────────────────
Future<Response> _addArtist(Connection conn, dynamic body) async {
  final name = body['fullName'];
  final avatar = body['avatarUrl'];
  final bio = body['bio'];

  if (name == null || name.toString().trim().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Tên nghệ sĩ là bắt buộc'},
    );
  }

  try {
    final result = await conn.execute(
      r'''
        INSERT INTO artists (full_name, avatar_url, bio)
        VALUES ($1, $2, $3)
        RETURNING id
      ''',
      parameters: [
        name.toString().trim(),
        avatar ?? '',
        bio,
      ],
    );

    return Response.json(body: {
      'done': true,
      'id': result.first[0],
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ─── UPDATE ──────────────────────────────────────
Future<Response> _updateArtist(Connection conn, dynamic body) async {
  final id = body['artistId'];

  if (id == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'artistId bắt buộc'},
    );
  }

  final result = await conn.execute(
    r'''
      UPDATE artists SET
        full_name = COALESCE($1, full_name),
        avatar_url = COALESCE($2, avatar_url),
        bio = COALESCE($3, bio)
      WHERE id = $4
      RETURNING id
    ''',
    parameters: [
      body['fullName'],
      body['avatarUrl'],
      body['bio'],
      id,
    ],
  );

  if (result.isEmpty) {
    return Response.json(statusCode: 404, body: {'done': false});
  }

  return Response.json(body: {'done': true});
}

// ─── DELETE ──────────────────────────────────────
Future<Response> _deleteArtist(Connection conn, dynamic body) async {
  final id = body['artistId'];

  final result = await conn.execute(
    r'DELETE FROM artists WHERE id = $1 RETURNING id',
    parameters: [id],
  );

  if (result.isEmpty) {
    return Response.json(statusCode: 404, body: {'done': false});
  }

  return Response.json(body: {'done': true});
}

// ─── GET ALL ─────────────────────────────────────
Future<Response> _getAll(Connection conn) async {
  final result = await conn.execute(
    '''
      SELECT 
          a.*,  
      COUNT(s.id) AS song_count
      FROM artists a
      LEFT JOIN songs s ON s.artist_id = a.id
      GROUP BY a.id
      ORDER BY a.id DESC;''',
  );

  return Response.json(body: {
    'artists': result
        .map((r) => {
              'id': r[0],
              'full_name': r[1],
              'avatar_url': r[2],
              'bio': r[3],
            })
        .toList(),
  });
}
