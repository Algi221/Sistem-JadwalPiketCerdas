import 'package:flutter/material.dart';
import '../../data/db_helper.dart';
import '../../utils/constants.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final leaderboard = await DatabaseHelper.instance.getLeaderboard();
    setState(() {
      _leaderboard = leaderboard;
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leaderboard Kehadiran'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _leaderboard.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada data', style: AppStyles.header.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) {
                final student = _leaderboard[index];
                final rank = index + 1;
                final name = student['name'] as String;
                final presentCount = student['present_count'] as int;
                final totalReports = student['total_reports'] as int;
                final attendanceRate = (student['attendance_rate'] ?? 0.0) as double;

                Color rankColor = AppColors.textSecondary;
                IconData? medalIcon;
                
                if (rank == 1) {
                  rankColor = const Color(0xFFFFD700); // emas
                  medalIcon = Icons.emoji_events_rounded;
                } else if (rank == 2) {
                  rankColor = const Color(0xFFC0C0C0); // perak
                  medalIcon = Icons.emoji_events_rounded;
                } else if (rank == 3) {
                  rankColor = const Color(0xFFCD7F32); // perunggu
                  medalIcon = Icons.emoji_events_rounded;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppStyles.cardDecoration.copyWith(
                    border: rank <= 3 ? Border.all(color: rankColor.withOpacity(0.3), width: 2) : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: rank <= 3 ? rankColor.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: medalIcon != null
                            ? Icon(medalIcon, color: rankColor, size: 28)
                            : Text(
                                '$rank',
                                style: AppStyles.header.copyWith(
                                  fontSize: 20,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    title: Text(name, style: AppStyles.header.copyWith(fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Hadir: $presentCount dari $totalReports laporan',
                          style: AppStyles.body.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalReports > 0 ? attendanceRate / 100 : 0,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              attendanceRate >= 80
                                  ? AppColors.success
                                  : attendanceRate >= 60
                                      ? AppColors.accent
                                      : AppColors.error,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: attendanceRate >= 80
                            ? AppColors.success.withOpacity(0.1)
                            : attendanceRate >= 60
                                ? AppColors.accent.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${attendanceRate.toStringAsFixed(0)}%',
                        style: AppStyles.body.copyWith(
                          color: attendanceRate >= 80
                              ? AppColors.success
                              : attendanceRate >= 60
                                  ? AppColors.accent
                                  : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
