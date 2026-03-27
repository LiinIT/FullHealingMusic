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
      return addAlbum(connect, body['userID'], body['nameAlbum']);
    case 'getAlbum':
      return getAlbum(connect, body['albumID']);
    default:
      return getAllAlbum(connect, body['userID']);
  }
}

Future<Response> getAllAlbum(Connection connect, dynamic userID) async {
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
        SELECT
          al.id,
          al.user_id,
          al.name,
          al.cover_url,
          created_at
        FROM 
          albums al
        WHERE 
          al.user_id = $1
        ''',
      parameters: [userID],
    );
    return Response.json(body: {'arrAlbum': result});
  } catch (e) {
    return Response.json(
      body: {
        'done': false,
      },
    );
  }
}

Future<Response> getAlbum(Connection connect, dynamic albumID) async {
  if (albumID == null) {
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
        SELECT
          al.id,
          al.user_id,
          al.name,
          al.cover_url,
          created_at
        FROM 
          albums al
        WHERE 
          al.id = $1
        ''',
      parameters: [albumID],
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

Future<Response> addAlbum(
  Connection connect,
  dynamic userID,
  dynamic nameAlbum,
) async {
  if (nameAlbum == null || userID == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'done': false,
        'message': 'Missing nameAlbum or User ID of Theme',
      },
    );
  }

  try {
    await connect.execute(
      r'''
        INSERT INTO 
           albums (user_id, name, created_at)
        VALUES ($1, $2, $3)
        ON CONFLICT DO NOTHING''',
      parameters: [userID, nameAlbum, DateTime.now()],
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
