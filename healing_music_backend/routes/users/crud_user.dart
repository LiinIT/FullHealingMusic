import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();

  switch (body['action']) {
    case 'addUser':
      return _addUser(conn, body);
    case 'updateUser':
      return _updateUser(conn, body);
    case 'deleteUser':
      return _deleteUser(conn, body);
    case 'getAll':
      return _getAll(conn);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

// ─── ADD USER ────────────────────────────────────
Future<Response> _addUser(Connection conn, dynamic body) async {
  final username = body['username'];
  final password = body['password'];
  final email = body['email'];
  final fullName = body['fullName'];
  final tag = body['userTag'];
  final avatar = body['avatarUrl'];
  final role = body['role'];

  if (username.toString().isEmpty ||
      password.toString().isEmpty ||
      email.toString().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'username, password, email là bắt buộc'},
    );
  }

  try {
    final result = await conn.execute(
      r'''
        INSERT INTO users (
          taguser, 
          username, 
          password, 
          email, 
          full_name, 
          avatar_url, 
          role
        )
        VALUES ($1, $2, $3, $4, $5, $6, COALESCE($7, 'USER'))
        RETURNING id
      ''',
      parameters: [
        tag,
        username,
        password,
        email,
        fullName,
        avatar,
        role,
      ],
    );

    return Response.json(
      body: {
        'done': true,
        'id': result.first[0],
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ─── UPDATE USER ─────────────────────────────────
Future<Response> _updateUser(Connection conn, dynamic body) async {
  final id = body['userId'];

  if (id.toString().isEmpty) {
    return Response.json(
      body: {'done': false, 'message': 'userId bắt buộc'},
    );
  }

  final result = await conn.execute(
    r'''
      UPDATE users SET
      username   = COALESCE(NULLIF($1, ''), username),
      password   = COALESCE(NULLIF($2, ''), password),
      email      = COALESCE(NULLIF($3, ''), email),
      full_name  = COALESCE(NULLIF($4, ''), full_name),
      avatar_url = COALESCE(NULLIF($5, ''), avatar_url),
      role       = COALESCE(NULLIF($6, ''), role),
      taguser    = COALESCE(NULLIF($7, ''), taguser)
      WHERE id = $8
      RETURNING id
    ''',
    parameters: [
      body['username'],
      body['password'],
      body['email'],
      body['fullName'],
      body['avatarUrl'],
      body['role'],
      body['taguser'],
      id,
    ],
  );

  if (result.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'done': false, 'message': 'User không tồn tại'},
    );
  }

  return Response.json(body: {'done': true});
}

// ─── DELETE USER ─────────────────────────────────
Future<Response> _deleteUser(Connection conn, dynamic body) async {
  final id = body['userId'];

  if (id.toString().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'userId bắt buộc'},
    );
  }

  final result = await conn.execute(
    r'DELETE FROM users WHERE id = $1 RETURNING id',
    parameters: [id],
  );

  if (result.isEmpty) {
    return Response.json(
      body: {'done': false, 'message': 'User không tồn tại'},
    );
  }

  return Response.json(body: {'done': true});
}

// ─── GET ALL USERS ───────────────────────────────
Future<Response> _getAll(Connection conn) async {
  final result = await conn.execute(
    '''
      SELECT 
        id,
        username,
        email,
        full_name,
        avatar_url,
        role,
        is_active,
        created_at,
        taguser
      FROM users
      ORDER BY created_at DESC
    ''',
  );

  return Response.json(body: {
    'users': result
        .map(
          (r) => {
            'id': r[0],
            'username': r[1],
            'email': r[2],
            'full_name': r[3],
            'avatar_url': r[4],
            'role': r[5],
            'is_active': r[6],
            'created_at': r[7].toString(),
            'taguser': r[8],
          },
        )
        .toList(),
  });
}
