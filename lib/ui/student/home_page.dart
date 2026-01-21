import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../database/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/notification_helper.dart';
import '../../utils/calendar_helper.dart';
import 'report_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Schedule> _mySchedules = [];
  List<Schedule> _classSchedules = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _hasReportToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null && user.id != null) {
      final mySchedules = await DatabaseHelper.instance.getSchedulesByUser(user.id!);
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final hasReport = await DatabaseHelper.instance.hasReportForDate(dateStr);
      
      if (mounted) {
        setState(() {
          _mySchedules = mySchedules;
          _hasReportToday = hasReport;
        });
        _loadScheduleForDate(_selectedDay);
      }
    }
  }

  Future<void> _loadScheduleForDate(DateTime date) async {
    final dayName = DateFormat('EEEE').format(date);
    String indoDay = _getIndonesianDay(dayName);
    
    final schedules = await DatabaseHelper.instance.getSchedulesByDay(indoDay);
    if (mounted) {
      setState(() {
        _classSchedules = schedules;
      });
    }
  }

  String _getIndonesianDay(String dayName) {
    switch (dayName) {
      case 'Monday': return 'Senin';
      case 'Tuesday': return 'Selasa';
      case 'Wednesday': return 'Rabu';
      case 'Thursday': return 'Kamis';
      case 'Friday': return 'Jumat';
      default: return dayName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Jadwal Piket Cerdas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
              tooltip: 'Sinkron ke Kalender HP',
              onPressed: () => _syncToCalendar(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22), 
              onPressed: _loadData
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(user),
            _buildCalendar(),
            _buildScheduleList(),
            const SizedBox(height: 20),
            if (_isPiketDayToday()) _buildReportButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, ${user?.name ?? ""}', 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('NIPD: ${user?.nipd ?? ""}', 
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(10),
      decoration: AppStyles.cardDecoration,
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadScheduleForDate(selectedDay);
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), shape: BoxShape.circle),
        ),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      ),
    );
  }

  Widget _buildScheduleList() {
    final dayName = DateFormat('EEEE', 'id_ID').format(_focusedDay);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Petugas Piket Hari $dayName', 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        if (_classSchedules.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('Tidak ada jadwal piket hari ini'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _classSchedules.length,
            itemBuilder: (context, index) {
              final schedule = _classSchedules[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                padding: const EdgeInsets.all(15),
                decoration: AppStyles.cardDecoration,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text((index + 1).toString(), style: TextStyle(color: AppColors.primary))),
                    const SizedBox(width: 15),
                    Text(schedule.userName ?? ""),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReportButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _hasReportToday ? null : () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ReportPage(todaysSchedules: _classSchedules)));
          },
          icon: const Icon(Icons.camera_alt_rounded),
          label: Text(_hasReportToday ? "Sudah Lapor" : "Lapor Piket"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

  bool _isPiketDayToday() {
    final todayName = DateFormat('EEEE').format(DateTime.now());
    String todayIndo = _getIndonesianDay(todayName);
    return _mySchedules.any((s) => s.day == todayIndo);
  }

  Future<void> _syncToCalendar(BuildContext context) async {
    if (kIsWeb) {
      _showSimpleDialog(context, 'Fitur Tidak Tersedia', 'Sinkronisasi hanya bisa di HP Android/iOS.');
      return;
    }

    if (_mySchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal kamu belum ada.')));
      return;
    }

    // MINTA IZIN DULU!
    await Permission.calendarFullAccess.request();
    await Permission.notification.request();
    
    // Khusus Android 13+, minta izin Exact Alarm
    final alarmStatus = await Permission.scheduleExactAlarm.status;
    if (alarmStatus.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    _showLoadingDialog(context);

    final successCount = await CalendarHelper.addAllPiketSchedules(
      studentName: Provider.of<AuthProvider>(context, listen: false).currentUser?.name ?? 'Siswa',
      piketDay: _mySchedules.first.day,
    );

    if (mounted) Navigator.pop(context); // Tutup loading

    if (mounted) {
      _showSimpleDialog(context, 
        successCount > 0 ? 'Berhasil!' : 'Gagal',
        successCount > 0 
          ? 'Jadwal piket & ALARM sudah disetel otomatis jam 05:45 pagi untuk 4 minggu ke depan! ⏰✨'
          : 'Gagal sinkron. Pastikan kamu memberi izin Kalender.'
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(child: Padding(padding: EdgeInsets.all(24), 
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(), SizedBox(height: 16), Text('Menyinkronkan...')
          ])))),
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}