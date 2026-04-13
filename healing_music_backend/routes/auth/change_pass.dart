import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:healing_music_backend/core/service/JwtService.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  // Xác thực JWT token từ header
  final authHeader = context.request.headers['Authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Thiếu token xác thực!'},
    );
  }

  final token = authHeader.substring(7);
  final payload = JwtService.verifyToken(token);
  if (payload == null) {
    return Response.json(
      statusCode: 401,
      body: {'message': 'Token không hợp lệ hoặc đã hết hạn!'},
    );
  }

  final body = await context.request.json();
  final userName = body['username']?.toString() ?? '';
  final newPassword = body['password']?.toString() ?? '';

  if (userName.isEmpty || newPassword.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Thiếu username hoặc password mới!'},
    );
  }

  // Đảm bảo chỉ đổi được password của chính mình (username trong token khớp)
  if (payload['username'] != userName) {
    return Response.json(
      statusCode: 403,
      body: {'message': 'Không có quyền đổi mật khẩu tài khoản này!'},
    );
  }

  // Hash mật khẩu mới trước khi lưu
  final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

  final result = await conn.execute(
    r'''
      UPDATE users
      SET password = $2
      WHERE username = $1
      RETURNING id;
    ''',
    parameters: [userName, hashedPassword],
  );

  if (result.isEmpty) {
    return Response(statusCode: 404, body: 'User not found');
  }

  return Response(body: 'Password updated successfully');
}
