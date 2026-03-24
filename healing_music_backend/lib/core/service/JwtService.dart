import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

final _env = DotEnv()..load();

String _getEnv(String key) {
  final value = _env[key];
  if (value == null || value.isEmpty) {
    throw Exception('Missing env: $key');
  }
  return value;
}

class JwtService {
  static final _secret = _getEnv('JWT_KEY');
  static const _expiry = Duration(days: 7);

  // Tạo token
  static String generateToken({
    required String userId,
    required String username,
  }) {
    final jwt = JWT(
      {
        'userId': userId,
        'username': username,
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return jwt.sign(
      SecretKey(_secret),
      expiresIn: _expiry,
    );
  }

  // Verify token
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      return null; // token hết hạn
    } on JWTException {
      return null; // token không hợp lệ
    }
  }
}
