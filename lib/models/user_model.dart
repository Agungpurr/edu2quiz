class UserModel {
  final String id;
  final String nama;
  final String username;
  final String password;
  final String role;
  final String? kelas;
  final String? noAbsen;
  final int xp;
  final int streak;
  final int hearts;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.role,
    this.kelas,
    this.noAbsen,
    this.xp = 0,
    this.streak = 0,
    this.hearts = 4,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'nama': nama, 'username': username, 'password': password,
    'role': role, 'kelas': kelas, 'no_absen': noAbsen,
    'xp': xp, 'streak': streak, 'hearts': hearts,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'], nama: map['nama'], username: map['username'],
    password: map['password'], role: map['role'], kelas: map['kelas'],
    noAbsen: map['no_absen'], xp: map['xp'] ?? 0,
    streak: map['streak'] ?? 0, hearts: map['hearts'] ?? 4,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
  );

  UserModel copyWith({
    String? nama, String? username, String? password,
    String? kelas, String? noAbsen, int? xp, int? streak, int? hearts,
  }) => UserModel(
    id: id, nama: nama ?? this.nama, username: username ?? this.username,
    password: password ?? this.password, role: role,
    kelas: kelas ?? this.kelas, noAbsen: noAbsen ?? this.noAbsen,
    xp: xp ?? this.xp, streak: streak ?? this.streak,
    hearts: hearts ?? this.hearts, createdAt: createdAt,
  );
}
