class User {
  final int? id;
  final String name;
  final String nipd;
  final String password;
  final String role; // bisa 'guru' atau 'siswa'

  User({
    this.id,
    required this.name,
    required this.nipd,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nipd': nipd,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      nipd: map['nipd'],
      password: map['password'],
      role: map['role'],
    );
  }
}
