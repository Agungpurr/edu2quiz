import 'package:flutter/material.dart';
import '../../models/hasil_model.dart';
import '../../models/soal_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/duo_button.dart';

class HasilScreen extends StatefulWidget {
  final HasilModel hasil;
  final AturanModel aturan;
  final int xpEarned;

  const HasilScreen({super.key, required this.hasil, required this.aturan, this.xpEarned = 0});

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _popAnim;
  bool _showDetail = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _popAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _lulus => widget.hasil.persentase >= 60;

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
                  colors: _lulus
                      ? [const Color(0xFF1B5E20), const Color(0xFF58CC02)]
                      : [const Color(0xFFB71C1C), DuoColors.red],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 48),
              child: Column(
                children: [
                  // Confetti emoji
                  ScaleTransition(
                    scale: _popAnim,
                    child: Text(_lulus ? '🏆' : '💪', style: const TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lulus ? 'UNIT SELESAI!' : 'TETAP SEMANGAT!',
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _lulus ? 'Kamu berhasil melewati unit ini! 🎉' : 'Coba lagi, kamu pasti bisa! 💪',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Score circle ──
            Transform.translate(
              offset: const Offset(0, -50),
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _lulus ? DuoColors.green : DuoColors.red, width: 5),
                  boxShadow: [
                    BoxShadow(color: (_lulus ? DuoColors.green : DuoColors.red).withOpacity(0.3), blurRadius: 20)
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${hasil.persentase.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.gradeColor(hasil.grade), height: 1.1)),
                    Text(hasil.grade,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.gradeColor(hasil.grade))),
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
                        _StatCard('⭐', '${widget.xpEarned} XP', 'XP Didapat', const Color(0xFFFFF4E0), DuoColors.orange),
                        _StatCard('✅', '${hasil.jawabanBenar}/${hasil.totalSoal}', 'Benar', DuoColors.greenLight, DuoColors.green),
                        _StatCard('⏱', dur, 'Waktu', const Color(0xFFE0F5FF), DuoColors.blue),
                        _StatCard('❤️', '${4 - (hasil.totalSoal - hasil.jawabanBenar).clamp(0, 4)} nyawa', 'Tersisa', DuoColors.redLight, DuoColors.red),
                      ],
                    ),
                  ),

                  // Detail toggle
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showDetail = !_showDetail),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: DuoColors.border, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('📝 ', style: TextStyle(fontSize: 16)),
                                const Text('Lihat Pembahasan', style: TextStyle(fontWeight: FontWeight.w800, color: DuoColors.textGrey)),
                                const SizedBox(width: 6),
                                Icon(_showDetail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: DuoColors.textGrey),
                              ],
                            ),
                          ),
                        ),

                        if (_showDetail) ...[
                          const SizedBox(height: 12),
                          ...hasil.detailJawaban.asMap().entries.map((e) => _DetailCard(index: e.key, detail: e.value)),
                        ],

                        const SizedBox(height: 20),
                        DuoButton(
                          label: 'LANJUTKAN →',
                          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
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
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color bg, textColor;
  const _StatCard(this.emoji, this.value, this.label, this.bg, this.textColor);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: textColor.withOpacity(0.2), width: 1.5)),
    child: Row(
      children: [
        const SizedBox(width: 14),
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textColor)),
          Text(label, style: const TextStyle(fontSize: 11, color: DuoColors.textGrey, fontWeight: FontWeight.w700)),
        ]),
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
      border: Border.all(color: (detail.benar ? DuoColors.green : DuoColors.red).withOpacity(0.3), width: 1.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(detail.benar ? '✅ ' : '❌ ', style: const TextStyle(fontSize: 16)),
        Expanded(child: Text('${index + 1}. ${detail.pertanyaan}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: DuoColors.textDark))),
      ]),
      const SizedBox(height: 6),
      Text('Jawabanmu: ${detail.jawabanSiswa}',
          style: TextStyle(color: detail.benar ? const Color(0xFF2B7A00) : DuoColors.red, fontWeight: FontWeight.w700, fontSize: 12)),
      if (!detail.benar)
        Text('✓ Jawaban benar: ${detail.jawabanBenar}',
            style: const TextStyle(color: Color(0xFF2B7A00), fontWeight: FontWeight.w800, fontSize: 12)),
    ]),
  );
}
