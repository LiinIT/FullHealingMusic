import 'dart:developer';

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
    case 'addSongToAlbum':
      return addSongToAlbum(connect, body['albumID'], body['songID']);
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

Future<Response> addSongToAlbum(
  Connection connect,
  dynamic albumID,
  dynamic songID,
) async {
  if (albumID == null || songID == null) {
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
        INSERT INTO 
          album_songs (album_id, song_id, added_at)
        VALUES ($1, $2, $3)
        ON CONFLICT (album_id, song_id) DO NOTHING
      ''',
      parameters: [albumID, songID, DateTime.now()],
    );

    return Response.json(body: {'success': true});
  } catch (e, stackTrace) {
    log('❌ Error adding album: $e\n$stackTrace', name: 'AlbumRoute');
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Internal server error',
      },
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
          a.id,
          a.user_id,
          a.name,
          a.cover_url,
          a.created_at,
          COALESCE(
            JSON_AGG(
              JSON_BUILD_OBJECT(
                'id',               s.id,
                'title',            s.title,
                'artist_id',        s.artist_id,
                'full_name',        ar.full_name,      
                'avatar_url',       ar.avatar_url,     
                'follower_count',   ar.follower_count, 
                'is_verified',      ar.is_verified,    
                'image_url',        s.image_url,
                'audio_url',        s.audio_url,
                'rank',             s.rank,
                'duration_seconds', s.duration_seconds,
                'created_at',       s.created_at
              ) ORDER BY als.added_at ASC
            ) FILTER (WHERE s.id IS NOT NULL),
            '[]'
          ) AS list_song
        FROM
          albums a
        LEFT JOIN
          album_songs als ON als.album_id = a.id
        LEFT JOIN
          songs s ON s.id = als.song_id
        LEFT JOIN 
          artists ar ON ar.id = s.artist_id  
        WHERE
          a.user_id = $1
        GROUP BY
          a.id, a.user_id, a.name, a.cover_url, a.created_at
        ORDER BY
          a.created_at DESC
        ''',
      parameters: [userID],
    );

    final albums = result
        .toList()
        .map(
          (row) => {
            'id': row[0],
            'user_id': row[1],
            'name': row[2],
            'cover_url': row[3],
            'created_at': row[4]?.toString(),
            'listSong': row[5],
          },
        )
        .toList();

    return Response.json(body: {'done': true, 'albums': albums});
  } catch (e) {
    log('❌ Error fetching albums: $e', name: 'AlbumRoute');
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
    log('❌ Error fetching album: $e', name: 'AlbumRoute');
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
    log('❌ Error adding album: $e\n$stackTrace', name: 'AlbumRoute');
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Internal server error',
      },
    );
  }
}
