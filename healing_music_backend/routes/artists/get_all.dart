import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();

  try {
    final result = await conn.execute(
      '''
        SELECT 
          a.id,
          a.full_name,
          a.avatar_url,
          a.follower_count,
          a.is_verified,
          a.created_at
        FROM artists a
        ORDER BY a.full_name ASC 
      ''',
    );

    if (result.isEmpty) {
      return Response.json(
        body: {'done': true, 'isEmpty': true, 'artists': <dynamic>[]},
      );
    }

    final artists = result
        .map(
          (row) => {
            // artists fields
            'id': row[0],
            'full_name': row[1],
            'avatar_url': row[2],
            'follower_count': row[3],
            'is_verified': row[4],
            'created_at': row[5]?.toString(),
          },
        )
        .toList();

    return Response.json(
      body: {'done': true, 'artists': artists},
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
