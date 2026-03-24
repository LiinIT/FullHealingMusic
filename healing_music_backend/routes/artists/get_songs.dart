import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final artistID = body['artistID'];

  try {
    final result = await conn.execute(
      '''
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

        FROM songs s
        LEFT JOIN artists a 
          ON a.id = s.artist_id
      ''',
      parameters: [artistID],
    );

    return Response.json(
      body: {'done': true, 'result': result},
    );
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
        'message': 'ERROR => $e',
      },
    );
  }
}
