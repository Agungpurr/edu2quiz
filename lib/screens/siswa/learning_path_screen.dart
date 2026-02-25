import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_model.dart';
import '../../services/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'quiz_screen.dart';

// Static learning path data (in real app this comes from DB based on progress)
final List<UnitModel> kDefaultUnits = [
  UnitModel(
    id: 'u1',
    label: 'BAGIAN 1, UNIT 1',
    title: 'Operasi Dasar Bilangan',
    colorValue: 0xFF58CC02,
    done: true,
    lessons: [
      LessonModel(id: 'l1', type: LessonType.done, mapel: 'Matematika'),
      LessonModel(id: 'l2', type: LessonType.done, mapel: 'Matematika'),
      LessonModel(id: 'l3', type: LessonType.done, mapel: 'Matematika'),
      LessonModel(id: 'l4', type: LessonType.book, mapel: 'Matematika'),
    ],
  ),
  UnitModel(
    id: 'u2',
    label: 'BAGIAN 1, UNIT 2',
    title: 'Pecahan dan Desimal',
    colorValue: 0xFF58CC02,
    current: true,
    lessons: [
      LessonModel(id: 'l5', type: LessonType.done, mapel: 'Matematika'),
      LessonModel(id: 'l6', type: LessonType.current, mapel: 'Matematika'),
      LessonModel(id: 'l7', type: LessonType.locked, mapel: 'Matematika'),
      LessonModel(id: 'l8', type: LessonType.locked, mapel: 'Matematika'),
    ],
  ),
  UnitModel(
    id: 'u3',
    label: 'BAGIAN 1, UNIT 3',
    title: 'Tumbuhan dan Hewan',
    colorValue: 0xCECE82FF,
    lessons: [
      LessonModel(id: 'l9', type: LessonType.locked, mapel: 'IPA'),
      LessonModel(id: 'l10', type: LessonType.locked, mapel: 'IPA'),
      LessonModel(id: 'l11', type: LessonType.locked, mapel: 'IPA'),
    ],
  ),
  UnitModel(
    id: 'u4',
    label: 'BAGIAN 2, UNIT 4',
    title: 'Indonesia dan Dunia',
    colorValue: 0xFFFF9600,
    lessons: [
      LessonModel(id: 'l12', type: LessonType.locked, mapel: 'IPS'),
      LessonModel(id: 'l13', type: LessonType.locked, mapel: 'IPS'),
      LessonModel(id: 'l14', type: LessonType.locked, mapel: 'IPS'),
    ],
  ),
  UnitModel(
    id: 'u5',
    label: 'BAGIAN 2, UNIT 5',
    title: 'Membaca dan Menulis',
    colorValue: 0xFFFF4B4B,
    lessons: [
      LessonModel(id: 'l16', type: LessonType.locked, mapel: 'B.Indonesia'),
      LessonModel(id: 'l17', type: LessonType.locked, mapel: 'B.Indonesia'),
      LessonModel(id: 'l18', type: LessonType.locked, mapel: 'B.Indonesia'),
    ],
  ),
];

// Zigzag offsets  0=left, 1=center, 2=right
const List<int> _zigzag = [1, 2, 1, 0, 1, 0, 1, 2];

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= kDefaultUnits.length) return null;
              final unit = kDefaultUnits[index];
              return _UnitSection(
                unit: unit,
                unitIndex: index,
                onStartLesson: (mapel) {
                  if (user == null) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          kelas: user.kelas ?? '5',
                          mapel: mapel,
                          siswaId: user.id,
                          siswaNama: user.nama,
                        ),
                      ));
                },
              );
            },
            childCount: kDefaultUnits.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _UnitSection extends StatelessWidget {
  final UnitModel unit;
  final int unitIndex;
  final void Function(String mapel) onStartLesson;

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
        // ── Unit header banner ──
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
                    Text(
                      '← ${unit.label}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _UnitPanduan(color: _unitColorDim),
            ],
          ),
        ),

        // ── Lesson nodes ──
        // FIX: Use CustomPaint for the vertical guide line instead of
        // Positioned inside a Stack, so it doesn't need a fixed height.
        _LessonNodesSection(
          lessons: unit.lessons,
          unitColor: _unitColorDim,
          onStartLesson: onStartLesson,
        ),

        // ── Chest / Trophy between units ──
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
  final void Function(String mapel) onStartLesson;

  const _LessonNodesSection({
    required this.lessons,
    required this.unitColor,
    required this.onStartLesson,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // FIX: Draw the vertical guide line via CustomPaint so it doesn't
      // interfere with the layout of child widgets.
      painter: _VerticalLinePainter(color: unitColor.withOpacity(0.15)),
      child: Column(
        children: [
          ...lessons.asMap().entries.map((e) {
            final idx = e.key;
            final lesson = e.value;
            final pos =
                _zigzag[idx % _zigzag.length]; // 0=left,1=center,2=right

            // FIX: Use Align + padding instead of Transform.translate.
            // Transform.translate moves the widget visually but doesn't
            // affect layout, causing nodes to be clipped at screen edges.
            return Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                // Push center of the node toward left or right by adding
                // padding on the opposite side.
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
                    onStartLesson(lesson.mapel);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Draws a thin vertical line in the center of the widget area.
class _VerticalLinePainter extends CustomPainter {
  final Color color;
  const _VerticalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_VerticalLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _LessonNode extends StatefulWidget {
  final LessonModel lesson;
  final Color unitColor;
  final VoidCallback onTap;

  const _LessonNode({
    required this.lesson,
    required this.unitColor,
    required this.onTap,
  });

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
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get isCurrent => widget.lesson.type == LessonType.current;
  bool get isLocked => widget.lesson.type == LessonType.locked;

  double get _size => isCurrent ? 72 : 60;

  Color get _bgColor {
    if (isLocked) return const Color(0xFFE5E5E5);
    return widget.unitColor;
  }

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
      default:
        return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isLocked) return;
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
          // FIX: Use clipBehavior: Clip.none so the pulse ring and tooltip
          // (which are larger than the main node) are not clipped.
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Pulse ring (slightly larger than the node)
            if (isCurrent)
              Container(
                width: _size + 16,
                height: _size + 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.unitColor.withOpacity(0.4),
                    width: 3,
                  ),
                ),
              ),
            // Main circle
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
                    blurRadius: 0,
                  )
                ],
                border: isCurrent
                    ? Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 4,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  _icon,
                  style: TextStyle(fontSize: isCurrent ? 28 : 22),
                ),
              ),
            ),
            // "MULAI" tooltip shown above the node when tapped
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
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: DuoColors.border, width: 2),
                  ),
                  child: const Text(
                    'MULAI',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: DuoColors.textDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
              color:
                  unlocked ? const Color(0xFFCCAA00) : const Color(0xFFBDBDBD),
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            unlocked ? '🎁' : '📦',
            style: const TextStyle(fontSize: 34),
          ),
        ),
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
              color:
                  unlocked ? const Color(0xFFCC7700) : const Color(0xFFBDBDBD),
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            unlocked ? '🏆' : '🏅',
            style: const TextStyle(fontSize: 28),
          ),
        ),
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
            Text(
              'PANDUAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}
