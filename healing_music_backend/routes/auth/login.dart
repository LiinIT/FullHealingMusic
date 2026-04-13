import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:healing_music_backend/core/service/JwtService.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final username = body['username'];
  final password = body['password'];

  if (username == null || password == null ||
      username.toString().isEmpty || password.toString().isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Vui lòng nhập tên đăng nhập và mật khẩu!'},
    );
  }

  // Lấy user theo username (không so sánh password trong SQL nữa)
  final result = await conn.execute(
    r'''
      SELECT id, username, password
      FROM users
      WHERE username = $1
    ''',
    parameters: [username],
  );

  if (result.isEmpty) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Sai tên đăng nhập hoặc mật khẩu!'},
    );
  }

  final row = result.first.toColumnMap();
  final storedPassword = row['password'].toString();
  final inputPassword = password.toString();

  // Kiểm tra password: hỗ trợ cả bcrypt lẫn plain-text cũ (migration tự động)
  bool isMatch;
  if (storedPassword.startsWith('\$2b\$') || storedPassword.startsWith('\$2a\$')) {
    // Mật khẩu đã được hash bcrypt
    isMatch = BCrypt.checkpw(inputPassword, storedPassword);
  } else {
    // Mật khẩu cũ dạng plain-text → so sánh trực tiếp
    isMatch = storedPassword == inputPassword;

    // Tự động migrate sang bcrypt sau khi đăng nhập thành công
    if (isMatch) {
      final hashed = BCrypt.hashpw(inputPassword, BCrypt.gensalt());
      await conn.execute(
        r'UPDATE users SET password = $1 WHERE id = $2',
        parameters: [hashed, row['id']],
      );
    }
  }

  if (!isMatch) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Sai tên đăng nhập hoặc mật khẩu!'},
    );
  }

  final token = JwtService.generateToken(
    userId: row['id'].toString(),
    username: row['username'].toString(),
  );

  return Response.json(
    body: {
      'message': 'Đăng nhập thành công!',
      'userID': row['id'],
      'username': row['username'],
      'token': token,
    },
  );
}
