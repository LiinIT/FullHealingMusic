import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

Connection? _dbConnection;
final _env = DotEnv()..load();

String _getEnv(String key) {
  // Ưu tiên Railway environment variables
  final fromSystem = Platform.environment[key];
  if (fromSystem != null && fromSystem.isNotEmpty) return fromSystem;
  // Fallback sang .env file (local dev)
  final value = _env[key];
  if (value == null || value.isEmpty) {
    throw Exception('Missing env: $key');
  }
  return value;
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

Endpoint get _endpoint => Endpoint(
      host: _getEnv('DB_HOST'),
      database: _getEnv('DB_NAME'),
      username: _getEnv('DB_USER'),
      password: _getEnv('DB_PASSWORD'),
      port: int.parse(_getEnv('DB_PORT')),
    );

/// Trả về connection hiện có hoặc mở lại nếu đã bị đóng/lỗi
Future<Connection> _getConnection() async {
  if (_dbConnection == null || _dbConnection!.isOpen == false) {
    _dbConnection = await Connection.open(
      _endpoint,
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
  }
  return _dbConnection!;
}

Handler middleware(Handler handler) {
  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: _corsHeaders);
    }

    try {
      final conn = await _getConnection();

      final response = await handler
          .use(provider<Connection>((_) => conn))
          .call(context);

      return response.copyWith(
        headers: {...response.headers, ..._corsHeaders},
      );
    } catch (e) {
      return Response.json(
        statusCode: 500,
        body: {'error': e.toString()},
        headers: _corsHeaders,
      );
    }
  };
}
