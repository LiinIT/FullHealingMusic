import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final conn = context.read<Connection>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  try {
    // 0. Get data request
    final request = await context.request.json();
    final artistID = request['artistID'];

    // 1. Truy vấn DB
    final result = await conn.execute(
      r'''
        SELECT 
          -- songs fields
          s.id              AS song_id,
          s.title,
          s.play_count,
          s.image_url,
          s.audio_url,
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
        WHERE s.artist_id = $1
      ''',
      parameters: [artistID],
    );

    // 2. Xử lý dữ liệu để loại bỏ các
    //kiểu dữ liệu không encodable (như DateTime)
    final songs = result
        .map(
          (row) => {
            // songs fields
            'song_id': row[0],
            'title': row[1],
            'play_count': row[2],
            'image_url': row[3],
            'audio_url': row[4],
            'duration_seconds': row[5],
            'song_created_at': row[6]?.toString(),

            // artists fields
            'artist_id': row[7],
            'full_name': row[8],
            'avatar_url': row[9],
            'follower_count': row[10],
            'is_verified': row[11],
          },
        )
        .toList();

    // 3. Trả về kết quả thành công
    return Response.json(
      body: {
        'status': 'success',
        'songs': songs,
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
