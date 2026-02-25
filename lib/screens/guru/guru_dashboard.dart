import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/duo_button.dart';
import 'siswa_management_screen.dart';
import 'soal_management_screen.dart';
import 'aturan_screen.dart';
import 'hasil_guru_screen.dart';

class GuruDashboard extends StatefulWidget {
  const GuruDashboard({super.key});
  @override
  State<GuruDashboard> createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard> {
  int _totalSiswa = 0, _totalSoal = 0, _totalHasil = 0;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    final db = DatabaseService();
    final s = await db.getAllSiswa();
    final q = await db.getAllSoal();
    final h = await db.getAllHasil();
    if (mounted) setState(() { _totalSiswa=s.length; _totalSoal=q.length; _totalHasil=h.length; });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: DuoColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1CB0F6),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1CB0F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 2)),
                              child: const Center(child: Text('👨‍🏫', style: TextStyle(fontSize: 28))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selamat Datang,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(auth.currentUser?.nama ?? 'Guru', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                              ],
                            )),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: () => _confirmLogout(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Dashboard Guru', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                Row(
                  children: [
                    _StatCard('👨‍🎓', '$_totalSiswa', 'Siswa', const Color(0xFF58CC02)),
                    const SizedBox(width: 10),
                    _StatCard('📝', '$_totalSoal', 'Soal', const Color(0xFF1CB0F6)),
                    const SizedBox(width: 10),
                    _StatCard('📊', '$_totalHasil', 'Hasil', const Color(0xFFFF9600)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Menu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: DuoColors.textDark)),
                const SizedBox(height: 12),
                _MenuCard(emoji:'👨‍🎓', title:'Data Siswa', subtitle:'Tambah, edit, hapus akun siswa',
                  colors:[const Color(0xFF43A047), const Color(0xFF66BB6A)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaManagementScreen())).then((_) => _loadStats())),
                _MenuCard(emoji:'📝', title:'Bank Soal', subtitle:'Kelola soal quiz per kelas & mapel',
                  colors:[const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoalManagementScreen())).then((_) => _loadStats())),
                _MenuCard(emoji:'⚙️', title:'Aturan Quiz', subtitle:'Jumlah soal, durasi, nilai minimum',
                  colors:[const Color(0xFF8E24AA), const Color(0xFFAB47BC)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AturanScreen()))),
                _MenuCard(emoji:'📊', title:'Hasil Siswa', subtitle:'Lihat nilai & download PDF laporan',
                  colors:[const Color(0xFFF4511E), const Color(0xFFFF7043)],
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HasilGuruScreen()))),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('👋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Keluar dari akun?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          DuoButton(label: 'KELUAR', color: DuoColors.red, shadowColor: DuoColors.redDark, onTap: () { Navigator.pop(ctx); context.read<AuthProvider>().logout(); }),
          const SizedBox(height: 10),
          DuoOutlineButton(label: 'BATAL', onTap: () => Navigator.pop(ctx)),
        ]),
        contentPadding: const EdgeInsets.all(24),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _StatCard(this.emoji, this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: DuoColors.border, width: 2)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: DuoColors.textGrey, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

class _MenuCard extends StatefulWidget {
  final String emoji, title, subtitle;
  final List<Color> colors;
  final VoidCallback onTap;
  const _MenuCard({required this.emoji, required this.title, required this.subtitle, required this.colors, required this.onTap});
  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _pressed = true),
    onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
    onTapCancel: () => setState(() => _pressed = false),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      margin: const EdgeInsets.only(bottom: 12),
      transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.colors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _pressed ? [] : [BoxShadow(color: widget.colors[0].withOpacity(0.5), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            Text(widget.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white70),
        ]),
      ),
    ),
  );
}
