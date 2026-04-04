import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connect = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  if (body == null || body is! Map) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Invalid body'},
    );
  }

  switch (body['action']) {
    case 'addAlbum':
      return addAlbum(
        connect,
        body['artistId'],
        body['title'],
        body['albumType'],
        body['coverUrl'],
      );
    case 'updateAlbum':
      return updateAlbum(
        connect,
        body['albumId'],
        body['artistId'],
        body['title'],
        body['albumType'],
        body['coverUrl'],
      );
    case 'addSongToAlbum':
      return addSongToAlbum(
        connect,
        body['albumId'],
        body['songId'],
        body['trackNumber'],
      );
    case 'getAllAlbums':
      return getAllAlbums(connect);
    case 'getAlbum':
      return getAlbum(connect, body['albumId']);
    case 'getAllAlbumsByArtist':
      return getAllAlbumsByArtist(connect, body['artistId']);
    case 'getSongsInAlbum':
      return getSongsInAlbum(connect, body['albumId']);
    case 'deleteAlbum':
      return deleteAlbum(connect, body['albumId']);
    case 'removeSongFromAlbum':
      return removeSongFromAlbum(connect, body['albumId'], body['songId']);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

// ============================================================
// ADD ALBUM
// ============================================================

Future<Response> addAlbum(
  Connection connect,
  dynamic artistId,
  dynamic title,
  dynamic albumType,
  dynamic coverUrl,
) async {
  if (artistId == null || title == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing artistId or title'},
    );
  }

  final int artistIdParsed = int.tryParse(artistId.toString()) ?? 0;

  try {
    final result = await connect.execute(
      r'''
      INSERT INTO artist_albums (artist_id, title, cover_url, album_type, release_date, created_at)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id;
      ''',
      parameters: [
        artistIdParsed,
        title,
        coverUrl ?? 'https://picsum.photos/500',
        albumType ?? 'album',
        DateTime.now().toIso8601String().split('T').first,
        DateTime.now(),
      ],
    );

    final rows = result.toList();

    return Response.json(
      body: {
        'done': rows.isNotEmpty,
        if (rows.isNotEmpty) 'id': rows.first[0],
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}
// ============================================================
// Update ALBUM
// ============================================================

Future<Response> updateAlbum(
  Connection connect,
  dynamic albumId,
  dynamic artistId,
  dynamic title,
  dynamic albumType,
  dynamic coverUrl,
) async {
  if (artistId == null || title == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing artistId or title'},
    );
  }

  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;
  final int artistIdParsed = int.tryParse(artistId.toString()) ?? 0;

  try {
    final result = await connect.execute(
      r'''
      UPDATE artist_albums 
      SET 
        artist_id = $2, 
        title = $3, 
        album_type = $4, 
        cover_url = $5 
      WHERE id = $1
      RETURNING id;
      ''',
      parameters: [
        albumIdParsed,
        artistIdParsed,
        title,
        albumType ?? 'album',
        coverUrl ?? '',
      ],
    );

    final rows = result.toList();

    return Response.json(
      body: {
        'done': rows.isNotEmpty,
        if (rows.isNotEmpty) 'id': rows.first[0],
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ============================================================
// ADD SONG TO ALBUM
// ============================================================

Future<Response> addSongToAlbum(
  Connection connect,
  dynamic albumId,
  dynamic songId,
  dynamic trackNumber,
) async {
  if (albumId == null || songId == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false},
    );
  }

  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;
  final int songIdParsed = int.tryParse(songId.toString()) ?? 0;

  try {
    await connect.execute(
      r'''
      INSERT INTO artist_album_songs (album_id, song_id, track_number, added_at)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (album_id, song_id)
      DO UPDATE SET track_number = EXCLUDED.track_number
      ''',
      parameters: [
        albumIdParsed,
        songIdParsed,
        trackNumber ?? 999,
        DateTime.now(),
      ],
    );

    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ============================================================
// GET ALL ALBUMS
// ============================================================

Future<Response> getAllAlbums(Connection connect) async {
  try {
    final result = await connect.execute('''
      SELECT
        a.id,
        a.artist_id,
        a.title,
        a.cover_url,
        a.album_type,
        a.release_date,
        a.created_at,
        ar.full_name,
        ar.avatar_url,
        ar.follower_count,
        ar.is_verified,
        COUNT(aas.song_id)
      FROM artist_albums a
      LEFT JOIN artists ar ON ar.id = a.artist_id
      LEFT JOIN artist_album_songs aas ON aas.album_id = a.id
      GROUP BY a.id, ar.id
      ORDER BY a.release_date DESC
    ''');

    final albums = result.map((row) {
      return {
        'id': row[0],
        'artist_id': row[1],
        'title': row[2],
        'cover_url': row[3],
        'album_type': row[4],
        'release_date': row[5]?.toString(),
        'created_at': row[6]?.toString(),
        'total_songs': (row[11] as int?) ?? 0,
        'artist': {
          'id': row[1],
          'full_name': row[7],
          'avatar_url': row[8],
          'follower_count': row[9],
          'is_verified': row[10],
        }
      };
    }).toList();

    return Response.json(body: {'done': true, 'albums': albums});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ============================================================
// GET ALBUM
// ============================================================

Future<Response> getAlbum(Connection connect, dynamic albumId) async {
  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;

  final result = await connect.execute(
    r'SELECT * FROM artist_albums WHERE id = $1',
    parameters: [albumIdParsed],
  );

  if (result.isEmpty) {
    return Response.json(statusCode: 404, body: {'done': false});
  }

  return Response.json(body: {'done': true, 'album': result.first});
}

// ============================================================
// GET ALBUMS BY ARTIST
// ============================================================

Future<Response> getAllAlbumsByArtist(
  Connection connect,
  dynamic artistId,
) async {
  final int artistIdParsed = int.tryParse(artistId.toString()) ?? 0;

  try {
    final result = await connect.execute(
      r'''
      SELECT
        a.id,
        a.title,
        COUNT(aas.song_id),
        COALESCE(
          JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', s.id,
              'title', s.title
            )
          ) FILTER (WHERE s.id IS NOT NULL),
          '[]'
        )
      FROM artist_albums a
      LEFT JOIN artist_album_songs aas ON aas.album_id = a.id
      LEFT JOIN songs s ON s.id = aas.song_id
      WHERE a.artist_id = $1
      GROUP BY a.id
      ''',
      parameters: [artistIdParsed],
    );

    final data = result.map((row) {
      return {
        'id': row[0],
        'title': row[1],
        'total_songs': row[2],
        'songs': row[3],
      };
    }).toList();

    return Response.json(body: {'done': true, 'albums': data});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ============================================================
// GET SONGS IN ALBUM
// ============================================================
Future<Response> getSongsInAlbum(
  Connection connect,
  dynamic albumId,
) async {
  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;

  final result = await connect.execute(
    r'''
    SELECT s.id, s.title, s.play_count, s.image_url
    FROM artist_album_songs aas
    JOIN songs s ON s.id = aas.song_id
    WHERE aas.album_id = $1
    ORDER BY aas.track_number
    ''',
    parameters: [albumIdParsed],
  );

  final songs = result
      .map(
        (row) => {
          'id': row[0],
          'title': row[1],
          'play_count': row[2],
          'image_url': row[3],
        },
      )
      .toList();

  return Response.json(
    body: {'done': true, 'songs': songs},
  );
}

// ============================================================
// DELETE ALBUM
// ============================================================

Future<Response> deleteAlbum(
  Connection connect,
  dynamic albumId,
) async {
  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;

  try {
    final result = await connect.execute(
      r'DELETE FROM artist_albums WHERE id = $1 RETURNING id',
      parameters: [albumIdParsed],
    );

    return Response.json(body: {'done': result.isNotEmpty});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ============================================================
// REMOVE SONG FROM ALBUM
// ============================================================

Future<Response> removeSongFromAlbum(
  Connection connect,
  dynamic albumId,
  dynamic songId,
) async {
  final int albumIdParsed = int.tryParse(albumId.toString()) ?? 0;
  final int songIdParsed = int.tryParse(songId.toString()) ?? 0;

  final result = await connect.execute(
    r'''
    DELETE FROM artist_album_songs
    WHERE album_id = $1 AND song_id = $2
    RETURNING album_id
    ''',
    parameters: [albumIdParsed, songIdParsed],
  );

  return Response.json(body: {'done': result.isNotEmpty});
}
