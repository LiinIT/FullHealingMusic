import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context, String path) async {
  // Try relative to CWD, then relative to script location
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

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Type': mimeType,
      'Cache-Control': 'public, max-age=86400',
    },
  );
}