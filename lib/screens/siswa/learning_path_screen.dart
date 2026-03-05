import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_model.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import 'quiz_screen.dart';

// ─────────────────────────────────────────────────────────────────
// Definisi unit & lesson — urutan ini menentukan unlock chain.
// Lesson pertama di setiap unit SELALU unlocked untuk siswa baru.
// ─────────────────────────────────────────────────────────────────
final List<UnitModel> kDefaultUnits = [
  UnitModel(
    id: 'u1',
    label: 'BAGIAN 1, UNIT 1',
    title: 'Operasi Dasar Bilangan',
    colorValue: 0xFF58CC02,
    lessons: [
      LessonModel(
          id: 'l1',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'mudah',
          topik: 'Perkalian & Pembagian'),
      LessonModel(
          id: 'l2',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'sedang',
          topik: 'FPB & KPK'),
      LessonModel(
          id: 'l3',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'sulit',
          topik: 'Operasi Campuran'),
      LessonModel(
          id: 'l4',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'mudah',
          topik: 'Ringkasan Materi'),
    ],
  ),
  UnitModel(
    id: 'u2',
    label: 'BAGIAN 1, UNIT 2',
    title: 'Pecahan dan Desimal',
    colorValue: 0xFF58CC02,
    lessons: [
      LessonModel(
          id: 'l5',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'mudah',
          topik: 'Mengenal Pecahan'),
      LessonModel(
          id: 'l6',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'sedang',
          topik: 'Pecahan & Desimal'),
      LessonModel(
          id: 'l7',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'sulit',
          topik: 'Operasi Pecahan'),
      LessonModel(
          id: 'l8',
          type: LessonType.locked,
          mapel: 'Matematika',
          tingkat: 'sulit',
          topik: 'Tantangan Pecahan'),
    ],
  ),
  UnitModel(
    id: 'u3',
    label: 'BAGIAN 1, UNIT 3',
    title: 'Tumbuhan dan Hewan',
    colorValue: 0xCECE82FF,
    lessons: [
      LessonModel(
          id: 'l9',
          type: LessonType.locked,
          mapel: 'IPA',
          tingkat: 'mudah',
          topik: 'Bagian Tumbuhan'),
      LessonModel(
          id: 'l10',
          type: LessonType.locked,
          mapel: 'IPA',
          tingkat: 'mudah',
          topik: 'Perkembangbiakan Hewan'),
      LessonModel(
          id: 'l11',
          type: LessonType.locked,
          mapel: 'IPA',
          tingkat: 'sedang',
          topik: 'Fotosintesis'),
    ],
  ),
  UnitModel(
    id: 'u4',
    label: 'BAGIAN 2, UNIT 4',
    title: 'Indonesia dan Dunia',
    colorValue: 0xFFFF9600,
    lessons: [
      LessonModel(
          id: 'l12',
          type: LessonType.locked,
          mapel: 'IPS',
          tingkat: 'mudah',
          topik: 'Ibu Kota & Wilayah'),
      LessonModel(
          id: 'l13',
          type: LessonType.locked,
          mapel: 'IPS',
          tingkat: 'sedang',
          topik: 'Sejarah Indonesia'),
      LessonModel(
          id: 'l14',
          type: LessonType.locked,
          mapel: 'IPS',
          tingkat: 'sedang',
          topik: 'Tokoh Nasional'),
    ],
  ),
  UnitModel(
    id: 'u5',
    label: 'BAGIAN 2, UNIT 5',
    title: 'Membaca dan Menulis',
    colorValue: 0xFFFF4B4B,
    lessons: [
      LessonModel(
          id: 'l16',
          type: LessonType.locked,
          mapel: 'B.Indonesia',
          tingkat: 'mudah',
          topik: 'Sinonim & Antonim'),
      LessonModel(
          id: 'l17',
          type: LessonType.locked,
          mapel: 'B.Indonesia',
          tingkat: 'mudah',
          topik: 'Tanda Baca'),
      LessonModel(
          id: 'l18',
          type: LessonType.locked,
          mapel: 'B.Indonesia',
          tingkat: 'sulit',
          topik: 'Jenis Paragraf'),
    ],
  ),
];

// Skor minimum untuk unlock lesson berikutnya (80%)
const int kMinPassScore = 80;

const List<int> _zigzag = [1, 2, 1, 0, 1, 0, 1, 2];

// ─────────────────────────────────────────────────────────────────
// Helper: hitung type lesson berdasarkan progress
// ─────────────────────────────────────────────────────────────────
List<UnitModel> applyProgress(
    List<UnitModel> units, Map<String, LessonProgress> progress) {
  // Kumpulkan semua lesson secara flat dengan urutan
  final allLessons = units.expand((u) => u.lessons).toList();

  // Tentukan type tiap lesson
  final Map<String, LessonType> typeMap = {};
  for (int i = 0; i < allLessons.length; i++) {
    final lesson = allLessons[i];
    final prog = progress[lesson.id];

    if (prog != null && prog.selesai) {
      // Sudah lulus
      typeMap[lesson.id] = LessonType.done;
    } else if (i == 0) {
      // Lesson pertama selalu bisa diakses
      typeMap[lesson.id] = prog != null
          ? LessonType.current // pernah dicoba tapi belum lulus
          : LessonType.current;
    } else {
      // Cek apakah lesson sebelumnya sudah lulus
      final prevLesson = allLessons[i - 1];
      final prevProg = progress[prevLesson.id];
      final prevDone = prevProg != null && prevProg.selesai;

      if (prevDone) {
        typeMap[lesson.id] = prog != null
            ? LessonType.current // pernah dicoba
            : LessonType.current; // baru unlock
      } else {
        typeMap[lesson.id] = LessonType.locked;
      }
    }
  }

  // Rebuild units dengan type yang sudah dihitung
  return units.map((unit) {
    final newLessons = unit.lessons
        .map((l) => l.copyWith(type: typeMap[l.id] ?? LessonType.locked))
        .toList();

    final allDone = newLessons.every((l) => l.type == LessonType.done);
    final anyActive = newLessons
        .any((l) => l.type == LessonType.current || l.type == LessonType.done);

    return unit.copyWith(
      done: allDone,
      current: anyActive && !allDone,
      lessons: newLessons,
    );
  }).toList();
}

// ─────────────────────────────────────────────────────────────────

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final _db = DatabaseService();
  List<UnitModel> _units = kDefaultUnits;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final progressList = await _db.getLessonProgress(user.id);

    final progressMap = {
      for (var p in progressList) p.lessonId: p,
    };

    setState(() {
      _units = applyProgress(kDefaultUnits, progressMap);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: DuoColors.green));
    }

    return RefreshIndicator(
      onRefresh: _loadProgress,
      color: DuoColors.green,
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _units.length) return null;
                final unit = _units[index];
                return _UnitSection(
                  unit: unit,
                  unitIndex: index,
                  onStartLesson: (lesson) async {
                    if (user == null) return;
                    // Push ke quiz lalu refresh progress setelah kembali
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            kelas: user.kelas ?? '5',
                            mapel: lesson.mapel,
                            tingkat: lesson.tingkat,
                            siswaId: user.id,
                            siswaNama: user.nama,
                            lessonId: lesson.id, // ← untuk simpan progress
                            minPassScore: kMinPassScore,
                          ),
                        ));
                    // Refresh setelah kembali dari quiz
                    _loadProgress();
                  },
                );
              },
              childCount: _units.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _UnitSection extends StatelessWidget {
  final UnitModel unit;
  final int unitIndex;
  final void Function(LessonModel lesson) onStartLesson;

  const _UnitSection({
    required this.unit,
    required this.unitIndex,
    required this.onStartLesson,
  });

  Color get _unitColor => Color(unit.colorValue);
  Color get _unitColorDim =>
      unit.done || unit.current ? _unitColor : const Color(0xFFAFAFAF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Unit header ──
        Container(
          margin: const EdgeInsets.fromLTRB(14, 20, 14, 20),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _unitColorDim,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _unitColorDim.withOpacity(0.45),
                offset: const Offset(0, 4),
                blurRadius: 0,
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('← ${unit.label}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(unit.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.2)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _UnitPanduan(color: _unitColorDim),
            ],
          ),
        ),

        // ── Lesson nodes ──
        _LessonNodesSection(
          lessons: unit.lessons,
          unitColor: _unitColorDim,
          onStartLesson: onStartLesson,
        ),

        // ── Chest / Trophy ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _ChestNode(unlocked: unit.done),
        ),
        if (unitIndex % 2 == 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TrophyNode(unlocked: false),
          ),
      ],
    );
  }
}

class _LessonNodesSection extends StatelessWidget {
  final List<LessonModel> lessons;
  final Color unitColor;
  final void Function(LessonModel) onStartLesson;

  const _LessonNodesSection({
    required this.lessons,
    required this.unitColor,
    required this.onStartLesson,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VerticalLinePainter(color: unitColor.withOpacity(0.15)),
      child: Column(
        children: lessons.asMap().entries.map((e) {
          final idx = e.key;
          final lesson = e.value;
          final pos = _zigzag[idx % _zigzag.length];
          return Padding(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: pos == 2 ? 100.0 : 0.0,
              right: pos == 0 ? 100.0 : 0.0,
            ),
            child: Align(
              alignment: pos == 0
                  ? Alignment.centerLeft
                  : pos == 2
                      ? Alignment.centerRight
                      : Alignment.center,
              child: _LessonNode(
                lesson: lesson,
                unitColor: unitColor,
                onTap: () {
                  if (lesson.type == LessonType.locked) return;
                  onStartLesson(lesson);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _VerticalLinePainter extends CustomPainter {
  final Color color;
  const _VerticalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_VerticalLinePainter old) => old.color != color;
}

class _LessonNode extends StatefulWidget {
  final LessonModel lesson;
  final Color unitColor;
  final VoidCallback onTap;

  const _LessonNode(
      {required this.lesson, required this.unitColor, required this.onTap});

  @override
  State<_LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<_LessonNode>
    with SingleTickerProviderStateMixin {
  bool _showTooltip = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get isCurrent => widget.lesson.type == LessonType.current;
  bool get isLocked => widget.lesson.type == LessonType.locked;
  bool get isDone => widget.lesson.type == LessonType.done;
  double get _size => isCurrent ? 72 : 60;

  Color get _bgColor => isLocked ? const Color(0xFFE5E5E5) : widget.unitColor;
  Color get _shadowColor =>
      isLocked ? const Color(0xFFBDBDBD) : widget.unitColor.withOpacity(0.7);

  String get _icon {
    switch (widget.lesson.type) {
      case LessonType.done:
        return '✓';
      case LessonType.current:
        return '⭐';
      case LessonType.book:
        return '📖';
      case LessonType.locked:
        return '🔒';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          // Tunjukkan pesan kenapa terkunci
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  '🔒 Selesaikan lesson sebelumnya dengan skor ≥ 80% dulu!'),
              backgroundColor: DuoColors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          return;
        }
        if (isCurrent) setState(() => _showTooltip = !_showTooltip);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: isCurrent ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (isCurrent)
              Container(
                width: _size + 16,
                height: _size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.unitColor.withOpacity(0.4), width: 3),
                ),
              ),
            Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                color: _bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _shadowColor,
                      offset: const Offset(0, 5),
                      blurRadius: 0)
                ],
                border: isCurrent
                    ? Border.all(color: Colors.white.withOpacity(0.5), width: 4)
                    : null,
              ),
              child: Center(
                child: Text(_icon,
                    style: TextStyle(fontSize: isCurrent ? 28 : 22)),
              ),
            ),
            if (_showTooltip && isCurrent)
              Positioned(
                bottom: _size + 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: DuoColors.border, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.lesson.topik.isNotEmpty
                            ? widget.lesson.topik
                            : 'MULAI',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: DuoColors.textDark),
                      ),
                      Text(
                        _tingkatLabel(widget.lesson.tingkat),
                        style: TextStyle(
                            fontSize: 11,
                            color: _tingkatColor(widget.lesson.tingkat),
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Min. 80% untuk lanjut →',
                        style: TextStyle(
                            fontSize: 10,
                            color: DuoColors.textGrey,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _tingkatLabel(String t) {
    switch (t) {
      case 'mudah':
        return '🟢 Mudah';
      case 'sedang':
        return '🟡 Sedang';
      case 'sulit':
        return '🔴 Sulit';
      default:
        return t;
    }
  }

  Color _tingkatColor(String t) {
    switch (t) {
      case 'mudah':
        return const Color(0xFF2E7D32);
      case 'sulit':
        return DuoColors.red;
      default:
        return DuoColors.orange;
    }
  }
}

class _ChestNode extends StatelessWidget {
  final bool unlocked;
  const _ChestNode({required this.unlocked});
  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFFFFE066) : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: unlocked
                    ? const Color(0xFFCCAA00)
                    : const Color(0xFFBDBDBD),
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
            child: Text(unlocked ? '🎁' : '📦',
                style: const TextStyle(fontSize: 34))),
      );
}

class _TrophyNode extends StatelessWidget {
  final bool unlocked;
  const _TrophyNode({required this.unlocked});
  @override
  Widget build(BuildContext context) => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFFFF9600) : const Color(0xFFE5E5E5),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: unlocked
                    ? const Color(0xFFCC7700)
                    : const Color(0xFFBDBDBD),
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
            child: Text(unlocked ? '🏆' : '🏅',
                style: const TextStyle(fontSize: 28))),
      );
}

class _UnitPanduan extends StatelessWidget {
  final Color color;
  const _UnitPanduan({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📋', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            Text('PANDUAN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)),
          ],
        ),
      );
}
