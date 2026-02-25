import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/hasil_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/duo_button.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});
  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  List<HasilModel> _hasilList = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    _hasilList = await DatabaseService().getHasilBySiswa(user.id);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    if (user == null) return const SizedBox();

    final totalBenar = _loading ? 0 : _hasilList.fold<int>(0, (s, h) => s + h.jawabanBenar);
    final totalSoal = _loading ? 0 : _hasilList.fold<int>(0, (s, h) => s + h.totalSoal);
    final lulusCount = _loading ? 0 : _hasilList.where((h) => h.lulus).length;
    final akurasi = totalSoal > 0 ? (totalBenar / totalSoal * 100).round() : 0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1CB0F6), Color(0xFF0099E0)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 56),
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  ),
                  child: const Center(child: Text('🧑‍🎓', style: TextStyle(fontSize: 46))),
                ),
                const SizedBox(height: 12),
                Text(user.nama, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('Kelas ${user.kelas ?? '-'} · No. Absen ${user.noAbsen ?? '-'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),

        // XP / Streak / Hearts card
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PillStat('⭐', '${user.xp} XP', 'Total XP'),
                  Container(width: 1, height: 40, color: DuoColors.border),
                  _PillStat('🔥', '${user.streak} hari', 'Streak'),
                  Container(width: 1, height: 40, color: DuoColors.border),
                  _PillStat('❤️', '${user.hearts}', 'Nyawa'),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Transform.translate(
                offset: const Offset(0, -10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistik Belajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DuoColors.textDark)),
                    const SizedBox(height: 12),
                    _StatRow('📝', 'Total Quiz Dikerjakan', '${_hasilList.length} quiz', DuoColors.blue),
                    _StatRow('✅', 'Total Soal Benar', '$totalBenar dari $totalSoal', DuoColors.green),
                    _StatRow('🏆', 'Quiz Lulus', '$lulusCount quiz', DuoColors.orange),
                    _StatRow('📈', 'Akurasi Rata-rata', '$akurasi%', const Color(0xCECE82FF)),
                    const SizedBox(height: 24),
                    DuoButton(
                      label: 'KELUAR',
                      color: DuoColors.red,
                      shadowColor: DuoColors.redDark,
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            content: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Text('👋', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              const Text('Keluar dari akun?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 20),
                              DuoButton(label: 'KELUAR', color: DuoColors.red, shadowColor: DuoColors.redDark, onTap: () => Navigator.pop(ctx, true)),
                              const SizedBox(height: 10),
                              DuoOutlineButton(label: 'BATAL', onTap: () => Navigator.pop(ctx, false)),
                            ]),
                            contentPadding: const EdgeInsets.all(24),
                          ),
                        );
                        if (ok == true && context.mounted) {
                          context.read<AuthProvider>().logout();
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PillStat extends StatelessWidget {
  final String icon, value, label;
  const _PillStat(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 24)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: DuoColors.textDark)),
    Text(label, style: const TextStyle(fontSize: 11, color: DuoColors.textGrey, fontWeight: FontWeight.w700)),
  ]);
}

class _StatRow extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatRow(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: DuoColors.border, width: 2),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: DuoColors.textGrey, fontWeight: FontWeight.w700)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
      ])),
    ]),
  );
}
