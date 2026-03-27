import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connect = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json();

  switch (body['action']) {
    case 'addAlbum':
      return addAlbum(connect, body['userID'], body['nameAlbum']);
    case 'getAlbum':
      return getAlbum(connect, body['albumID']);
    case 'getAllAlbum':
      return getAllAlbum(connect, body['userID']);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

Future<Response> getAllAlbum(Connection connect, dynamic userID) async {
  if (userID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing userID',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT
          id,
          user_id,
          name,
          cover_url,
          created_at
        FROM 
          albums 
        WHERE 
          user_id = $1
        ORDER BY created_at DESC
        ''',
      parameters: [userID],
    );

    // Convert rows to list of maps
    final rows = result.toList();
    final albums = rows
        .map(
          (row) => {
            'id': row[0],
            'user_id': row[1],
            'name': row[2],
            'cover_url': row[3],
            'created_at': row[4]?.toString(),
          },
        )
        .toList();

    return Response.json(body: {'done': true, 'albums': albums});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch albums',
      },
    );
  }
}

Future<Response> getAlbum(Connection connect, dynamic albumID) async {
  if (albumID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumID',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT
          id,
          user_id,
          name,
          cover_url,
          created_at
        FROM 
          albums 
        WHERE 
          id = $1
        ''',
      parameters: [albumID],
    );

    final rows = result.toList();
    if (rows.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {
          'done': false,
          'message': 'Album not found',
        },
      );
    }

    final row = rows.first;
    final album = {
      'id': row[0],
      'user_id': row[1],
      'name': row[2],
      'cover_url': row[3],
      'created_at': row[4]?.toString(),
    };

    return Response.json(body: {'done': true, 'album': album});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch album',
      },
    );
  }
}

Future<Response> addAlbum(
  Connection connect,
  dynamic userID,
  dynamic nameAlbum,
) async {
  if (nameAlbum == null || userID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing nameAlbum or User ID',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        INSERT INTO albums (user_id, name, created_at)
        VALUES ($1, $2, $3)
        ON CONFLICT (user_id, name) DO NOTHING
        RETURNING id;
      ''',
      parameters: [userID, nameAlbum, DateTime.now()],
    );

    final rows = result.toList();
    final inserted = rows.isNotEmpty;
    final int? newId = inserted ? rows.first[0] as int? : null;

    return Response.json(
      body: {
        'done': inserted,
        if (inserted) 'id': newId,
        if (!inserted) 'message': 'Album already exists',
      },
    );
  } catch (e, stackTrace) {
    print('Error adding album: $e\n$stackTrace');
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Internal server error',
      },
    );
  }
}
