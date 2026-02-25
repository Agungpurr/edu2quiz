import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/hasil_model.dart';
import '../../services/auth_provider.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});
  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  List<HasilModel> _hasilList = [];
  bool _loading = true;
  String _filterMapel = 'Semua';
  Set<String> _expanded = {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    setState(() => _loading = true);
    _hasilList = await DatabaseService().getHasilBySiswa(user.id);
    setState(() => _loading = false);
  }

  List<HasilModel> get _filtered =>
      _filterMapel == 'Semua' ? _hasilList : _hasilList.where((h) => h.mapel == _filterMapel).toList();

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final lulus = list.where((h) => h.lulus).length;
    final avg = list.isEmpty ? 0 : (list.map((h) => h.persentase).reduce((a, b) => a + b) / list.length).round();

    return RefreshIndicator(
      onRefresh: _load,
      color: DuoColors.green,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              color: DuoColors.green,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Riwayat Quiz 📊', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Semua quiz yang pernah dikerjakan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),

          // Stats strip
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  _StatStrip('📝', '${list.length}', 'Total'),
                  _divider,
                  _StatStrip('✅', '$lulus', 'Lulus'),
                  _divider,
                  _StatStrip('📈', '$avg%', 'Rata-rata'),
                ],
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Matematika', 'IPA', 'IPS', 'B.Indonesia'].map((m) {
                    final active = m == _filterMapel;
                    final color = m == 'Semua' ? const Color(0xFF533483) : (AppTheme.mapelColors[m] ?? DuoColors.green);
                    return GestureDetector(
                      onTap: () => setState(() => _filterMapel = m),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m, style: TextStyle(color: active ? Colors.white : color, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // List
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: DuoColors.green)))
          else if (list.isEmpty)
            const SliverFillRemaining(child: _EmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _RiwayatCard(
                    hasil: list[i],
                    expanded: _expanded.contains(list[i].id),
                    onToggle: () => setState(() {
                      if (_expanded.contains(list[i].id)) _expanded.remove(list[i].id);
                      else _expanded.add(list[i].id);
                    }),
                  ),
                  childCount: list.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _divider => Container(width: 1, height: 40, color: DuoColors.border);
}

class _StatStrip extends StatelessWidget {
  final String icon, value, label;
  const _StatStrip(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: DuoColors.textDark)),
      Text(label, style: const TextStyle(fontSize: 11, color: DuoColors.textGrey, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _RiwayatCard extends StatelessWidget {
  final HasilModel hasil;
  final bool expanded;
  final VoidCallback onToggle;
  const _RiwayatCard({required this.hasil, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppTheme.gradeColor(hasil.grade);
    final mapelColor = AppTheme.mapelColors[hasil.mapel] ?? DuoColors.green;
    final mapelEmoji = AppTheme.mapelEmoji[hasil.mapel] ?? '📚';
    final dateStr = DateFormat('dd MMM yyyy · HH:mm').format(hasil.selesaiAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DuoColors.border, width: 2),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Grade circle
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: gradeColor,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: gradeColor.withOpacity(0.5), offset: const Offset(0, 4), blurRadius: 0)],
                    ),
                    child: Center(child: Text(hasil.grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$mapelEmoji ${hasil.mapel}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hasil.persentase / 100, minHeight: 8,
                          backgroundColor: DuoColors.border,
                          valueColor: AlwaysStoppedAnimation(gradeColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${hasil.jawabanBenar}/${hasil.totalSoal} benar · ${hasil.persentase.toStringAsFixed(0)}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: gradeColor)),
                          Text(dateStr, style: const TextStyle(fontSize: 10, color: DuoColors.textGrey)),
                        ],
                      ),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasil.lulus ? DuoColors.greenLight : DuoColors.redLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hasil.lulus ? 'LULUS' : 'GAGAL',
                      style: TextStyle(color: hasil.lulus ? DuoColors.green : DuoColors.red, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: DuoColors.textGrey),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: DuoColors.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: hasil.detailJawaban.asMap().entries.map((e) {
                  final d = e.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: d.benar ? DuoColors.greenLight : DuoColors.redLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(d.benar ? '✅' : '❌', style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${e.key + 1}. ${d.pertanyaan}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 4),
                      Text('Jawabanmu: ${d.jawabanSiswa}',
                          style: TextStyle(fontSize: 11, color: d.benar ? const Color(0xFF2B7A00) : DuoColors.red, fontWeight: FontWeight.w700)),
                      if (!d.benar)
                        Text('✓ Benar: ${d.jawabanBenar}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF2B7A00), fontWeight: FontWeight.w800)),
                    ]),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('📭', style: TextStyle(fontSize: 72)),
      const SizedBox(height: 16),
      const Text('Belum ada riwayat quiz', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: DuoColors.textGrey)),
      const SizedBox(height: 6),
      const Text('Mulai quiz dari tab Belajar!', style: TextStyle(color: DuoColors.textGrey, fontSize: 13)),
    ]),
  );
}
