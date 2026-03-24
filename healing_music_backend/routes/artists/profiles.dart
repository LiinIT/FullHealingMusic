import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  // if (context.request.method != HttpMethod.post) {
  //   return Response(statusCode: 405);
  // }

  try {
    final result = await conn.execute(
      '''
        SELECT 
            artists.id, 
            artists.full_name, 
            artists.avatar_url 
        FROM artists
      ''',
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
