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
  final account = body['account'];

  // 3. Truy vấn DB
  final result = await conn.execute(
    r'''
      SELECT users.username 
      FROM users 
      WHERE username = $1
    ''',
    parameters: [account],
  );

  // 4. Kiểm tra kết quả — trả 200 cho cả 2 trường hợp, dùng body để phân biệt
  return Response.json(
    body: {'isNotEmpty': result.isNotEmpty},
  );
}
