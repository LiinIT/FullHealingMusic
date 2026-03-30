import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();
  // Chỉ chấp nhận phương thức POST
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  // 1. Đọc dữ liệu từ Flutter gửi lên
  final body = await context.request.json();
  final userName = body['username'];
  final password = body['password'];

  // 3. Truy vấn DB
  final result = await conn.execute(
    r'''
      UPDATE users
      SET password = $2
      WHERE username = $1
      RETURNING id;
    ''',
    parameters: [userName, password],
  );

  // 4. Kiểm tra kết quả
  if (result.isEmpty) {
    return Response(statusCode: 404, body: 'User not found');
  }
  return Response(body: 'Password updated successfully');
}
