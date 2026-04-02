import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

Connection? _dbConnection;
final _env = DotEnv()..load();
String _getEnv(String key) {
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
Handler middleware(Handler handler) {
  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: _corsHeaders);
    }
    _dbConnection ??= await Connection.open(
      Endpoint(
        host: _getEnv('DB_HOST'),
        database: _getEnv('DB_NAME'),
        username: _getEnv('DB_USER'),
        password: _getEnv('DB_PASSWORD'),
        port: int.parse(_getEnv('DB_PORT')),
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );
    final response = await handler
        .use(provider<Connection>((_) => _dbConnection!))
        .call(context);
    return response.copyWith(
      headers: {...response.headers, ..._corsHeaders},
    );
  };
}
