import 'dart:math';

import 'package:dart_frog/dart_frog.dart';
import 'package:healing_music_backend/core/service/JwtService.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();
  // Chỉ chấp nhận phương thức POST
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  // 1. Đọc dữ liệu từ Flutter gửi lên
  final body = await context.request.json();
  final username = body['username'];
  final password = body['password'];

  // 3. Truy vấn DB
  final result = await conn.execute(
    r'''
      SELECT 
        users.id,
        users.username, 
        users.password 
      FROM users
      WHERE username = $1 AND password = $2
    ''',
    parameters: [username, password],
  );

  // 4. Kiểm tra kết quả
  if (result.isEmpty) {
    return Response.json(
      body: {'message': 'Sai tên đăng nhập hoặc mật khẩu!'},
      statusCode: 401,
    );
  }

  final jsonUserResult = result.first.toColumnMap();

  // return token session
  final token = JwtService.generateToken(
    userId: jsonUserResult['id'].toString(),
    username:
        jsonUserResult['username'].toString() + Random.secure().toString(),
  );

  return Response.json(
    body: {
      'message': 'Đăng nhập thành công!',
      'userID': jsonUserResult['id'],
      'username': jsonUserResult['username'],
      'token': token,
    },
  );
}
