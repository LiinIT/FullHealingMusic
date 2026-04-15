# HEALING MUSIC — HƯỚNG DẪN BUILD HỆ THỐNG TRÊN MÁY MỚI

> Làm theo đúng thứ tự, không bỏ bước nào.

---

## TỔNG QUAN HỆ THỐNG

| Thành phần            | Công nghệ           | Port  |
|-----------------------|---------------------|-------|
| Backend API           | Dart Frog (Dart)    | 8080  |
| Database              | PostgreSQL           | 5432  |
| Admin Web             | HTML/CSS/JS (static) | —    |
| Flutter App           | Flutter (Dart)      | —     |

---

## BƯỚC 1 — CÀI ĐẶT CÔNG CỤ

### 1.1 Dart SDK
```bash
# macOS (Homebrew)
brew tap dart-lang/dart
brew install dart

# Kiểm tra
dart --version   # >= 3.0.0
```

### 1.2 Dart Frog CLI
```bash
dart pub global activate dart_frog_cli

# Kiểm tra
dart_frog --version
```

### 1.3 PostgreSQL
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15

# Kiểm tra
psql --version
```

### 1.4 Flutter SDK (cho app)
```bash
# Tải tại https://docs.flutter.dev/get-started/install
flutter --version   # >= 3.x.x
flutter doctor      # đảm bảo không lỗi
```

---

## BƯỚC 2 — CLONE DỰ ÁN

```bash
git clone <repo_url> Healing_music
cd Healing_music
```

Cấu trúc thư mục:
```
Healing_music/
├── healing_music_backend/   # Dart Frog API
├── healing_music_app/       # Flutter mobile app
└── healing_music_web/       # Admin dashboard (static HTML)
```

---

## BƯỚC 3 — SETUP DATABASE

### 3.1 Tạo user và database PostgreSQL
```bash
psql postgres
```
```sql
CREATE USER asliin WITH PASSWORD 'Liin123';
CREATE DATABASE healing_music_db OWNER asliin;
GRANT ALL PRIVILEGES ON DATABASE healing_music_db TO asliin;
\q
```

### 3.2 Chạy schema + import data
```bash
psql -U asliin -d healing_music_db -f healing_music_backend/query.sql
```

> ⚠️ File query.sql dùng đường dẫn tuyệt đối để COPY CSV.
> Trước khi chạy, cập nhật đường dẫn CSV trong query.sql cho phù hợp máy mới:

```sql
-- Tìm và thay thế đoạn này trong query.sql:
COPY users(...) FROM '/Users/asliin/Documents/...'
-- Thành đường dẫn đúng trên máy mới, ví dụ:
COPY users(...) FROM '/home/username/Healing_music/healing_music_web/public/users_db.csv' CSV HEADER;
```

### 3.3 Kiểm tra data đã import
```bash
psql -U asliin -d healing_music_db -c "SELECT COUNT(*) FROM songs;"
psql -U asliin -d healing_music_db -c "SELECT COUNT(*) FROM artists;"
```

---

## BƯỚC 4 — SETUP BACKEND (Dart Frog)

### 4.1 Cấu hình file .env
```bash
cd healing_music_backend
```

Tạo file `.env`:
```env
DB_HOST=127.0.0.1
DB_PORT=5432
DB_NAME=healing_music_db
DB_USER=asliin
DB_PASSWORD=Liin123
JWT_KEY=8xR!mQpL2zNvK9jH5yB6nM3cXvF7dS0wE4tY1uI8oP2aZ9cL5kW7jR4eT6yU
PORT=8080
ENVIRONMENT=development
```

> ⚠️ Đổi `DB_USER`, `DB_PASSWORD` nếu tạo khác ở Bước 3.1
> ⚠️ `JWT_KEY` giữ nguyên để token cũ vẫn hợp lệ (hoặc đổi nếu muốn reset session)

### 4.2 Cài dependencies
```bash
dart pub get
```

### 4.3 Chạy server (dev)
```bash
dart_frog dev
```

### 4.4 Kiểm tra server
```bash
curl http://localhost:8080
# Kỳ vọng: response JSON hoặc 200 OK
```

### 4.5 Build production (tùy chọn)
```bash
dart_frog build
cd build && dart bin/server.dart
```

---

## BƯỚC 5 — SETUP FLUTTER APP

### 5.1 Cấu hình file .env
```bash
cd healing_music_app
```

Tạo file `.env`:
```env
API_URL=http://<IP_MÁY_CHẠY_BACKEND>:8080
```

> Nếu test trên emulator Android: `API_URL=http://10.0.2.2:8080`
> Nếu test trên thiết bị thật cùng WiFi: `API_URL=http://192.168.x.x:8080` (IP của máy backend)
> Nếu test trên iOS Simulator: `API_URL=http://localhost:8080`

### 5.2 Cài dependencies
```bash
flutter pub get
```

### 5.3 Chạy app
```bash
flutter run
```

---

## BƯỚC 6 — SETUP ADMIN WEB

Admin Web là static HTML, không cần build. Chỉ cần:

### 6.1 Cập nhật API URL
Mở file `healing_music_web/js/config.js`:
```js
const CONFIG = {
    API_BASE_URL: 'http://localhost:8080',  // ← đổi IP nếu cần
};
```

### 6.2 Mở trong browser
```bash
# Dùng Live Server (VS Code extension) hoặc bất kỳ HTTP server nào
cd healing_music_web
npx serve .         # hoặc python3 -m http.server 3000
```

Mở trình duyệt: `http://localhost:3000`

---

## CHECKLIST KIỂM TRA SAU KHI BUILD

- [ ] PostgreSQL đang chạy: `brew services list | grep postgresql`
- [ ] Database có data: `psql -U asliin -d healing_music_db -c "SELECT COUNT(*) FROM songs;"`
- [ ] Backend đang chạy: `curl http://localhost:8080`
- [ ] File `.env` backend đã tạo đúng
- [ ] File `.env` app đã trỏ đúng IP backend
- [ ] Admin web mở được và load danh sách bài hát

---

## GHI CHÚ QUAN TRỌNG

| Vấn đề | Giải pháp |
|--------|-----------|
| COPY CSV lỗi đường dẫn | Sửa đường dẫn tuyệt đối trong `query.sql` trước khi chạy |
| App không kết nối được backend | Kiểm tra IP trong `.env` app, firewall, và backend đang chạy |
| PostgreSQL lỗi permission | Chạy lại `GRANT ALL PRIVILEGES` trong psql |
| `dart_frog` không tìm thấy | Thêm `~/.pub-cache/bin` vào `PATH` trong `.zshrc` hoặc `.bashrc` |
| Flutter không thấy `.env` | Đảm bảo `.env` nằm ở root của `healing_music_app/` |
