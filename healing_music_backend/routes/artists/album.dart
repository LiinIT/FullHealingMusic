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
      return addAlbum(
        connect,
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

// Thêm album mới
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
      body: {
        'done': false,
        'message': 'Missing artistId or title',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        INSERT INTO artist_albums (artist_id, title, cover_url, album_type, release_date, created_at)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id;
      ''',
      parameters: [
        artistId,
        title,
        coverUrl ?? 'https://picsum.photos/id/15/500/500',
        albumType ?? 'album',
        DateTime.now(),
        DateTime.now(),
      ],
    );

    final rows = result.toList();
    final inserted = rows.isNotEmpty;
    final int? newId = inserted ? rows.first[0] as int? : null;

    return Response.json(
      body: {
        'done': inserted,
        if (inserted) 'id': newId,
        if (!inserted) 'message': 'Failed to create album',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Internal server error: $e',
      },
    );
  }
}

// Thêm bài hát vào album
Future<Response> addSongToAlbum(
  Connection connect,
  dynamic albumId,
  dynamic songId,
  dynamic trackNumber,
) async {
  if (albumId == null || songId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumId or songId',
      },
    );
  }

  try {
    // Kiểm tra album tồn tại
    final albumCheck = await connect.execute(
      r'SELECT id FROM artist_albums WHERE id = $1',
      parameters: [albumId],
    );

    if (albumCheck.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {
          'done': false,
          'message': 'Album not found',
        },
      );
    }

    // Kiểm tra bài hát tồn tại
    final songCheck = await connect.execute(
      r'SELECT id FROM songs WHERE id = $1',
      parameters: [songId],
    );

    if (songCheck.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {
          'done': false,
          'message': 'Song not found',
        },
      );
    }

    // Thêm vào album
    await connect.execute(
      r'''
        INSERT INTO artist_album_songs (album_id, song_id, track_number, added_at)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (album_id, song_id) DO UPDATE 
        SET track_number = EXCLUDED.track_number,
            added_at = EXCLUDED.added_at
      ''',
      parameters: [albumId, songId, trackNumber ?? 999, DateTime.now()],
    );

    return Response.json(
      body: {
        'done': true,
        'message': 'Song added to album successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Internal server error: $e',
      },
    );
  }
}

Future<Response> getAllAlbums(Connection connect) async {
  try {
    final result = await connect.execute(
      '''
        SELECT
          a.id,
          a.artist_id,
          a.title,
          a.cover_url,
          a.album_type,
          a.release_date,
          a.created_at,
          ar.full_name as artist_name,
          ar.avatar_url as artist_avatar,
          ar.follower_count,
          ar.is_verified,
          COUNT(aas.song_id) as total_songs
        FROM 
          artist_albums a
        LEFT JOIN
          artists ar ON ar.id = a.artist_id
        LEFT JOIN
          artist_album_songs aas ON aas.album_id = a.id
        GROUP BY
          a.id, a.artist_id, a.title, a.cover_url, a.album_type, 
          a.release_date, a.created_at, ar.full_name, ar.avatar_url, 
          ar.follower_count, ar.is_verified
        ORDER BY
          a.release_date DESC
        ''',
    );

    final rows = result.toList();

    // FIXED: Trả về danh sách album thay vì chỉ một album
    final albums = rows.map((row) {
      return {
        'id': row[0],
        'artist_id': row[1],
        'title': row[2],
        'cover_url': row[3],
        'album_type': row[4],
        'release_date': row[5]?.toString(),
        'created_at': row[6]?.toString(),
        'total_songs': row[11] ?? 0,
        'artist': {
          'id': row[1],
          'full_name': row[7],
          'avatar_url': row[8],
          'follower_count': row[9],
          'is_verified': row[10],
        },
      };
    }).toList();

    return Response.json(
      body: {
        'done': true,
        'albums': albums,
        'total': albums.length,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch albums: $e',
      },
    );
  }
}

// Lấy thông tin album theo ID
Future<Response> getAlbum(Connection connect, dynamic albumId) async {
  if (albumId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumId',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT
          a.id,
          a.artist_id,
          a.title,
          a.cover_url,
          a.album_type,
          a.release_date,
          a.created_at,
          ar.full_name as artist_name,
          ar.avatar_url as artist_avatar,
          ar.follower_count,
          ar.is_verified
        FROM 
          artist_albums a
        LEFT JOIN
          artists ar ON ar.id = a.artist_id
        WHERE 
          a.id = $1
        ''',
      parameters: [albumId],
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
      'artist_id': row[1],
      'title': row[2],
      'cover_url': row[3],
      'album_type': row[4],
      'release_date': row[5]?.toString(),
      'created_at': row[6]?.toString(),
      'artist': {
        'id': row[1],
        'full_name': row[7],
        'avatar_url': row[8],
        'follower_count': row[9],
        'is_verified': row[10],
      },
    };

    return Response.json(body: {'done': true, 'album': album});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch album: $e',
      },
    );
  }
}

// Lấy tất cả album của một nghệ sĩ
Future<Response> getAllAlbumsByArtist(
  Connection connect,
  dynamic artistId,
) async {
  if (artistId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing artistId',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT
          a.id,
          a.artist_id,
          a.title,
          a.cover_url,
          a.album_type,
          a.release_date,
          a.created_at,
          COUNT(aas.song_id) as total_songs,
          COALESCE(
            JSON_AGG(
              JSON_BUILD_OBJECT(
                'id', s.id,
                'title', s.title,
                'track_number', aas.track_number,
                'duration_seconds', s.duration_seconds,
                'image_url', s.image_url,
              ) ORDER BY aas.track_number ASC
            ) FILTER (WHERE s.id IS NOT NULL),
            '[]'
          ) AS songs
        FROM
          artist_albums a
        LEFT JOIN
          artist_album_songs aas ON aas.album_id = a.id
        LEFT JOIN
          songs s ON s.id = aas.song_id
        WHERE
          a.artist_id = $1
        GROUP BY
          a.id, a.artist_id, a.title, a.cover_url, a.album_type, a.release_date, a.created_at
        ORDER BY
          a.release_date DESC
        ''',
      parameters: [artistId],
    );

    final albums = result
        .toList()
        .map(
          (row) => {
            'id': row[0],
            'artist_id': row[1],
            'title': row[2],
            'cover_url': row[3],
            'album_type': row[4],
            'release_date': row[5]?.toString(),
            'created_at': row[6]?.toString(),
            'total_songs': row[7] ?? 0,
            'songs': row[8],
          },
        )
        .toList();

    return Response.json(body: {'done': true, 'albums': albums});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch albums: $e',
      },
    );
  }
}

// Lấy danh sách bài hát trong album
Future<Response> getSongsInAlbum(Connection connect, dynamic albumId) async {
  if (albumId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumId',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT
          s.id,
          s.title,
          s.image_url,
          s.audio_url,
          s.duration_seconds,
          s.play_count,
          s.created_at,
          aas.track_number,
          aas.added_at,
          ar.id as artist_id,
          ar.full_name as artist_name,
          ar.avatar_url as artist_avatar,
          ar.is_verified
        FROM
          artist_album_songs aas
        INNER JOIN
          songs s ON s.id = aas.song_id
        INNER JOIN
          artists ar ON ar.id = s.artist_id
        WHERE
          aas.album_id = $1
        ORDER BY
          aas.track_number ASC
        ''',
      parameters: [albumId],
    );

    final songs = result
        .toList()
        .map(
          (row) => {
            'id': row[0],
            'title': row[1],
            'image_url': row[2],
            'audio_url': row[3],
            'duration_seconds': row[4],
            'play_count': row[5],
            'created_at': row[6]?.toString(),
            'track_number': row[7],
            'added_at': row[8]?.toString(),
            'artist': {
              'id': row[9],
              'full_name': row[10],
              'avatar_url': row[11],
              'is_verified': row[12],
            },
          },
        )
        .toList();

    return Response.json(body: {'done': true, 'songs': songs});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to fetch songs: $e',
      },
    );
  }
}

// Xóa album
Future<Response> deleteAlbum(Connection connect, dynamic albumId) async {
  if (albumId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumId',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'DELETE FROM artist_albums WHERE id = $1 RETURNING id',
      parameters: [albumId],
    );

    final deleted = result.isNotEmpty;

    return Response.json(
      body: {
        'done': deleted,
        if (!deleted) 'message': 'Album not found',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to delete album: $e}',
      },
    );
  }
}

// Xóa bài hát khỏi album
Future<Response> removeSongFromAlbum(
  Connection connect,
  dynamic albumId,
  dynamic songId,
) async {
  if (albumId == null || songId == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing albumId or songId',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        DELETE FROM artist_album_songs 
        WHERE 
          album_id = $1 AND song_id = $2 
        RETURNING album_id''',
      parameters: [albumId, songId],
    );

    final removed = result.isNotEmpty;

    return Response.json(
      body: {
        'done': removed,
        if (!removed) 'message': 'Song not found in album',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message': 'Failed to remove song: $e',
      },
    );
  }
}
