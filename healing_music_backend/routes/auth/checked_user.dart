import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final userName = body['username']?.toString() ?? '';
  final password = body['password']?.toString() ?? '';

  if (userName.isEmpty || password.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'isMatch': false, 'message': 'Thiếu username hoặc password'},
    );
  }

  // Lấy password đã lưu (bcrypt hoặc plain-text cũ)
  final result = await conn.execute(
    r'SELECT password FROM users WHERE username = $1',
    parameters: [userName],
  );

  if (result.isEmpty) {
    return Response.json(statusCode: 400, body: {'isMatch': false});
  }

  final storedPassword = result.first[0].toString();

  // Hỗ trợ cả bcrypt lẫn plain-text cũ (migration)
  bool isMatch;
  final isBcrypt = storedPassword.startsWith(r'$2b$') ||
      storedPassword.startsWith(r'$2a$');
  if (isBcrypt) {
    isMatch = BCrypt.checkpw(password, storedPassword);
  } else {
    isMatch = storedPassword == password;
  }

  // 200 = khớp, 400 = không khớp
  return Response.json(
    statusCode: isMatch ? 200 : 400,
    body: {'isMatch': isMatch},
  );
}
