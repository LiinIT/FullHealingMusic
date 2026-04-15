import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:healing_music_backend/core/service/JwtService.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

final _env = DotEnv()..load();

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.options) {
    return Response(statusCode: 204);
  }

  // Auth guard
  final authHeader = context.request.headers['Authorization'];
  if (authHeader == null || !authHeader.startsWith('Bearer ')) {
    return Response.json(
      statusCode: 401,
      body: {'done': false, 'message': 'Thiếu token xác thực'},
    );
  }
  final payload = JwtService.verifyToken(authHeader.substring(7));
  if (payload == null) {
    return Response.json(
      statusCode: 401,
      body: {'done': false, 'message': 'Token không hợp lệ'},
    );
  }

  final conn = context.read<Connection>();
  final body = await context.request.json();

  switch (body['action']) {
    case 'send':
      return _sendNotification(conn, body);
    case 'getHistory':
      return _getHistory(conn);
    case 'deleteHistory':
      return _deleteHistory(conn, body);
    default:
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Unknown action'},
      );
  }
}

// ─── SEND NOTIFICATION ───────────────────────────────────────────────────────
Future<Response> _sendNotification(Connection conn, dynamic body) async {
  final appId = _env['ONESIGNAL_APP_ID'] ?? '';
  final restKey = _env['ONESIGNAL_REST_API_KEY'] ?? '';

  if (appId.isEmpty ||
      restKey.isEmpty ||
      restKey == 'your_onesignal_rest_api_key_here') {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message':
            'OneSignal chưa được cấu hình. '
            'Vui lòng thêm ONESIGNAL_REST_API_KEY vào .env',
      },
    );
  }

  final title = body['title']?.toString() ?? '';
  final content = body['content']?.toString() ?? '';
  // all | segment | external_ids
  final target = body['target']?.toString() ?? 'all';
  final imageUrl = body['imageUrl']?.toString();
  final launchUrl = body['launchUrl']?.toString();
  final segment = body['segment']?.toString() ?? 'All';
  final List<dynamic> externalIds =
      (body['externalIds'] as List<dynamic>?) ?? [];

  if (title.isEmpty || content.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'Title và content là bắt buộc'},
    );
  }

  // Build OneSignal payload
  final Map<String, dynamic> osPayload = {
    'app_id': appId,
    'headings': {'en': title, 'vi': title},
    'contents': {'en': content, 'vi': content},
  };

  // Target audience
  if (target == 'segment') {
    osPayload['included_segments'] = [segment];
  } else if (target == 'external_ids' && externalIds.isNotEmpty) {
    osPayload['include_aliases'] = {
      'external_id': externalIds.map((e) => e.toString()).toList(),
    };
    osPayload['target_channel'] = 'push';
  } else {
    // default: all
    osPayload['included_segments'] = ['All'];
  }

  if (imageUrl != null && imageUrl.isNotEmpty) {
    osPayload['big_picture'] = imageUrl;
    osPayload['ios_attachments'] = {'id': imageUrl};
  }

  if (launchUrl != null && launchUrl.isNotEmpty) {
    osPayload['url'] = launchUrl;
  }

  // Call OneSignal REST API
  final response = await http.post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    headers: {
      'Authorization': 'Key $restKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(osPayload),
  );

  final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

  if (response.statusCode != 200 || responseBody['errors'] != null) {
    return Response.json(
      statusCode: 500,
      body: {
        'done': false,
        'message':
            'OneSignal error: ${responseBody['errors'] ?? response.body}',
      },
    );
  }

  final notificationId = responseBody['id']?.toString() ?? '';
  final recipients = (responseBody['recipients'] as num?)?.toInt() ?? 0;

  await _saveHistory(
    conn,
    title: title,
    content: content,
    target: target,
    segment: segment,
    imageUrl: imageUrl,
    onesignalId: notificationId,
    recipients: recipients,
  );

  return Response.json(
    body: {
      'done': true,
      'notificationId': notificationId,
      'recipients': recipients,
    },
  );
}

// ─── SAVE HISTORY ────────────────────────────────────────────────────────────
Future<void> _saveHistory(
  Connection conn, {
  required String title,
  required String content,
  required String target,
  required String segment,
  required String onesignalId,
  required int recipients,
  String? imageUrl,
}) async {
  try {
    await conn.execute(
      '''
        CREATE TABLE IF NOT EXISTS notification_history (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          target VARCHAR(50),
          segment VARCHAR(100),
          image_url TEXT,
          onesignal_id TEXT,
          recipients INT DEFAULT 0,
          sent_at TIMESTAMP DEFAULT NOW()
        )
      ''',
    );

    await conn.execute(
      r'''
        INSERT INTO notification_history
          (title, content, target, segment, image_url, onesignal_id, recipients)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
      ''',
      parameters: [
        title,
        content,
        target,
        segment,
        imageUrl,
        onesignalId,
        recipients,
      ],
    );
  } catch (_) {
    // Không fail toàn bộ request nếu lưu lịch sử thất bại
  }
}

// ─── GET HISTORY ─────────────────────────────────────────────────────────────
Future<Response> _getHistory(Connection conn) async {
  try {
    await conn.execute(
      '''
        CREATE TABLE IF NOT EXISTS notification_history (
          id SERIAL PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          target VARCHAR(50),
          segment VARCHAR(100),
          image_url TEXT,
          onesignal_id TEXT,
          recipients INT DEFAULT 0,
          sent_at TIMESTAMP DEFAULT NOW()
        )
      ''',
    );

    final result = await conn.execute(
      '''
        SELECT id, title, content, target, segment,
               image_url, onesignal_id, recipients, sent_at
        FROM notification_history
        ORDER BY sent_at DESC
        LIMIT 100
      ''',
    );

    return Response.json(
      body: {
        'notifications': result
            .map(
              (r) => {
                'id': r[0],
                'title': r[1],
                'content': r[2],
                'target': r[3],
                'segment': r[4],
                'image_url': r[5],
                'onesignal_id': r[6],
                'recipients': r[7],
                'sent_at': r[8].toString(),
              },
            )
            .toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': '$e'},
    );
  }
}

// ─── DELETE HISTORY ──────────────────────────────────────────────────────────
Future<Response> _deleteHistory(Connection conn, dynamic body) async {
  final id = body['id'];
  if (id == null) {
    return Response.json(
      statusCode: 400,
      body: {'done': false, 'message': 'id là bắt buộc'},
    );
  }

  await conn.execute(
    r'DELETE FROM notification_history WHERE id = $1',
    parameters: [id],
  );

  return Response.json(body: {'done': true});
}
