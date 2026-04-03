import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    final contentType = context.request.headers['content-type'] ?? '';
    if (!contentType.contains('multipart/form-data')) {
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Cần multipart/form-data'},
      );
    }

    // Lấy boundary
    final boundary = contentType.split('boundary=').last.trim();
    final List<int> bodyBytes = await context.request
        .bytes()
        .fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));

    // Parse multipart thủ công
    final parsed = _parseMultipart(bodyBytes, boundary);
    if (parsed == null) {
      return Response.json(
        statusCode: 400,
        body: {'done': false, 'message': 'Không tìm thấy file'},
      );
    }

    final filename = parsed['filename'] as String;
    final fileBytes = parsed['bytes'] as List<int>;

    // Xác định subfolder
    final isAudio = filename.endsWith('.mp3') ||
        filename.endsWith('.wav') ||
        filename.endsWith('.flac') ||
        filename.endsWith('.m4a');

    final subfolder = isAudio ? 'audios' : 'images';

    // Lưu file vào healing_music_web/public/
    final savePath = '../healing_music_web/public/$subfolder/$filename';
    final file = File(savePath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(fileBytes);

    final url = 'http://192.168.1.24:3000/public/$subfolder/$filename';

    return Response.json(
      body: {
        'done': true,
        'url': url,
        'filename': filename,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'done': false, 'message': 'Upload thất bại: $e'},
    );
  }
}

// Parse multipart/form-data thủ công không cần package
Map<String, dynamic>? _parseMultipart(List<int> bodyBytes, String boundary) {
  try {
    final boundaryBytes = '--$boundary'.codeUnits;
    final body = String.fromCharCodes(bodyBytes);

    // Tìm filename
    final filenameMatch = RegExp('filename="([^"]+)"').firstMatch(body);
    if (filenameMatch == null) return null;
    final filename = filenameMatch.group(1)!;

    // Tìm vị trí bắt đầu content (sau 2 CRLF)
    final headerEnd = body.indexOf('\r\n\r\n');
    if (headerEnd == -1) return null;

    final contentStart = headerEnd + 4;

    // Tìm vị trí kết thúc (boundary kết thúc)
    final endBoundary = '\r\n--$boundary--';
    final contentEnd = body.lastIndexOf(endBoundary);
    if (contentEnd == -1) return null;

    // Cắt bytes đúng vị trí
    final fileBytes = bodyBytes.sublist(contentStart, contentEnd);

    return {
      'filename': filename,
      'bytes': fileBytes,
    };
  } catch (e) {
    return null;
  }
}
