import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mime/mime.dart';

Future<Response> onRequest(RequestContext context, String path) async {
  final filePath = 'public/$path';
  final file = File(filePath);

  if (!file.existsSync()) {
    return Response(statusCode: 404, body: 'File not found: $path');
  }

  final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';
  final bytes = file.readAsBytesSync();

  return Response.bytes(
    body: bytes,
    headers: {
      'Content-Type': mimeType,
      'Cache-Control': 'public, max-age=86400',
    },
  );
}
