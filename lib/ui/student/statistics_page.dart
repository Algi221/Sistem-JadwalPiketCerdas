import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class StudentStatisticsPage extends StatefulWidget {
  const StudentStatisticsPage({super.key});

  @override
  State<StudentStatisticsPage> createState() => _StudentStatisticsPageState();
}

class _StudentStatisticsPageState extends State<StudentStatisticsPage> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.id != null) {
      final stats = await DatabaseHelper.instance.getStudentStats(auth.currentUser!.id!);
      final reports = await DatabaseHelper.instance.getStudentReports(auth.currentUser!.id!);
      
      setState(() {
        _stats = stats;
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final presentCount = _stats?['presentCount'] ?? 0;
    final absentCount = _stats?['absentCount'] ?? 0;
    final attendanceRate = _stats?['attendanceRate'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik Saya'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // kartu persentase kehadiran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cardDecoration.copyWith(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF4A6FA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '${attendanceRate.toStringAsFixed(1)}%',
                    style: AppStyles.title.copyWith(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tingkat Kehadiran',
                    style: AppStyles.body.copyWith(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // grid statistik
            Row(
              children: [
                Expanded(child: _buildStatCard('Hadir', presentCount, AppColors.success, Icons.check_circle_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Tidak Hadir', absentCount, AppColors.error, Icons.cancel_rounded)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Laporan', _stats?['totalReports'] ?? 0, AppColors.secondary, Icons.description_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Jadwal Piket', _stats?['scheduledDays'] ?? 0, AppColors.accent, Icons.calendar_today_rounded)),
              ],
            ),
            const SizedBox(height: 32),

            // grafik kehadiran
            Text('Grafik Kehadiran', style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      value: presentCount.toDouble(),
                      title: '$presentCount',
                      color: AppColors.success,
                      radius: 50,
                      titleStyle: AppStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      value: absentCount.toDouble(),
                      title: '$absentCount',
                      color: AppColors.error.withOpacity(0.7),
                      radius: 50,
                      titleStyle: AppStyles.body.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // laporan terbaru
            Text('Riwayat Terbaru', style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _reports.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    decoration: AppStyles.cardDecoration,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Belum ada riwayat', style: AppStyles.body),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reports.length > 5 ? 5 : _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final isPresent = report['is_present'] == 1;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: AppStyles.cardDecoration,
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPresent ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isPresent ? Icons.check_circle : Icons.cancel,
                              color: isPresent ? AppColors.success : AppColors.error,
                            ),
                          ),
                          title: Text(report['date'] ?? '', style: AppStyles.header.copyWith(fontSize: 15)),
                          subtitle: Text(
                            isPresent ? 'Hadir' : 'Tidak Hadir',
                            style: AppStyles.body.copyWith(
                              color: isPresent ? AppColors.success : AppColors.error,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: AppStyles.title.copyWith(fontSize: 28, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.body.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
