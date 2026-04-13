import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json();
  final fullName = body['full_name']?.toString() ?? '';
  final email = body['email']?.toString() ?? '';
  final account = body['account']?.toString() ?? '';
  final password = body['password']?.toString() ?? '';

  // Validate đầu vào
  if (fullName.isEmpty || email.isEmpty || account.isEmpty || password.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Vui lòng điền đầy đủ thông tin!'},
    );
  }

  if (password.length < 6) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Mật khẩu phải có ít nhất 6 ký tự!'},
    );
  }

  // Hash password trước khi lưu vào DB
  final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

  try {
    await conn.execute(
      r'''
        INSERT INTO users(username, password, email, full_name)
        VALUES ($1, $2, $3, $4)
      ''',
      parameters: [account, hashedPassword, email, fullName],
    );

    return Response.json(body: {'done': true});
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'ERROR => $e'},
    );
  }
}
