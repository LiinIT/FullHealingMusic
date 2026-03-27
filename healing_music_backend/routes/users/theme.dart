import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connect = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json();

  switch (body['action']) {
    case 'setTheme':
      return setTheme(connect, body['isLightMode'], body['userID']);
    case 'getTheme':
    default:
      return getTheme(connect, body['userID']);
  }
}

Future<Response> getTheme(Connection connect, dynamic userID) async {
  if (userID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing isLightMode or User ID of Theme',
      },
    );
  }

  try {
    final result = await connect.execute(
      r'''
        SELECT  light_mode
        FROM 
           theme_user
        WHERE user_id = $1
        ''',
      parameters: [userID],
    );
    return Response.json(body: {'isLightMode': result[0][0]});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}

Future<Response> setTheme(
  Connection connect,
  dynamic isLightMode,
  dynamic userID,
) async {
  if (isLightMode == null || userID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing isLightMode or User ID of Theme',
      },
    );
  }

  try {
    await connect.execute(
      r'''
        INSERT INTO 
           theme_user (user_id, light_mode)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING''',
      parameters: [userID, isLightMode],
    );
    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}
