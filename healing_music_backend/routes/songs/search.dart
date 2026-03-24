import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final keyword = body['keyword'] as String?;

  if (keyword == null || keyword.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Missing keyword'},
    );
  }

  try {
    final result = await conn.execute(
      r'''
        SELECT
          s.id              AS song_id,
          s.title,
          s.image_url,
          s.audio_url,
          s.rank,
          s.duration_seconds,
          a.id              AS artist_id,
          a.full_name ,
          a.avatar_url,
          a.follower_count,
          a.is_verified
        FROM songs s
        LEFT JOIN artists a ON a.id = s.artist_id
        WHERE
          s.title ILIKE $1
          OR a.full_name ILIKE $1
        LIMIT 20
      ''',
      parameters: ['%$keyword%'],
    );

    final songs = result
        .map(
          (row) => {
            'song_id': row[0],
            'title': row[1],
            'image_url': row[2],
            'audio_url': row[3],
            'rank': row[4],
            'duration_seconds': row[5],
            'artist_id': row[6],
            'full_name': row[7],
            'avatar_url': row[8],
            'follower_count': row[9],
            'is_verified': row[10],
          },
        )
        .toList();

    return Response.json(
      body: {'done': true, 'songs': songs},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': e.toString()},
    );
  }
}
