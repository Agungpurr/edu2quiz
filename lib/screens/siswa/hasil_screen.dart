import 'package:flutter/material.dart';
import '../../models/hasil_model.dart';
import '../../models/soal_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/duo_button.dart';

class HasilScreen extends StatefulWidget {
  final HasilModel hasil;
  final AturanModel aturan;
  final int xpEarned;
  final bool gameOver; // hati habis sebelum soal selesai
  final bool timeUp; // waktu habis

  final bool lulus;
  final int minPassScore;

  const HasilScreen({
    super.key,
    required this.hasil,
    required this.aturan,
    this.xpEarned = 0,
    this.gameOver = false,
    this.timeUp = false,
    this.lulus = false,
    this.minPassScore = 80,
  });

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _popAnim;
  bool _showDetail = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _popAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _lulus => widget.lulus;

  // Tentukan mood banner berdasarkan kondisi
  _BannerMood get _mood {
    if (widget.gameOver) return _BannerMood.gameOver;
    if (widget.timeUp) return _BannerMood.timeUp;
    if (_lulus) return _BannerMood.lulus;
    return _BannerMood.gagal;
  }

  @override
  Widget build(BuildContext context) {
    final hasil = widget.hasil;
    final dur = '${hasil.durasiDetik ~/ 60}m ${hasil.durasiDetik % 60}s';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero banner ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _popAnim,
                    child: Text(_emoji, style: const TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),

                  // Khusus game over: tampilkan sisa soal yang belum terjawab
                  if (widget.gameOver) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Terjawab: ${hasil.detailJawaban.where((d) => d.jawabanSiswa != "Tidak dijawab").length}/${hasil.totalSoal} soal',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Score circle ──
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentColor, width: 5),
                  boxShadow: [
                    BoxShadow(
                        color: _accentColor.withOpacity(0.3), blurRadius: 20)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.gameOver
                          ? '💀'
                          : '${hasil.persentase.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: widget.gameOver ? 36 : 26,
                          fontWeight: FontWeight.w900,
                          color: widget.gameOver
                              ? DuoColors.red
                              : AppTheme.gradeColor(hasil.grade),
                          height: 1.1),
                    ),
                    if (!widget.gameOver)
                      Text(
                        hasil.grade,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.gradeColor(hasil.grade)),
                      ),
                  ],
                ),
              ),
            ),

            // ── Stats grid ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  Transform.translate(
                    offset: const Offset(0, -30),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _StatCard('⭐', '${widget.xpEarned} XP', 'XP Didapat',
                            const Color(0xFFFFF4E0), DuoColors.orange),
                        _StatCard(
                            '✅',
                            '${hasil.jawabanBenar}/${hasil.totalSoal}',
                            'Benar',
                            DuoColors.greenLight,
                            DuoColors.green),
                        _StatCard('⏱', dur, 'Waktu', const Color(0xFFE0F5FF),
                            DuoColors.blue),
                        // Tampilkan hati tersisa yang sebenarnya dari quiz
                        _StatCard(
                            '❤️',
                            widget.gameOver
                                ? '0 nyawa'
                                : '${(4 - (hasil.totalSoal - hasil.jawabanBenar).clamp(0, 4))} nyawa',
                            'Tersisa',
                            DuoColors.redLight,
                            DuoColors.red),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      children: [
                        // Pesan khusus game over
                        if (widget.gameOver) ...[
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: DuoColors.redLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: DuoColors.red.withOpacity(0.4),
                                  width: 1.5),
                            ),
                            child: Row(
                              children: const [
                                Text('💡', style: TextStyle(fontSize: 20)),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tips: Jawab benar 2× berturut untuk +1 hati, dan 5× berturut untuk full hati!',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: DuoColors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Detail toggle
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showDetail = !_showDetail),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: DuoColors.border, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📝 ',
                                    style: TextStyle(fontSize: 16)),
                                const Text('Lihat Pembahasan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: DuoColors.textGrey)),
                                const SizedBox(width: 6),
                                Icon(
                                    _showDetail
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: DuoColors.textGrey),
                              ],
                            ),
                          ),
                        ),

                        if (_showDetail) ...[
                          const SizedBox(height: 12),
                          ...hasil.detailJawaban.asMap().entries.map((e) =>
                              _DetailCard(index: e.key, detail: e.value)),
                        ],

                        const SizedBox(height: 20),

                        // Tombol: coba lagi jika game over, lanjut jika lulus
                        if (widget.gameOver)
                          Column(
                            children: [
                              DuoButton(
                                label: 'COBA LAGI 🔄',
                                onTap: () => Navigator.pop(context),
                                color: DuoColors.green,
                                shadowColor: DuoColors.greenDark,
                              ),
                              const SizedBox(height: 10),
                              DuoOutlineButton(
                                label: 'KEMBALI KE MENU',
                                onTap: () => Navigator.of(context)
                                    .popUntil((r) => r.isFirst),
                              ),
                            ],
                          )
                        else
                          DuoButton(
                            label: 'LANJUTKAN →',
                            onTap: () => Navigator.of(context)
                                .popUntil((r) => r.isFirst),
                            color: DuoColors.green,
                            shadowColor: DuoColors.greenDark,
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper getters berdasarkan mood ──

  List<Color> get _gradientColors {
    switch (_mood) {
      case _BannerMood.gameOver:
        return [const Color(0xFF4A0000), const Color(0xFF8B0000)];
      case _BannerMood.timeUp:
        return [const Color(0xFF4A3000), DuoColors.orange];
      case _BannerMood.lulus:
        return [const Color(0xFF1B5E20), const Color(0xFF58CC02)];
      case _BannerMood.gagal:
        return [const Color(0xFFB71C1C), DuoColors.red];
    }
  }

  Color get _accentColor {
    switch (_mood) {
      case _BannerMood.gameOver:
        return DuoColors.red;
      case _BannerMood.timeUp:
        return DuoColors.orange;
      case _BannerMood.lulus:
        return DuoColors.green;
      case _BannerMood.gagal:
        return DuoColors.red;
    }
  }

  String get _emoji {
    switch (_mood) {
      case _BannerMood.gameOver:
        return '💀';
      case _BannerMood.timeUp:
        return '⏰';
      case _BannerMood.lulus:
        return '🏆';
      case _BannerMood.gagal:
        return '💪';
    }
  }

  String get _title {
    switch (_mood) {
      case _BannerMood.gameOver:
        return 'HATI HABIS!';
      case _BannerMood.timeUp:
        return 'WAKTU HABIS!';
      case _BannerMood.lulus:
        return 'UNIT SELESAI!';
      case _BannerMood.gagal:
        return 'TETAP SEMANGAT!';
    }
  }

  String get _subtitle {
    switch (_mood) {
      case _BannerMood.gameOver:
        return 'Jangan menyerah! Coba lagi dan kumpulkan hati 💪';
      case _BannerMood.timeUp:
        return 'Waktu habis! Latih kecepatanmu ⚡';
      case _BannerMood.lulus:
        return 'Lesson selesai! Lesson berikutnya terbuka! 🎉';
      case _BannerMood.gagal:
        return 'Butuh ${widget.minPassScore}% untuk lanjut. Coba lagi! 💪';
    }
  }
}

enum _BannerMood { gameOver, timeUp, lulus, gagal }

// ── Subwidgets ───────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color bg, textColor;
  const _StatCard(this.emoji, this.value, this.label, this.bg, this.textColor);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: textColor.withOpacity(0.2), width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: textColor)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: DuoColors.textGrey,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

class _DetailCard extends StatelessWidget {
  final int index;
  final DetailJawaban detail;
  const _DetailCard({required this.index, required this.detail});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: detail.benar ? DuoColors.greenLight : DuoColors.redLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: (detail.benar ? DuoColors.green : DuoColors.red)
                  .withOpacity(0.3),
              width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(detail.benar ? '✅ ' : '❌ ',
                  style: const TextStyle(fontSize: 16)),
              Expanded(
                  child: Text('${index + 1}. ${detail.pertanyaan}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: DuoColors.textDark))),
            ]),
            const SizedBox(height: 6),
            Text('Jawabanmu: ${detail.jawabanSiswa}',
                style: TextStyle(
                    color:
                        detail.benar ? const Color(0xFF2B7A00) : DuoColors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
            if (!detail.benar)
              Text('✓ Jawaban benar: ${detail.jawabanBenar}',
                  style: const TextStyle(
                      color: Color(0xFF2B7A00),
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            // Soal tidak dijawab (game over)
            if (detail.jawabanSiswa == 'Tidak dijawab')
              const Text('⚠️ Tidak sempat dijawab',
                  style: TextStyle(
                      color: DuoColors.orange,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
          ],
        ),
      );
}
