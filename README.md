# 📅 Jadwal Piket Cerdas

Aplikasi manajemen jadwal piket kelas yang bikin ngatur piket jadi lebih gampang dan terorganisir. Dibuat pake Flutter biar bisa jalan di mana aja - Android, iOS, Web, Windows, Linux, macOS.

## 🎯 Fitur Utama

### Untuk Siswa
- **Lapor Piket** - Pilih foto bukti piket dari:
  - 📷 **Kamera** - Ambil foto langsung:
    - Di laptop/web: Buka webcam laptop (browser akan minta izin akses kamera)
    - Di HP: Buka kamera HP
  - 🖼️ **Galeri/File** - Pilih dari storage:
    - Di laptop/web: File explorer komputer
    - Di HP: Galeri foto
  - Centang temen yang hadir piket
- **Statistik Personal** - Lihat persentase kehadiran piket kamu
- **Riwayat Laporan** - Cek semua laporan piket yang pernah kamu kirim
- **Dashboard Interaktif** - Tampilan yang clean dan mudah dipahami

### Untuk Guru
- **Dashboard Analytics** - Overview lengkap statistik kelas
- **Kelola Jadwal** - Atur jadwal piket per hari dengan mudah
- **Leaderboard** - Ranking siswa berdasarkan kehadiran piket
- **Semua Laporan** - Lihat dan verifikasi semua laporan yang masuk
- **Kalender Interaktif** - Lihat jadwal piket dalam bentuk kalender

## 🗄️ Database & Sistem

### Struktur Database

Aplikasi ini pake **SQLite** sebagai database lokal. Ada 4 tabel utama:

#### 1. **users** - Data Pengguna
```sql
- id: Primary key
- name: Nama lengkap
- nipd: NIPD/Username untuk login
- password: Password (plaintext - untuk demo aja ya)
- role: 'guru' atau 'siswa'
```

#### 2. **schedules** - Jadwal Piket
```sql
- id: Primary key
- day: Hari piket ('Senin', 'Selasa', dst.)
- user_id: Foreign key ke users
```

#### 3. **reports** - Laporan Piket
```sql
- id: Primary key
- date: Tanggal laporan (YYYY-MM-DD)
- reporter_id: Foreign key ke users (yang ngelaporin)
- image_path: Path foto bukti piket
- created_at: Timestamp pembuatan
```

#### 4. **report_details** - Detail Kehadiran
```sql
- id: Primary key
- report_id: Foreign key ke reports
- student_id: Foreign key ke users
- is_present: 1 = hadir, 0 = gak hadir
```

### Cara Kerja Sistem

1. **Login System**
   - Guru login pake NIPD: `admin`, Password: `admin`
   - Siswa login pake NIPD masing-masing, Password default: `123`

2. **Seeding Data**
   - Otomatis bikin 1 akun guru
   - Bikin 40 siswa (termasuk Algifahri dan Habibah)
   - Distribute jadwal piket secara merata ke 5 hari kerja

3. **Flow Laporan Piket**
   - Siswa yang piket hari ini buka app
   - Pilih sumber foto: Kamera (ambil langsung) atau Galeri/File (pilih dari storage)
   - Upload foto bukti piket
   - Centang temen-temen yang hadir piket
   - Submit laporan
   - Data masuk ke database dengan status kehadiran masing-masing

4. **Analytics & Statistics**
   - Real-time calculation persentase kehadiran
   - Leaderboard otomatis update berdasarkan data report
   - Chart dan grafik interaktif

## 🚀 Cara Menggunakan

### Prerequisites

Yang perlu kamu install dulu:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi terbaru)
- Android Studio / VS Code
- Git

### Step-by-Step Installation

#### 1. Clone Repository
```bash
git clone https://github.com/username/jadwal_piket_cerdas.git
cd jadwal_piket_cerdas
```

#### 2. Install Dependencies
```bash
flutter pub get
```

#### 3. Jalanin di Device/Emulator

**Android/iOS:**
```bash
# Pastiin device/emulator udah nyala
flutter devices

# Jalanin aplikasi
flutter run
```

**Web:**
```bash
flutter run -d chrome
```

**Windows:**
```bash
flutter run -d windows
```

**Linux:**
```bash
flutter run -d linux
```

**macOS:**
```bash
flutter run -d macos
```

### Login Credentials

**Guru:**
- NIPD: `admin`
- Password: `admin`

**Siswa:**
- Password semua siswa: `123`
- NIPD: Otomatis di-generate saat pertama kali run (format: `242510001`, `242510002`, dst.)

> **Note:** NIPD siswa di-generate otomatis pake pattern `242510000 + seed`. Jadi setiap siswa punya NIPD unik, bisa diubah passwordnya kalau udah login.

### Data Seeding (Auto-Generated)

Saat pertama kali aplikasi jalan, database otomatis diisi dengan:

**1 Akun Guru:**
- Nama: Guru Wali
- NIPD: `admin`
- Password: `admin`

**40 Akun Siswa:**
- Dikelompokkan per hari (8 siswa per hari)
- NIPD: `242510001` sampai `242510040`
- Password: semua `123`

**Jadwal Piket:**
- **Senin:** 8 siswa (NIPD 001-008)
- **Selasa:** 8 siswa (NIPD 009-016) - termasuk Algifahri & Habibah
- **Rabu:** 8 siswa (NIPD 017-024)
- **Kamis:** 8 siswa (NIPD 025-032)
- **Jumat:** 8 siswa (NIPD 033-040)

### 🔧 Cara Customize Data Siswa

Kalau mau ganti data siswa sesuai kelas kamu, gampang banget! Tinggal edit file `lib/data/db_helper.dart`:

**1. Buka file `lib/data/db_helper.dart`**

**2. Cari fungsi `_seedData` (sekitar line 76)**

**3. Edit data siswa sesuai kebutuhan:**

```dart
// Contoh: Ganti siswa pertama
await db.insert('users', User(
  name: 'Nama Siswa Kamu',      // <- Ganti nama
  nipd: '242510001',             // <- Ganti NIPD (harus unik!)
  password: '123',               // <- Ganti password kalau mau
  role: 'siswa'
).toMap());
```

**4. Atur ulang jadwal piket kalau perlu:**

Scroll ke bawah, cari bagian pengaturan jadwal (sekitar line 139). Sesuaikan user_id dengan siswa yang mau kamu assign:

```dart
// Contoh: Assign siswa ke hari Senin
// user_id dimulai dari 2 (karena 1 = guru)
for (int i = 1; i <= 8; i++) {
  await db.insert('schedules', {'day': 'Senin', 'user_id': i + 1});
}
```

**5. Hapus database lama (kalau udah pernah run):**

```bash
# Hapus database biar data baru ke-load
flutter clean
```

**6. Run ulang aplikasi:**

```bash
flutter run
```

> **Tips:**
> - Pastiin NIPD unik untuk setiap siswa
> - Jumlah siswa bebas, gak harus 40
> - Bisa atur berapa siswa per hari sesuai kebutuhan
> - Password bisa diubah per siswa atau sama semua

> **Cara Lihat NIPD Siswa:**
> Login sebagai guru, terus buka menu "Daftar Akun Siswa" untuk lihat semua NIPD dan password siswa.

## 📱 Screenshot

> TODO: Tambahin screenshot aplikasi di sini

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **Database:** SQLite (sqflite)
- **UI Components:** 
  - Material Design 3
  - Google Fonts (Inter)
  - FL Chart (untuk grafik)
  - Table Calendar
- **Image Handling:** image_picker (support kamera & galeri untuk semua platform)
- **Date Formatting:** intl

## 📂 Struktur Folder

```
lib/
├── data/              # Models & Database Helper
│   ├── db_helper.dart
│   ├── user_model.dart
│   ├── schedule_model.dart
│   └── report_model.dart
├── providers/         # State Management
│   └── auth_provider.dart
├── ui/               # User Interface
│   ├── student/      # Halaman untuk siswa
│   ├── teacher/      # Halaman untuk guru
│   └── login_page.dart
├── utils/            # Utilities & Constants
│   ├── constants.dart
│   └── notification_helper.dart
└── main.dart         # Entry point
```

## 🎨 Design System

Aplikasi ini pake color palette yang soft dan professional:

- **Primary:** Muted Blue-Grey (#5B7C99)
- **Secondary:** Soft Sage Green (#7FA99B)
- **Accent:** Warm Terracotta (#E8A87C)
- **Background:** Very Light Grey (#F8F9FA)

Typography pake **Google Fonts - Inter** buat tampilan yang modern dan clean.

## 🔧 Development

### Build untuk Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Windows:**
```bash
flutter build windows --release
```

### Testing

```bash
# Run tests
flutter test

# Analyze code
flutter analyze
```

## 👨‍💻 Author

Algifahri Tri Ramadhan

## 📝 Notes

late, already deleted
---

