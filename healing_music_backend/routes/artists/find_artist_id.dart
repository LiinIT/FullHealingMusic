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
      r'''
        SELECT * 
        FROM artists 
        WHERE artists.id = $1 ''',
      parameters: [artistID],
    );

    final artist = result
        .map(
          (row) => {
            'id': row[0],
            'full_name': row[1],
            'avatar_url': row[2],
            'follower_count': row[3],
            'is_verified': row[4],
            'created_at': row[5]?.toString(),
          },
        )
        .toList();

    if (artist.isEmpty) {
      return Response.json(
        statusCode: 404,
        body: {'done': false, 'message': 'Artist not found'},
      );
    }

    return Response.json(
      body: {
        'done': true,
        'artist': artist.first,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'ERROR => $e'},
    );
  }
}
