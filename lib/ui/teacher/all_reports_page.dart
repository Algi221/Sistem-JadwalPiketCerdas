import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/db_helper.dart';
import '../../utils/constants.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await DatabaseHelper.instance.getAllReportsWithDetails();
    setState(() {
      _reports = reports;
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
        title: const Text('Semua Laporan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada laporan', style: AppStyles.header.copyWith(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final reportId = report['id'] as int;
                final date = report['date'] as String;
                final reporterName = report['reporter_name'] as String;
                final imagePath = report['image_path'] as String;
                final presentCount = report['present_count'] as int;
                final totalStudents = report['total_students'] as int;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: AppStyles.cardDecoration,
                  child: InkWell(
                    onTap: () => _showReportDetails(reportId, date, imagePath),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // placeholder gambar buat web
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_camera_rounded, size: 48, color: AppColors.secondary.withOpacity(0.5)),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto Laporan',
                                  style: AppStyles.body.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(date)),
                                    style: AppStyles.header.copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Dilaporkan oleh: $reporterName',
                                    style: AppStyles.body.copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    '$presentCount Hadir',
                                    AppColors.success,
                                    Icons.check_circle_rounded,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    '${totalStudents - presentCount} Tidak Hadir',
                                    AppColors.error,
                                    Icons.cancel_rounded,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.body.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDetails(int reportId, String date, String imagePath) async {
    final details = await DatabaseHelper.instance.getReportDetails(reportId);
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Detail Laporan',
                    style: AppStyles.title.copyWith(fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(date)),
                    style: AppStyles.header.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ...details.map((detail) {
                    final studentName = detail['student_name'] as String;
                    final isPresent = detail['is_present'] == 1;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: AppStyles.cardDecoration,
                      child: Row(
                        children: [
                          Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            color: isPresent ? AppColors.success : AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(studentName, style: AppStyles.header.copyWith(fontSize: 15)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPresent ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPresent ? 'Hadir' : 'Tidak Hadir',
                              style: AppStyles.body.copyWith(
                                color: isPresent ? AppColors.success : AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
