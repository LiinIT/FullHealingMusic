import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    // 0. Get data request
    final request = await context.request.json();
    final userID = request['userID'];

    // 1. Truy vấn DB
    final result = await conn.execute(
      r'''
        SELECT 
          u.id,
          u.username,
          u.email,
          u.full_name,
          u.avatar_url,
          u.role,
          u.is_active
        FROM users u
        WHERE u.id = $1
      ''',
      parameters: [userID],
    );

    // 2. Xử lý dữ liệu để loại bỏ các
    //kiểu dữ liệu không encodable (như DateTime)
    final user = result
        .map(
          (row) => {
            'id': row[0],
            'username': row[1],
            'password': '',
            'email': row[2],
            'full_name': row[3],
            'avatar_url': row[4],
            'role': row[5],
            'is_active': row[6],
          },
        )
        .toList();

    // 3. Trả về kết quả thành công
    return Response.json(
      body: {
        'status': 'success',
        'user': user,
      },
    );
  } catch (e) {
    // Xử lý lỗi nếu truy vấn thất bại
    return Response.json(
      body: {'status': 'error', 'message': e.toString()},
      statusCode: 500,
    );
  }
}
