import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../database/schedule_model.dart';
import '../../database/user_model.dart';
import '../../utils/constants.dart';

class DayDetailPage extends StatefulWidget {
  final String day;
  const DayDetailPage({super.key, required this.day});

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  List<Schedule> _schedules = [];
  List<User> _allStudents = [];
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
      final scheds = await DatabaseHelper.instance.getSchedulesByDay(widget.day);
      final students = await DatabaseHelper.instance.getAllStudents();
      setState(() {
          _schedules = scheds;
          _allStudents = students;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Jadwal ${widget.day}"),
        ),
        body: Column(
            children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: _schedules.length,
                        itemBuilder: (context, index) {
                            final item = _schedules[index];
                            return ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(item.userName ?? 'Siswa'),
                            );
                        },
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text("Kelola Jadwal (Advanced)"),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        onPressed: () {
                             _showManageDialog(context);
                        },
                    ),
                  ),
                )
            ],
        ),
    );
  }

  void _showManageDialog(BuildContext context) {
      // sederhananya: pilih siswa yang mau dipindahin ke hari ini
      User? selectedStudent;
      showDialog(
          context: context,
          builder: (context) {
              return StatefulBuilder(
                  builder: (context, setState) {
                      return AlertDialog(
                          title: Text("Tambah Siswa ke ${widget.day}"),
                          content: DropdownButton<User>(
                              isExpanded: true,
                              hint: const Text("Pilih Siswa"),
                              value: selectedStudent,
                              onChanged: (val) {
                                  setState(() {
                                      selectedStudent = val;
                                  });
                              },
                              items: _allStudents.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text("${s.name} (${s.nipd})"),
                              )).toList(),
                          ),
                          actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                              ElevatedButton(onPressed: () async {
                                  if (selectedStudent != null) {
                                      await DatabaseHelper.instance.updateStudentSchedule(selectedStudent!.id!, widget.day);
                                      if (mounted) {
                                          Navigator.pop(context);
                                          _loadData();
                                      }
                                  }
                              }, child: const Text("Simpan")),
                          ],
                      );
                  }
              );
          }
      );
  }
}
