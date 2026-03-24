import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  try {
    // 1. Truy vấn DB
    final result = await conn.execute('''
        SELECT 
          -- songs fields
          s.id              AS song_id,
          s.title,
          s.image_url,
          s.audio_url,
          s.rank,
          s.duration_seconds,
          s.created_at      AS song_created_at,

          -- artists fields
          a.id              AS artist_id,
          a.full_name,
          a.avatar_url,
          a.follower_count,
          a.is_verified

        FROM songs s
        LEFT JOIN artists a 
          ON a.id = s.artist_id
        ORDER BY RANDOM() 
        LIMIT 50
        ''');

    // 2. Xử lý dữ liệu để loại bỏ các
    //kiểu dữ liệu không encodable (như DateTime)
    final songsList = result.map((row) {
      final columnMap = row.toColumnMap();

      // Chuyển đổi mọi giá trị DateTime thành String (ISO8601)
      return columnMap.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        }
        return MapEntry(key, value);
      });
    }).toList();

    // 3. Trả về kết quả thành công
    return Response.json(
      body: {
        'status': 'success',
        'songs': songsList,
      },
    );
  } catch (e) {
    // Xử lý lỗi nếu truy vấn thất bại
    return Response.json(
      body: {'status': 'error', 'message': e.toString()},
      statusCode: 500,
    );
  }
}
