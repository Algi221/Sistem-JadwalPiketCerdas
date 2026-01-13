import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../data/db_helper.dart';
import '../login_page.dart';
import '../credential_viewer_page.dart';
import 'day_detail_page.dart';
import 'analytics_page.dart';
import 'leaderboard_page.dart';
import 'all_reports_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, dynamic>? _classStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await DatabaseHelper.instance.getClassStats();
      if (mounted) {
        setState(() {
          _classStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      if (mounted) {
        setState(() {
          _classStats = {
            'totalStudents': 0,
            'totalReports': 0,
            'averageAttendanceRate': 0.0,
          };
          _isLoading = false;
        });
      }
    }
  }

  String _getIndonesianDay(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    switch (dayName) {
      case 'Monday': return 'Senin';
      case 'Tuesday': return 'Selasa';
      case 'Wednesday': return 'Rabu';
      case 'Thursday': return 'Kamis';
      case 'Friday': return 'Jumat';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Guru', style: AppStyles.header.copyWith(fontSize: 16, color: Colors.white)),
            Text('SMA Yadika 11 - Kelas 11-J', style: AppStyles.body.copyWith(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(context, auth),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // overview statistik
                  _buildStatsOverview(),
                  const SizedBox(height: 24),

                  // kalender
                  Text('Kalender Jadwal Piket', style: AppStyles.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  _buildCalendarCard(),
                  const SizedBox(height: 24),

                  // menu cepat
                  Text('Menu Utama', style: AppStyles.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 16),
                  
                  _buildMenuList(),
                  const SizedBox(height: 32),
                  
                  // kelola jadwal
                  Text('Kelola Jadwal Piket', style: AppStyles.title.copyWith(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    'Atur jadwal piket untuk setiap hari',
                    style: AppStyles.body.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildScheduleList(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsOverview() {
    final totalStudents = _classStats?['totalStudents'] ?? 0;
    final totalReports = _classStats?['totalReports'] ?? 0;
    final avgRate = (_classStats?['averageAttendanceRate'] ?? 0.0) as double;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4A6FA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Kelas 11-J',
                      style: AppStyles.header.copyWith(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Statistik keseluruhan kelas',
                      style: AppStyles.body.copyWith(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('$totalStudents', 'Total Siswa', Icons.people_rounded),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem('$totalReports', 'Total Laporan', Icons.description_rounded),
              ),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              Expanded(
                child: _buildStatItem('${avgRate.toStringAsFixed(0)}%', 'Avg Attendance', Icons.trending_up_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppStyles.title.copyWith(color: Colors.white, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.body.copyWith(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppStyles.header.copyWith(fontSize: 16),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          selectedTextStyle: AppStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          weekendTextStyle: AppStyles.body.copyWith(color: AppColors.error.withOpacity(0.7)),
          outsideDaysVisible: false,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          weekendStyle: AppStyles.body.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.error.withOpacity(0.7)),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          
          final indoDay = _getIndonesianDay(selectedDay);
          if (indoDay.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DayDetailPage(day: indoDay)),
            );
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildMenuList() {
    final menuItems = [
      {
        'title': 'Analytics Kelas',
        'subtitle': 'Lihat statistik dan grafik kelas',
        'icon': Icons.analytics_rounded,
        'color': AppColors.primary,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherAnalyticsPage())),
      },
      {
        'title': 'Leaderboard',
        'subtitle': 'Ranking siswa berdasarkan kehadiran',
        'icon': Icons.emoji_events_rounded,
        'color': AppColors.accent,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardPage())),
      },
      {
        'title': 'Semua Laporan',
        'subtitle': 'Lihat semua laporan piket yang masuk',
        'icon': Icons.list_alt_rounded,
        'color': AppColors.secondary,
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllReportsPage())),
      },
      {
        'title': 'Daftar Akun Siswa',
        'subtitle': 'Lihat NIPD dan password semua siswa',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF7F8C8D),
        'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CredentialViewerPage())),
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final color = item['color'] as Color;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppStyles.cardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'] as IconData, color: color, size: 26),
            ),
            title: Text(item['title'] as String, style: AppStyles.header.copyWith(fontSize: 16)),
            subtitle: Text(item['subtitle'] as String, style: AppStyles.body.copyWith(fontSize: 13)),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ),
            onTap: item['onTap'] as VoidCallback,
          ),
        );
      },
    );
  }

  Widget _buildScheduleList() {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final colors = [
          AppColors.primary,
          AppColors.secondary,
          AppColors.accent,
          const Color(0xFF9B59B6),
          const Color(0xFFE67E22),
        ];
        final color = colors[index % colors.length];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppStyles.cardDecoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  day.substring(0, 1),
                  style: AppStyles.title.copyWith(color: color, fontSize: 20),
                ),
              ),
            ),
            title: Text(day, style: AppStyles.header.copyWith(fontSize: 16)),
            subtitle: Text('Kelola jadwal piket hari $day', style: AppStyles.body.copyWith(fontSize: 13)),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DayDetailPage(day: day)),
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Konfirmasi Logout', style: AppStyles.header.copyWith(fontSize: 18)),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: AppStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal', style: AppStyles.body.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                auth.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Logout', style: AppStyles.buttonText),
            ),
          ],
        );
      },
    );
  }
}
