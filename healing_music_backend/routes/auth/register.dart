import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final fullName = body['full_name'];
  final email = body['email'];
  final account = body['account'];
  final password = body['password'];

  try {
    await conn.execute(
      r'''
        INSERT INTO 
          users(username, password, email, full_name) 
          VALUES ($1, $2, $3, $4)
      ''',
      parameters: [account, password, email, fullName],
    );

    return Response.json(
      body: {
        'done': true,
      },
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
