# Alumnet MultiPlatform

Alumnet MultiPlatform adalah aplikasi jejaring alumni yang mendukung berbagai platform (Web, Android, iOS, Windows, MacOS, Linux) menggunakan Flutter untuk frontend dan Node.js untuk backend.

## Fitur Utama
- Autentikasi pengguna
- Chat grup alumni
- Penyimpanan pesan lokal dan remote
- UI responsif dan modern

## Struktur Proyek
- `frontend/` : Aplikasi Flutter (multi-platform)
- `backend/` : Backend Node.js (Express)

## Cara Menjalankan

### Backend
1. Masuk ke folder backend:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Jalankan server:
   ```bash
   node index.js
   ```

### Frontend
1. Masuk ke folder frontend:
   ```bash
   cd frontend
   ```
2. Jalankan aplikasi Flutter sesuai platform:
   - Web: `flutter run -d chrome`
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`
   - Windows: `flutter run -d windows`
   - MacOS: `flutter run -d macos`
   - Linux: `flutter run -d linux`

## Konfigurasi
- Pastikan backend berjalan sebelum menggunakan fitur chat di frontend.
- Ubah konfigurasi API endpoint di `lib/config.dart` jika diperlukan.

## Kontribusi
Pull request dan issue sangat diterima untuk pengembangan lebih lanjut.

## Lisensi
MIT License
