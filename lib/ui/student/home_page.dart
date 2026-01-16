import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../database/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/notification_helper.dart';
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
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.id != null) {
      final myScheds = await DatabaseHelper.instance.getSchedulesByUser(auth.currentUser!.id!);
      setState(() {
        _mySchedules = myScheds;
      });
      _checkTodayPiket(myScheds);
    }
    
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final hasReport = await DatabaseHelper.instance.hasReportForDate(dateStr);
    
    setState(() {
        _hasReportToday = hasReport;
    });

    _loadScheduleForDate(_selectedDay);
  }

  void _checkTodayPiket(List<Schedule> myScheds) {
      final now = DateTime.now();
      final dayName = DateFormat('EEEE').format(now);
      
      String indoDay = '';
      switch (dayName) {
          case 'Monday': indoDay = 'Senin'; break;
          case 'Tuesday': indoDay = 'Selasa'; break;
          case 'Wednesday': indoDay = 'Rabu'; break;
          case 'Thursday': indoDay = 'Kamis'; break;
          case 'Friday': indoDay = 'Jumat'; break;
          default: indoDay = '';
      }
      
      if (indoDay.isNotEmpty) {
          final isPiketToday = myScheds.any((s) => s.day == indoDay);
          if (isPiketToday) {
              NotificationHelper().showNotification(
                  "Jangan Lupa Piket!", 
                  "Hari ini ($indoDay) adalah jadwal piket kamu."
              );
          }
      }
  }
  
  Future<void> _loadScheduleForDate(DateTime date) async {
      final dayName = DateFormat('EEEE').format(date);
      String indoDay = '';
      switch (dayName) {
          case 'Monday': indoDay = 'Senin'; break;
          case 'Tuesday': indoDay = 'Selasa'; break;
          case 'Wednesday': indoDay = 'Rabu'; break;
          case 'Thursday': indoDay = 'Kamis'; break;
          case 'Friday': indoDay = 'Jumat'; break;
          default: indoDay = '';
      }
      
      if (indoDay.isNotEmpty) {
          final scheds = await DatabaseHelper.instance.getSchedulesByDay(indoDay);
          setState(() {
              _classSchedules = scheds;
          });
      } else {
          setState(() {
              _classSchedules = [];
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${user?.name ?? 'Siswa'}', 
              style: AppStyles.header.copyWith(fontSize: 16, color: Colors.white)),
            Text('Kelas 11-J', 
              style: AppStyles.body.copyWith(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22), 
              onPressed: _loadData
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMyScheduleCard(),
            const SizedBox(height: 24),
            
            _buildCalendarCard(),
            const SizedBox(height: 24),
            
            Text("Jadwal Piket", style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDay),
              style: AppStyles.body.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            _classSchedules.isEmpty 
            ? Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: AppStyles.cardDecoration,
                child: Column(
                  children: [
                    Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text("Tidak ada jadwal piket", style: AppStyles.body),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classSchedules.length,
                itemBuilder: (context, index) {
                    final item = _classSchedules[index];
                    final isMe = item.userId == user?.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppStyles.cardDecoration.copyWith(
                        color: isMe ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                      ),
                      child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.primary.withOpacity(0.15) : AppColors.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}", 
                                  style: TextStyle(
                                    color: isMe ? AppColors.primary : AppColors.secondary, 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )
                                ),
                              ),
                          ),
                          title: Text(item.userName ?? 'Siswa', style: AppStyles.header.copyWith(fontSize: 15)),
                          trailing: isMe 
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text("Saya", style: AppStyles.body.copyWith(color: Colors.white, fontSize: 12)),
                                )
                              : null,
                      ),
                    );
                },
            ),
          ],
        ),
      ),
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
          _loadScheduleForDate(selectedDay);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildMyScheduleCard() {
    if (_mySchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: AppStyles.cardDecoration,
        child: Column(
             children: [
                 Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.success.withOpacity(0.7)),
                 const SizedBox(height: 12),
                 Text("Tidak ada jadwal piket", style: AppStyles.header.copyWith(color: AppColors.success)),
                 const SizedBox(height: 4),
                 Text("Anda bebas dari tugas piket minggu ini", style: AppStyles.body.copyWith(fontSize: 13)),
             ] 
          ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration.copyWith(
        color: AppColors.primary.withOpacity(0.05),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
             children: [
                 Container(
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: AppColors.primary.withOpacity(0.15),
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary, size: 20)
                 ),
                 const SizedBox(width: 12),
                 Text("Jadwal Piket Saya", style: AppStyles.header.copyWith(fontSize: 16)),
             ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _mySchedules.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s.day, style: AppStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          _buildReportButton(),
        ],
      ),
    );
  }

  Widget _buildReportButton() {
     final now = DateTime.now();
     final dayName = DateFormat('EEEE').format(now);
     String indoDay = '';
     switch (dayName) {
          case 'Monday': indoDay = 'Senin'; break;
          case 'Tuesday': indoDay = 'Selasa'; break;
          case 'Wednesday': indoDay = 'Rabu'; break;
          case 'Thursday': indoDay = 'Kamis'; break;
          case 'Friday': indoDay = 'Jumat'; break;
     }

     final isPiketToday = _mySchedules.any((s) => s.day == indoDay);
     
     if (isPiketToday) {
         if (_hasReportToday) {
             return Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                 decoration: BoxDecoration(
                     color: AppColors.success.withOpacity(0.15),
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: AppColors.success.withOpacity(0.3)),
                 ),
                 child: Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                         const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                         const SizedBox(width: 8),
                         Text("Laporan Terkirim", style: AppStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                     ]
                 ),
             );
         } else {
             return SizedBox(
                 width: double.infinity,
                 child: ElevatedButton.icon(
                     icon: const Icon(Icons.camera_alt_rounded, size: 20),
                     label: const Text("Lapor Piket"),
                     style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                         elevation: 0,
                     ),
                     onPressed: () async {
                         final todaysScheds = await DatabaseHelper.instance.getSchedulesByDay(indoDay);
                         
                         if (mounted) {
                             final result = await Navigator.push(
                                 context, 
                                 MaterialPageRoute(builder: (_) => ReportPage(todaysSchedules: todaysScheds))
                             );
                             
                             if (result == true) {
                                 _loadData(); 
                             }
                         }
                     },
                 ),
             );
         }
     }
     
     return const SizedBox(); 
  }
}
