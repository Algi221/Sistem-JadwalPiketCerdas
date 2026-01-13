class Report {
  final int? id;
  final String date;
  final int reporterId;
  final String imagePath;
  final String createdAt;

  Report({
    this.id,
    required this.date,
    required this.reporterId,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'reporter_id': reporterId,
      'image_path': imagePath,
      'created_at': createdAt,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      date: map['date'],
      reporterId: map['reporter_id'],
      imagePath: map['image_path'],
      createdAt: map['created_at'],
    );
  }
}

class ReportDetail {
  final int? id;
  final int reportId;
  final int studentId;
  final int isPresent; // 1 = hadir, 0 = gak hadir

  ReportDetail({
    this.id,
    required this.reportId,
    required this.studentId,
    required this.isPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'student_id': studentId,
      'is_present': isPresent,
    };
  }
}
