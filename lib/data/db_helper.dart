import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user_model.dart';
import 'schedule_model.dart';
import 'report_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jadwal_piket_v3.db'); // ganti nama biar database baru ke-create
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      nipd TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE schedules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      day TEXT NOT NULL,
      user_id INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE reports (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      reporter_id INTEGER NOT NULL,
      image_path TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (reporter_id) REFERENCES users (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE report_details (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      report_id INTEGER NOT NULL,
      student_id INTEGER NOT NULL,
      is_present INTEGER NOT NULL,
      FOREIGN KEY (report_id) REFERENCES reports (id),
      FOREIGN KEY (student_id) REFERENCES users (id)
    )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // 1. bikin akun guru dulu nih
    await db.insert('users', User(
      name: 'Guru Wali',
      nipd: 'admin',
      password: 'admin',
      role: 'guru',
    ).toMap());

    // 2. data siswa - gampang diubah kalau mau customize
    // tinggal edit nama, nipd, sama jadwal piketnya sesuai kebutuhan
    
    // Siswa yang piket hari Senin
    await db.insert('users', User(name: 'Adi Santoso', nipd: '242510001', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Budi Wijaya', nipd: '242510002', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Citra Saputra', nipd: '242510003', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Dewi Putra', nipd: '242510004', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Eko Utami', nipd: '242510005', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Fajar Lestari', nipd: '242510006', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Gita Hidayat', nipd: '242510007', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Hadi Kusuma', nipd: '242510008', password: '123', role: 'siswa').toMap());

    // Siswa yang piket hari Selasa
    await db.insert('users', User(name: 'Algifahri Tri Ramadhan', nipd: '242510009', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Dwi Habibah Husain', nipd: '242510010', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Indah Pratama', nipd: '242510011', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Joko Nugroho', nipd: '242510012', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Kiki Santoso', nipd: '242510013', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Lina Wijaya', nipd: '242510014', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Milo Saputra', nipd: '242510015', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Nina Putra', nipd: '242510016', password: '123', role: 'siswa').toMap());

    // Siswa yang piket hari Rabu
    await db.insert('users', User(name: 'Oscar Utami', nipd: '242510017', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Putri Lestari', nipd: '242510018', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Qori Hidayat', nipd: '242510019', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Rina Kusuma', nipd: '242510020', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Sari Pratama', nipd: '242510021', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Tono Nugroho', nipd: '242510022', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Adi Wijaya', nipd: '242510023', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Budi Saputra', nipd: '242510024', password: '123', role: 'siswa').toMap());

    // Siswa yang piket hari Kamis
    await db.insert('users', User(name: 'Citra Putra', nipd: '242510025', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Dewi Utami', nipd: '242510026', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Eko Lestari', nipd: '242510027', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Fajar Hidayat', nipd: '242510028', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Gita Kusuma', nipd: '242510029', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Hadi Pratama', nipd: '242510030', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Indah Nugroho', nipd: '242510031', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Joko Santoso', nipd: '242510032', password: '123', role: 'siswa').toMap());

    // Siswa yang piket hari Jumat
    await db.insert('users', User(name: 'Kiki Wijaya', nipd: '242510033', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Lina Saputra', nipd: '242510034', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Milo Putra', nipd: '242510035', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Nina Utami', nipd: '242510036', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Oscar Lestari', nipd: '242510037', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Putri Hidayat', nipd: '242510038', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Qori Kusuma', nipd: '242510039', password: '123', role: 'siswa').toMap());
    await db.insert('users', User(name: 'Rina Pratama', nipd: '242510040', password: '123', role: 'siswa').toMap());

    // 3. atur jadwal piketnya sesuai grouping di atas
    // Senin (8 siswa: NIPD 001-008)
    for (int i = 1; i <= 8; i++) {
      await db.insert('schedules', {'day': 'Senin', 'user_id': i + 1});
    }

    // Selasa (8 siswa: NIPD 009-016)
    for (int i = 9; i <= 16; i++) {
      await db.insert('schedules', {'day': 'Selasa', 'user_id': i + 1});
    }

    // Rabu (8 siswa: NIPD 017-024)
    for (int i = 17; i <= 24; i++) {
      await db.insert('schedules', {'day': 'Rabu', 'user_id': i + 1});
    }

    // Kamis (8 siswa: NIPD 025-032)
    for (int i = 25; i <= 32; i++) {
      await db.insert('schedules', {'day': 'Kamis', 'user_id': i + 1});
    }

    // Jumat (8 siswa: NIPD 033-040)
    for (int i = 33; i <= 40; i++) {
      await db.insert('schedules', {'day': 'Jumat', 'user_id': i + 1});
    }
  }

  // CRUD Helpers
  Future<User?> getUser(String nipd, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'nipd = ? AND password = ?',
      whereArgs: [nipd, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateUserPassword(int id, String newPassword) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Schedule>> getSchedulesByDay(String day) async {
    final db = await instance.database;
    // join buat dapetin nama siswa juga
    final result = await db.rawQuery('''
      SELECT s.id, s.day, s.user_id, u.name as user_name
      FROM schedules s
      INNER JOIN users u ON s.user_id = u.id
      WHERE s.day = ?
    ''', [day]);

    return result.map((json) => Schedule.fromMap(json)).toList();
  }

  Future<List<Schedule>> getSchedulesByUser(int userId) async {
      final db = await instance.database;
      final result = await db.query(
          'schedules',
          where: 'user_id = ?',
          whereArgs: [userId],
      );
      return result.map((json) => Schedule.fromMap(json)).toList();
  }
  
  // buat guru: update/insert jadwal
  // sederhananya gini: buat ganti hari siswa, kita update entry jadwalnya
  // atau kalau hubungannya 1-ke-1 (satu hari per siswa), pake UPDATE
  // kalau many-to-many, pake INSERT/DELETE
  // asumsi: 1 hari per siswa aja biar simpel, sesuai seeding tadi
  Future<int> updateStudentSchedule(int userId, String newDay) async {
      final db = await instance.database;
      // cek dulu ada gak
      final exists = await db.query('schedules', where: 'user_id = ?', whereArgs: [userId]);
      if (exists.isNotEmpty) {
          return await db.update('schedules', {'day': newDay}, where: 'user_id = ?', whereArgs: [userId]);
      } else {
          return await db.insert('schedules', {'day': newDay, 'user_id': userId});
      }
  }

  Future<List<User>> getAllStudents() async {
      final db = await instance.database;
      final result = await db.query('users', where: 'role = ?', whereArgs: ['siswa']);
      return result.map((json) => User.fromMap(json)).toList();
  }

  // Report Methods
  Future<int> insertReport(Report report) async {
      final db = await instance.database;
      return await db.insert('reports', report.toMap());
  }

  Future<void> insertReportDetail(ReportDetail detail) async {
      final db = await instance.database;
      await db.insert('report_details', detail.toMap());
  }

  Future<bool> hasReportForDate(String date) async {
      final db = await instance.database;
      final result = await db.query('reports', where: 'date = ?', whereArgs: [date]);
      return result.isNotEmpty;
  }

  // ============ STATISTIK & ANALYTICS ============
  
  /// ambil semua report beserta detailnya buat siswa tertentu
  Future<List<Map<String, dynamic>>> getStudentReports(int studentId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT r.*, rd.is_present
      FROM reports r
      INNER JOIN report_details rd ON r.id = rd.report_id
      WHERE rd.student_id = ?
      ORDER BY r.date DESC
    ''', [studentId]);
    return result;
  }

  /// hitung statistik kehadiran buat siswa
  Future<Map<String, dynamic>> getStudentStats(int studentId) async {
    final db = await instance.database;
    
    // total hari yang dijadwalin
    final schedules = await db.query('schedules', where: 'user_id = ?', whereArgs: [studentId]);
    final scheduledDays = schedules.length;
    
    // total report dimana siswa hadir
    final presentResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM report_details
      WHERE student_id = ? AND is_present = 1
    ''', [studentId]);
    final presentCount = presentResult.first['count'] as int;
    
    // total report dimana siswa gak hadir
    final absentResult = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM report_details
      WHERE student_id = ? AND is_present = 0
    ''', [studentId]);
    final absentCount = absentResult.first['count'] as int;
    
    // total report keseluruhan
    final totalReports = presentCount + absentCount;
    
    // persentase kehadiran
    final attendanceRate = totalReports > 0 ? (presentCount / totalReports * 100) : 0.0;
    
    return {
      'scheduledDays': scheduledDays,
      'totalReports': totalReports,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'attendanceRate': attendanceRate,
    };
  }

  /// ambil data leaderboard (semua siswa diranking berdasarkan kehadiran)
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        u.id,
        u.name,
        u.nipd,
        COUNT(CASE WHEN rd.is_present = 1 THEN 1 END) as present_count,
        COUNT(rd.id) as total_reports,
        CAST(COUNT(CASE WHEN rd.is_present = 1 THEN 1 END) AS FLOAT) / 
        NULLIF(COUNT(rd.id), 0) * 100 as attendance_rate
      FROM users u
      LEFT JOIN report_details rd ON u.id = rd.student_id
      WHERE u.role = 'siswa'
      GROUP BY u.id
      ORDER BY attendance_rate DESC, present_count DESC
    ''');
    return result;
  }

  /// ambil semua report dengan detail lengkap
  Future<List<Map<String, dynamic>>> getAllReportsWithDetails() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        r.*,
        u.name as reporter_name,
        COUNT(rd.id) as total_students,
        SUM(CASE WHEN rd.is_present = 1 THEN 1 ELSE 0 END) as present_count
      FROM reports r
      INNER JOIN users u ON r.reporter_id = u.id
      LEFT JOIN report_details rd ON r.id = rd.report_id
      GROUP BY r.id
      ORDER BY r.date DESC, r.created_at DESC
    ''');
    return result;
  }

  /// ambil detail report termasuk nama siswa dan status kehadiran
  Future<List<Map<String, dynamic>>> getReportDetails(int reportId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        rd.*,
        u.name as student_name,
        u.nipd
      FROM report_details rd
      INNER JOIN users u ON rd.student_id = u.id
      WHERE rd.report_id = ?
      ORDER BY u.name
    ''', [reportId]);
    return result;
  }

  /// ambil statistik kelas (buat analytics guru)
  Future<Map<String, dynamic>> getClassStats() async {
    final db = await instance.database;
    
    // total siswa
    final studentCount = await db.rawQuery('SELECT COUNT(*) as count FROM users WHERE role = "siswa"');
    final totalStudents = studentCount.first['count'] as int;
    
    // total report
    final reportCount = await db.rawQuery('SELECT COUNT(*) as count FROM reports');
    final totalReports = reportCount.first['count'] as int;
    
    // rata-rata persentase kehadiran
    final avgAttendance = await db.rawQuery('''
      SELECT AVG(attendance_rate) as avg_rate FROM (
        SELECT 
          CAST(COUNT(CASE WHEN rd.is_present = 1 THEN 1 END) AS FLOAT) / 
          NULLIF(COUNT(rd.id), 0) * 100 as attendance_rate
        FROM users u
        LEFT JOIN report_details rd ON u.id = rd.student_id
        WHERE u.role = 'siswa'
        GROUP BY u.id
      )
    ''');
    final avgRate = avgAttendance.first['avg_rate'] ?? 0.0;
    
    return {
      'totalStudents': totalStudents,
      'totalReports': totalReports,
      'averageAttendanceRate': avgRate,
    };
  }

  /// ambil jumlah report bulanan buat chart
  Future<List<Map<String, dynamic>>> getMonthlyReportStats() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        COUNT(*) as report_count
      FROM reports
      GROUP BY month
      ORDER BY month DESC
      LIMIT 12
    ''');
    return result;
  }
}
