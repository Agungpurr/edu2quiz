// models/lesson_model.dart

enum LessonType { done, current, locked, book }

class LessonModel {
  final String id;
  final LessonType type;
  final String mapel;
  final String tingkat;
  final String topik;

  const LessonModel({
    required this.id,
    required this.type,
    required this.mapel,
    this.tingkat = 'sedang',
    this.topik = '',
  });

  // Buat copy dengan type berbeda (untuk dynamic unlock)
  LessonModel copyWith({LessonType? type}) => LessonModel(
        id: id,
        type: type ?? this.type,
        mapel: mapel,
        tingkat: tingkat,
        topik: topik,
      );
}

class UnitModel {
  final String id;
  final String label;
  final String title;
  final int colorValue;
  final bool done;
  final bool current;
  final List<LessonModel> lessons;

  const UnitModel({
    required this.id,
    required this.label,
    required this.title,
    required this.colorValue,
    this.done = false,
    this.current = false,
    required this.lessons,
  });

  UnitModel copyWith({
    bool? done,
    bool? current,
    List<LessonModel>? lessons,
  }) =>
      UnitModel(
        id: id,
        label: label,
        title: title,
        colorValue: colorValue,
        done: done ?? this.done,
        current: current ?? this.current,
        lessons: lessons ?? this.lessons,
      );
}

// ── Progress model ────────────────────────────────────────────────
// Disimpan ke tabel 'lesson_progress' di SQLite
class LessonProgress {
  final String siswaId;
  final String lessonId;
  final bool selesai; // true jika skor >= minPass
  final int skorTertinggi; // 0–100
  final DateTime updatedAt;

  const LessonProgress({
    required this.siswaId,
    required this.lessonId,
    required this.selesai,
    required this.skorTertinggi,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'siswa_id': siswaId,
        'lesson_id': lessonId,
        'selesai': selesai ? 1 : 0,
        'skor_tertinggi': skorTertinggi,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory LessonProgress.fromMap(Map<String, dynamic> map) => LessonProgress(
        siswaId: map['siswa_id'],
        lessonId: map['lesson_id'],
        selesai: map['selesai'] == 1,
        skorTertinggi: map['skor_tertinggi'],
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      );
}
