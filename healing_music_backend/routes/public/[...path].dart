import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context, String path) async {
  final candidates = [
    'public/$path',
    'build/public/$path',
    '${File(Platform.script.toFilePath()).parent.parent.path}/public/$path',
  ];

  File? found;
  for (final candidate in candidates) {
    final f = File(candidate);
    if (f.existsSync()) {
      found = f;
      break;
    }
  }

  if (found == null) {
    return Response(statusCode: 404, body: 'File not found: $path');
  }

  final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
  final bytes = found.readAsBytesSync();
  final fileSize = bytes.length;

  // Check if client requests a byte range (for seeking)
  final rangeHeader = context.request.headers['range'];
  if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
    final rangeParts = rangeHeader.substring(6).split('-');
    final start = int.tryParse(rangeParts[0]) ?? 0;
    final end = rangeParts.length > 1 && rangeParts[1].isNotEmpty
        ? int.tryParse(rangeParts[1]) ?? (fileSize - 1)
        : fileSize - 1;
    final chunk = bytes.sublist(start, end + 1);

    return Response.bytes(
      statusCode: 206,
      body: chunk,
      headers: {
        'Content-Type': mimeType,
        'Content-Length': chunk.length.toString(),
        'Content-Range': 'bytes $start-$end/$fileSize',
        'Accept-Ranges': 'bytes',
        'Cache-Control': 'public, max-age=86400',
      },
    );
  }

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Type': mimeType,
      'Content-Length': fileSize.toString(),
      'Accept-Ranges': 'bytes',
      'Cache-Control': 'public, max-age=86400',
    },
  );
}