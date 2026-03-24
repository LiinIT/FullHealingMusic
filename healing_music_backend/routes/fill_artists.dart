import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();
  final apis = <String>[
    // V-Pop (Việt Nam)
    'Son Tung M-TP', 'Hoang Thuy Linh', 'Den Vau', 'HIEUTHUHAI', 'tlow',
    'Suni Ha Linh', 'Mono', 'TLinh', 'Grey D', 'Phuong Ly',
    'Duc Phuc', 'Erik', 'Min', 'Noo Phuoc Thinh', 'Suboi',

    // US-UK (Quốc tế)
    'Taylor Swift', 'Ed Sheeran', 'Adele',
    'Billie Eilish', 'Dua Lipa', 'Charlie Puth', 'Maroon 5',
  ];

  int count = 0;
  // Gọi sang Deezer
  for (final nameArtist in apis) {
    final deezerUrl = Uri.parse('https://api.deezer.com/search?q=$nameArtist');

    final response = await http.get(deezerUrl);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final id = data['data'][0]['artist']['id'].toString();
      final fullName = data['data'][0]['artist']['name'].toString();
      final avatarUrl = data['data'][0]['artist']['picture_xl'].toString();

      await conn.execute(
        'INSERT INTO artists (id, full_name, avatar_url) '
        r'VALUES ($1, $2, $3) '
        'ON CONFLICT (id) DO UPDATE '
        'SET full_name = EXCLUDED.full_name, '
        'avatar_url = EXCLUDED.avatar_url;',
        parameters: [id, fullName, avatarUrl],
      );
      count++;
      print('✅ ✅ ✅ Fill artist [action]: $fullName ');
    } else {
      final data = jsonDecode(response.body);
      final fullName = data['data'][0]['artist']['name'].toString();
      print('❌ ❌ ❌ Fill artist [break]: $fullName ');
    }
  }

  print('🏆 🏆 🏆 Fill artist: END. We having $count artists 🧑‍🎨. 🏆 🏆 🏆 ');

  return Response.json(
    body: {
      'status': 'success',
      'message': '😎 Fill artist: END. We having $count artists 🧑‍🎨!',
    },
  );
}
