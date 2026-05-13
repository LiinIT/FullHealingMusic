import 'package:dart_frog/dart_frog.dart';
import 'package:healing_music_backend/core/service/JwtService.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.delete) {
    return Response(statusCode: 405);
  }

  // Xác thực JWT token
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

  final userId = int.tryParse(payload['userId']?.toString() ?? '');
  if (userId == null) {
    return Response.json(
      statusCode: 400,
      body: {'message': 'Token không chứa thông tin user hợp lệ!'},
    );
  }

  // Xóa toàn bộ dữ liệu liên quan theo thứ tự tránh vi phạm foreign key
  await conn.execute(
    r'DELETE FROM history WHERE user_id = $1',
    parameters: [userId],
  );
  await conn.execute(
    r'DELETE FROM favorites WHERE user_id = $1',
    parameters: [userId],
  );
  await conn.execute(
    r'DELETE FROM playlist_songs WHERE playlist_id IN (SELECT id FROM playlists WHERE user_id = $1)',
    parameters: [userId],
  );
  await conn.execute(
    r'DELETE FROM playlists WHERE user_id = $1',
    parameters: [userId],
  );
  await conn.execute(
    r'DELETE FROM theme_user WHERE user_id = $1',
    parameters: [userId],
  );

  // Xóa tài khoản
  final result = await conn.execute(
    r'DELETE FROM users WHERE id = $1 RETURNING id',
    parameters: [userId],
  );

  if (result.isEmpty) {
    return Response.json(
      statusCode: 404,
      body: {'message': 'Không tìm thấy tài khoản!'},
    );
  }

  return Response.json(
    body: {'message': 'Tài khoản đã được xóa thành công!'},
  );
}
