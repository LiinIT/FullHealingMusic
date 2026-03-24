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
        SELECT artists.full_name 
        FROM artists 
        WHERE artists.id = $1 ''',
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
