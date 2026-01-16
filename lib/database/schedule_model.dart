class Schedule {
  final int? id;
  final String day; // hari piketnya: 'Senin', 'Selasa', dst.
  final int userId;
  final String? userName; // ini buat nampilin nama pas join query, jadi gampang

  Schedule({
    this.id,
    required this.day,
    required this.userId,
    this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'user_id': userId,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'],
      day: map['day'],
      userId: map['user_id'],
      userName: map['user_name'], // Helper column from joins
    );
  }
}
