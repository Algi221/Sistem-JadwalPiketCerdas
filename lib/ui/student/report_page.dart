import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/db_helper.dart';
import '../../data/report_model.dart';
import '../../data/schedule_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ReportPage extends StatefulWidget {
  final List<Schedule> todaysSchedules;

  const ReportPage({super.key, required this.todaysSchedules});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  File? _image;
  final picker = ImagePicker();
  // set siswa yang hadir. awalnya kosong dulu, nanti user yang pilih
  // "bisa select teman yang piket" maksudnya pilih yang hadir gitu
  final Set<int> _selectedIds = {}; 

  @override
  void initState() {
    super.initState();
    // defaultnya gak ada yang kepilih, user harus centang sendiri siapa yang hadir
    // atau auto-select semua terus user uncheck? tapi kayaknya lebih enak pilih manual deh
    // "select teman yang piket" -> pilih yang hadir aja
  }

  Future _getImage() async {
    // kasih pilihan mau pake kamera atau galeri
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('Pilih Sumber Foto', style: AppStyles.header.copyWith(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text('Kamera', style: AppStyles.header.copyWith(fontSize: 16)),
                subtitle: Text(
                  kIsWeb ? 'Buka webcam laptop' : 'Ambil foto langsung',
                  style: AppStyles.body.copyWith(fontSize: 13),
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                ),
                title: Text('Galeri', style: AppStyles.header.copyWith(fontSize: 16)),
                subtitle: Text(
                  kIsWeb ? 'Pilih file dari komputer' : 'Pilih dari galeri',
                  style: AppStyles.body.copyWith(fontSize: 13),
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppStyles.body.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        );
      },
    );

    if (source != null) {
      try {
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengambil foto: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _submitReport() async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (_image == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap sertakan foto bukti!")));
          return;
      }
      if (_selectedIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih siapa saja yang piket!")));
          return;
      }

      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      
      // 1. bikin report dulu nih
      final report = Report(
          date: dateStr, 
          reporterId: auth.currentUser!.id!, 
          imagePath: _image!.path, 
          createdAt: now.toIso8601String()
      );
      
      final reportId = await DatabaseHelper.instance.insertReport(report);

      // 2. bikin detail reportnya
      // loop semua siswa yang dijadwalin hari ini
      // kalau ada di _selectedIds -> hadir (1), kalau gak -> gak hadir (0)
      for (var schedule in widget.todaysSchedules) {
          await DatabaseHelper.instance.insertReportDetail(ReportDetail(
              reportId: reportId, 
              studentId: schedule.userId, 
              isPresent: _selectedIds.contains(schedule.userId) ? 1 : 0
          ));
      }

      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dikirim!")));
          Navigator.pop(context, true); // balik dengan status sukses
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Lapor Piket"), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    // bagian kamera
                    GestureDetector(
                        onTap: _getImage,
                        child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey),
                            ),
                            child: _image == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                                        Text("Ketuk untuk ambil foto"),
                                    ],
                                )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(_image!.path, fit: BoxFit.cover)
                                        : Image.file(_image!, fit: BoxFit.cover),
                                ),
                        ),
                    ),
                    const SizedBox(height: 24),
                    Text("Siapa yang piket hari ini?", style: AppStyles.header),
                    Text("Centang teman yang hadir/piket.", style: AppStyles.body),
                    const SizedBox(height: 12),
                    
                    // daftar siswa yang dijadwalin
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.todaysSchedules.length,
                        itemBuilder: (context, index) {
                            final item = widget.todaysSchedules[index];
                            final isMe = item.userId == Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
                            
                            return CheckboxListTile(
                                title: Text(item.userName ?? 'Siswa'),
                                subtitle: isMe ? const Text("(Saya)") : null,
                                value: _selectedIds.contains(item.userId),
                                onChanged: (val) {
                                    setState(() {
                                        if (val == true) {
                                            _selectedIds.add(item.userId);
                                        } else {
                                            _selectedIds.remove(item.userId);
                                        }
                                    });
                                },
                            );
                        },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("KIRIM LAPORAN", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                ],
            ),
        ),
    );
  }
}
