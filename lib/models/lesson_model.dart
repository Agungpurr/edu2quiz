enum LessonType { done, current, book, locked, chest, trophy }

class LessonModel {
  final String id;
  final LessonType type;
  final String mapel;

  const LessonModel({required this.id, required this.type, required this.mapel});
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
}
