import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/soal_model.dart';
import '../../models/hasil_model.dart';
import '../../models/lesson_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/duo_button.dart';
import 'hasil_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  final String kelas;
  final String mapel;
  final String tingkat;
  final String siswaId;
  final String siswaNama;
  final String lessonId; // untuk simpan progress
  final int minPassScore; // skor minimum lulus (default 80)

  const QuizScreen({
    super.key,
    required this.kelas,
    required this.mapel,
    required this.tingkat,
    required this.siswaId,
    required this.siswaNama,
    required this.lessonId,
    this.minPassScore = 80,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final _db = DatabaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SoalModel> _soalList = [];
  AturanModel? _aturan;
  bool _loading = true;
  String? _error;

  int _currentIdx = 0;
  int? _selected;
  bool _answered = false;
  final Map<int, int> _answers = {};

  int _timeLeft = 0, _totalTime = 0;

  // ── Heart system ──────────────────────────────────────────────
  int _hearts = 4;
  static const int _maxHearts = 4;
  int _consecutiveCorrect = 0;
  // Aturan:
  //   salah          → -1 hati, reset streak
  //   benar 2x berturut → +1 hati (maks 4)
  //   benar 5x berturut → full hati, reset streak
  // Game over hanya saat hati = 0
  // ─────────────────────────────────────────────────────────────

  int _xpEarned = 0;
  bool _finished = false;
  bool _gameOver = false;
  Timer? _timer;
  DateTime? _startTime;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  String? _heartNotif;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(_shakeCtrl);
    _playMusic();
    _loadQuiz();
  }

  Future<void> _playMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audio/quiz_music.mp3'));
    await _audioPlayer.setVolume(0.4);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      _aturan = await _db.getAturan(widget.kelas, widget.mapel);
      if (_aturan == null) {
        setState(() {
          _error = 'Aturan quiz belum diatur guru';
          _loading = false;
        });
        return;
      }

      var soal = await _db.getSoalForQuiz(
        widget.kelas,
        widget.mapel,
        _aturan!.jumlahSoal,
        _aturan!.acak,
        tingkat: widget.tingkat,
      );
      if (soal.isEmpty) {
        soal = await _db.getSoalForQuiz(
          widget.kelas,
          widget.mapel,
          _aturan!.jumlahSoal,
          _aturan!.acak,
        );
      }
      if (soal.isEmpty) {
        setState(() {
          _error = 'Belum ada soal untuk ${widget.mapel} Kelas ${widget.kelas}';
          _loading = false;
        });
        return;
      }

      setState(() {
        _soalList = soal;
        _timeLeft = _aturan!.durasiMenit * 60;
        _totalTime = _timeLeft;
        _loading = false;
        _startTime = DateTime.now();
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 0) {
        t.cancel();
        _finishQuiz(timeUp: true);
      } else
        setState(() => _timeLeft--);
    });
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    final soal = _soalList[_currentIdx];
    final isCorrect = idx == soal.jawabanBenar;

    setState(() {
      _selected = idx;
      _answered = true;
      _answers[_currentIdx] = idx;
    });

    if (isCorrect) {
      _consecutiveCorrect++;
      setState(() => _xpEarned += soal.poin);

      if (_consecutiveCorrect >= 5) {
        // 5 benar berturut → full hati
        setState(() {
          _hearts = _maxHearts;
          _heartNotif = 'FULL ❤️';
          _consecutiveCorrect = 0;
        });
        _clearNotif();
      } else if (_consecutiveCorrect % 2 == 0) {
        // Setiap 2 benar berturut → +1 hati
        if (_hearts < _maxHearts) {
          setState(() {
            _hearts = (_hearts + 1).clamp(0, _maxHearts);
            _heartNotif = '+1 ❤️';
          });
          _clearNotif();
        }
      }
    } else {
      // Salah: reset streak, kurangi hati
      _consecutiveCorrect = 0;
      _shakeCtrl.forward(from: 0);
      setState(() {
        _hearts = (_hearts - 1).clamp(0, _maxHearts);
        if (_hearts == 0) _gameOver = true;
      });
    }
  }

  void _clearNotif() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _heartNotif = null);
    });
  }

  void _next() {
    if (_gameOver) {
      _finishQuiz(gameOver: true);
      return;
    }
    if (_currentIdx < _soalList.length - 1) {
      setState(() {
        _currentIdx++;
        _selected = _answers[_currentIdx];
        _answered = _answers.containsKey(_currentIdx);
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz({bool gameOver = false, bool timeUp = false}) async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    final dur = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    int benar = 0, totalPoin = 0, maxPoin = 0;
    final detail = <DetailJawaban>[];
    for (int i = 0; i < _soalList.length; i++) {
      final s = _soalList[i];
      maxPoin += s.poin;
      final ja = _answers[i];
      final isB = ja == s.jawabanBenar;
      if (isB) {
        benar++;
        totalPoin += s.poin;
      }
      detail.add(DetailJawaban(
        soalId: s.id,
        pertanyaan: s.pertanyaan,
        jawabanSiswa: ja != null ? s.pilihan[ja] : 'Tidak dijawab',
        jawabanBenar: s.pilihan[s.jawabanBenar],
        benar: isB,
        poin: isB ? s.poin : 0,
      ));
    }

    final hasil = HasilModel(
      id: const Uuid().v4(),
      siswaId: widget.siswaId,
      siswaNama: widget.siswaNama,
      siswaKelas: widget.kelas,
      mapel: widget.mapel,
      totalSoal: _soalList.length,
      jawabanBenar: benar,
      totalPoin: totalPoin,
      maksimalPoin: maxPoin,
      durasiDetik: dur,
      detailJawaban: detail,
      selesaiAt: DateTime.now(),
    );
    await _db.saveHasil(hasil);

    // ── Simpan progress lesson ──────────────────────────────────
    final skor =
        _soalList.isEmpty ? 0 : (benar / _soalList.length * 100).round();
    final lulus = !gameOver && skor >= widget.minPassScore;
    await _db.saveLessonProgress(LessonProgress(
      siswaId: widget.siswaId,
      lessonId: widget.lessonId,
      selesai: lulus,
      skorTertinggi: skor,
      updatedAt: DateTime.now(),
    ));

    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HasilScreen(
              hasil: hasil,
              aturan: _aturan!,
              xpEarned: _xpEarned,
              gameOver: gameOver,
              timeUp: timeUp,
              lulus: lulus,
              minPassScore: widget.minPassScore,
            ),
          ));
    }
  }

  String get _timeStr {
    final m = _timeLeft ~/ 60;
    final s = _timeLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor => _timeLeft > 300
      ? DuoColors.green
      : _timeLeft > 60
          ? DuoColors.orange
          : DuoColors.red;

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: DuoColors.green)),
      );
    if (_error != null) return _ErrorState(message: _error!);

    final soal = _soalList[_currentIdx];
    final mapelColor = AppTheme.mapelColors[widget.mapel] ?? DuoColors.green;
    final progress = _answers.length / _soalList.length;

    return WillPopScope(
      onWillPop: () async => await _confirmExit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _QuizHeader(
                progress: progress,
                hearts: _hearts,
                maxHearts: _maxHearts,
                timeStr: _timeStr,
                timerColor: _timerColor,
                heartNotif: _heartNotif,
                consecutiveCorrect: _consecutiveCorrect,
                onExit: () async {
                  if (await _confirmExit()) Navigator.pop(context);
                },
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SingleChildScrollView(
                    key: ValueKey(_currentIdx),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: mapelColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: mapelColor.withOpacity(0.3),
                                    width: 1.5),
                              ),
                              child: Text(
                                  '${AppTheme.mapelEmoji[widget.mapel] ?? ''} ${widget.mapel}',
                                  style: TextStyle(
                                      color: mapelColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _tingkatColor(widget.tingkat)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _tingkatColor(widget.tingkat)
                                        .withOpacity(0.3),
                                    width: 1.5),
                              ),
                              child: Text(_tingkatLabel(widget.tingkat),
                                  style: TextStyle(
                                      color: _tingkatColor(widget.tingkat),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(soal.pertanyaan,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: DuoColors.textDark,
                                height: 1.4)),
                        const SizedBox(height: 28),
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(
                                _answered && _selected != soal.jawabanBenar
                                    ? ((_shakeAnim.value * 4 - 2) * 6)
                                    : 0,
                                0),
                            child: child,
                          ),
                          child: Column(
                            children: soal.pilihan
                                .asMap()
                                .entries
                                .map((e) => _AnswerCard(
                                      label: String.fromCharCode(65 + e.key),
                                      text: e.value,
                                      state: _answered
                                          ? (e.key == soal.jawabanBenar
                                              ? _CardState.correct
                                              : (_selected == e.key
                                                  ? _CardState.wrong
                                                  : _CardState.normal))
                                          : (_selected == e.key
                                              ? _CardState.selected
                                              : _CardState.normal),
                                      onTap: () => _selectAnswer(e.key),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _QuizBottom(
                answered: _answered,
                correct: _answered && _selected == soal.jawabanBenar,
                correctAnswer: soal.pilihan[soal.jawabanBenar],
                xp: soal.poin,
                isLast: _currentIdx == _soalList.length - 1,
                gameOver: _gameOver,
                onContinue: _answered ? _next : null,
              ),
            ],
          ),
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

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🚪', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          const Text('Berhenti belajar?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Kemajuanmu akan hilang jika keluar sekarang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: DuoColors.textGrey)),
          const SizedBox(height: 24),
          DuoButton(
              label: 'LANJUTKAN BELAJAR',
              onTap: () => Navigator.pop(ctx, false)),
          const SizedBox(height: 10),
          DuoOutlineButton(
              label: 'KELUAR', onTap: () => Navigator.pop(ctx, true)),
        ]),
        contentPadding: const EdgeInsets.all(24),
      ),
    );
    return result ?? false;
  }
}

// ── Header ──────────────────────────────────────────────────────

class _QuizHeader extends StatelessWidget {
  final double progress;
  final int hearts;
  final int maxHearts;
  final String timeStr;
  final Color timerColor;
  final String? heartNotif;
  final int consecutiveCorrect;
  final VoidCallback onExit;

  const _QuizHeader({
    required this.progress,
    required this.hearts,
    required this.maxHearts,
    required this.timeStr,
    required this.timerColor,
    required this.heartNotif,
    required this.consecutiveCorrect,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close,
                    color: DuoColors.textGrey, size: 26),
                onPressed: onExit,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    backgroundColor: DuoColors.border,
                    valueColor: const AlwaysStoppedAnimation(DuoColors.green),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(timeStr,
                    style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              // Hati dengan animasi
              Row(
                children: List.generate(
                    maxHearts,
                    (i) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              i < hearts ? '❤️' : '🤍',
                              key: ValueKey('$i-${i < hearts}'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        )),
              ),
              const SizedBox(width: 10),
              // Notif hati sementara
              if (heartNotif != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: DuoColors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DuoColors.green.withOpacity(0.4)),
                  ),
                  child: Text(heartNotif!,
                      style: const TextStyle(
                          color: DuoColors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 13)),
                ),
              const Spacer(),
              // Streak indikator
              if (consecutiveCorrect > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: DuoColors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$consecutiveCorrect berturut',
                          style: const TextStyle(
                              color: DuoColors.orange,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Answer cards ─────────────────────────────────────────────────

enum _CardState { normal, selected, correct, wrong }

class _AnswerCard extends StatefulWidget {
  final String label;
  final String text;
  final _CardState state;
  final VoidCallback onTap;
  const _AnswerCard(
      {required this.label,
      required this.text,
      required this.state,
      required this.onTap});
  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  bool _pressed = false;
  Color get _bg {
    switch (widget.state) {
      case _CardState.correct:
        return DuoColors.greenLight;
      case _CardState.wrong:
        return DuoColors.redLight;
      case _CardState.selected:
        return const Color(0xFFDDF4FF);
      default:
        return Colors.white;
    }
  }

  Color get _border {
    switch (widget.state) {
      case _CardState.correct:
        return DuoColors.green;
      case _CardState.wrong:
        return DuoColors.red;
      case _CardState.selected:
        return DuoColors.blue;
      default:
        return DuoColors.border;
    }
  }

  Color get _shadow {
    switch (widget.state) {
      case _CardState.correct:
        return DuoColors.greenDark;
      case _CardState.wrong:
        return DuoColors.redDark;
      case _CardState.selected:
        return DuoColors.blueDark;
      default:
        return DuoColors.border;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case _CardState.correct:
        return const Color(0xFF2B7A00);
      case _CardState.wrong:
        return const Color(0xFF7A0000);
      case _CardState.selected:
        return const Color(0xFF0B5E88);
      default:
        return DuoColors.textDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        widget.state == _CardState.correct || widget.state == _CardState.wrong;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 10),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 2),
          boxShadow: [
            BoxShadow(
                color: _shadow,
                offset: Offset(0, _pressed ? 0 : 3),
                blurRadius: 0)
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.state == _CardState.normal
                      ? const Color(0xFFF5F5F5)
                      : _border.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _border, width: 2),
                ),
                child: Center(
                    child: Text(
                  widget.state == _CardState.correct
                      ? '✓'
                      : widget.state == _CardState.wrong
                          ? '✗'
                          : widget.label,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _textColor,
                      fontSize: 14),
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(widget.text,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                          height: 1.4))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ───────────────────────────────────────────────────

class _QuizBottom extends StatelessWidget {
  final bool answered;
  final bool correct;
  final String correctAnswer;
  final int xp;
  final bool isLast;
  final bool gameOver;
  final VoidCallback? onContinue;

  const _QuizBottom({
    required this.answered,
    required this.correct,
    required this.correctAnswer,
    required this.xp,
    required this.isLast,
    required this.gameOver,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (answered) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: gameOver
                    ? const Color(0xFFFFE5E5)
                    : correct
                        ? DuoColors.greenLight
                        : DuoColors.redLight,
                borderRadius: BorderRadius.circular(14),
                border: gameOver
                    ? Border.all(color: DuoColors.red, width: 1.5)
                    : null,
              ),
              child: Row(
                children: [
                  Text(
                      gameOver
                          ? '💀'
                          : correct
                              ? '🎉'
                              : '💔',
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameOver
                                ? 'Hati kamu habis!'
                                : correct
                                    ? 'Mantap! Jawaban kamu benar!'
                                    : 'Jawaban yang benar:',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: gameOver
                                    ? DuoColors.red
                                    : correct
                                        ? const Color(0xFF2B7A00)
                                        : const Color(0xFF7A0000)),
                          ),
                          if (gameOver)
                            const Text('Quiz berakhir. Lihat hasil kamu!',
                                style: TextStyle(
                                    color: DuoColors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13))
                          else if (!correct)
                            Text(correctAnswer,
                                style: const TextStyle(
                                    color: DuoColors.red,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13))
                          else
                            Text('+$xp XP',
                                style: const TextStyle(
                                    color: DuoColors.green,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                        ]),
                  ),
                ],
              ),
            ),
          ],
          DuoButton(
            label: !answered
                ? 'PILIH JAWABAN'
                : gameOver
                    ? 'LIHAT HASIL →'
                    : isLast
                        ? 'SELESAI ✓'
                        : 'LANJUTKAN →',
            onTap: onContinue,
            color: !answered
                ? DuoColors.textGrey
                : gameOver
                    ? DuoColors.red
                    : correct
                        ? DuoColors.green
                        : DuoColors.red,
            shadowColor: !answered
                ? const Color(0xFF999999)
                : correct
                    ? DuoColors.greenDark
                    : DuoColors.redDark,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('😢', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DuoColors.textGrey)),
            const SizedBox(height: 24),
            DuoButton(label: 'KEMBALI', onTap: () => Navigator.pop(context)),
          ]),
        )),
      );
}
