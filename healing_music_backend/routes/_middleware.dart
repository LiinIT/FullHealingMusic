import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';

// Biến global để giữ kết nối không bị đóng
Connection? _dbConnection;
final _env = DotEnv()..load();

String _getEnv(String key) {
  final value = _env[key];
  if (value == null || value.isEmpty) {
    throw Exception('Missing env: $key');
  }
  return value;
}

Handler middleware(Handler handler) {
  return (context) async {
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

    return handler
        .use(provider<Connection>((_) => _dbConnection!))
        .call(context);
  };
}
