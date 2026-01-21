import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../database/db_helper.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser?.id != null) {
      final reports = await DatabaseHelper.instance.getStudentReports(auth.currentUser!.id!);
      setState(() {
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada riwayat laporan', style: AppStyles.header.copyWith(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Laporan yang Anda kirim akan muncul di sini', style: AppStyles.body),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                final isPresent = report['is_present'] == 1;
                final date = report['date'] ?? '';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: AppStyles.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // placeholder gambar buat web
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_rounded, size: 48, color: AppColors.primary.withOpacity(0.5)),
                              const SizedBox(height: 8),
                              Text(
                                'Foto Bukti Piket',
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
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.parse(date)),
                                  style: AppStyles.header.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPresent ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPresent ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPresent ? Icons.check_circle : Icons.cancel,
                                    size: 16,
                                    color: isPresent ? AppColors.success : AppColors.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isPresent ? 'Hadir' : 'Tidak Hadir',
                                    style: AppStyles.body.copyWith(
                                      color: isPresent ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
