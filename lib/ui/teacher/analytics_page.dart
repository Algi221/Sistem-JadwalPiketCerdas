import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../database/db_helper.dart';
import '../../utils/constants.dart';

class TeacherAnalyticsPage extends StatefulWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  State<TeacherAnalyticsPage> createState() => _TeacherAnalyticsPageState();
}

class _TeacherAnalyticsPageState extends State<TeacherAnalyticsPage> {
  Map<String, dynamic>? _classStats;
  List<Map<String, dynamic>> _monthlyStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final classStats = await DatabaseHelper.instance.getClassStats();
    final monthlyStats = await DatabaseHelper.instance.getMonthlyReportStats();
    
    setState(() {
      _classStats = classStats;
      _monthlyStats = monthlyStats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final totalStudents = _classStats?['totalStudents'] ?? 0;
    final totalReports = _classStats?['totalReports'] ?? 0;
    final avgRate = (_classStats?['averageAttendanceRate'] ?? 0.0) as double;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics Kelas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // kartu overview
            Text('Overview Kelas 11-J', style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Siswa',
                    totalStudents.toString(),
                    Icons.people_rounded,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Laporan',
                    totalReports.toString(),
                    Icons.description_rounded,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Rata-rata Kehadiran',
              '${avgRate.toStringAsFixed(1)}%',
              Icons.trending_up_rounded,
              AppColors.success,
            ),
            const SizedBox(height: 32),

            // chart laporan bulanan
            Text('Laporan Bulanan', style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.cardDecoration,
              child: _monthlyStats.isEmpty
                  ? Center(
                      child: Text('Belum ada data', style: AppStyles.body),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (_monthlyStats.map((e) => e['report_count'] as int).reduce((a, b) => a > b ? a : b) + 5).toDouble(),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= _monthlyStats.length) return const SizedBox();
                                final month = _monthlyStats[value.toInt()]['month'] as String;
                                final parts = month.split('-');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    parts.length > 1 ? parts[1] : month,
                                    style: AppStyles.body.copyWith(fontSize: 11),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: AppStyles.body.copyWith(fontSize: 11),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          _monthlyStats.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (_monthlyStats[index]['report_count'] as int).toDouble(),
                                color: AppColors.primary,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 32),

            // aksi cepat
            Text('Aksi Cepat', style: AppStyles.title.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildActionButton(
              'Lihat Leaderboard',
              Icons.emoji_events_rounded,
              AppColors.accent,
              () {
                Navigator.pushNamed(context, '/leaderboard');
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Semua Laporan',
              Icons.list_alt_rounded,
              AppColors.secondary,
              () {
                Navigator.pushNamed(context, '/all-reports');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppStyles.title.copyWith(fontSize: 32, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.body.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppStyles.cardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: AppStyles.header.copyWith(fontSize: 16)),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
