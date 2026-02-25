import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hasil_model.dart';
import '../../services/database_service.dart';
import '../../services/pdf_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class HasilGuruScreen extends StatefulWidget {
  const HasilGuruScreen({super.key});

  @override
  State<HasilGuruScreen> createState() => _HasilGuruScreenState();
}

class _HasilGuruScreenState extends State<HasilGuruScreen> {
  final _db = DatabaseService();
  List<HasilModel> _hasilList = [];
  bool _loading = true;
  String _filterKelas = 'Semua';
  String _filterMapel = 'Semua';
  bool _downloadingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadHasil();
  }

  Future<void> _loadHasil() async {
    setState(() => _loading = true);
    final kelas = _filterKelas == 'Semua' ? null : _filterKelas;
    final mapel = _filterMapel == 'Semua' ? null : _filterMapel;
    _hasilList = await _db.getAllHasil(kelas: kelas, mapel: mapel);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final lulusCount = _hasilList.where((h) => h.lulus).length;
    final avgScore = _hasilList.isEmpty
        ? 0.0
        : _hasilList.map((h) => h.persentase).reduce((a, b) => a + b) /
            _hasilList.length;

    return Scaffold(
      backgroundColor: DuoColors.bg,
      appBar: AppBar(
        title: const Text('Hasil Quiz Siswa'),
        actions: [
          if (!_downloadingPdf)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'Download PDF',
              onPressed: _hasilList.isEmpty ? null : _downloadPdf,
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterKelas,
                    decoration: const InputDecoration(
                        labelText: 'Kelas', isDense: true),
                    items: ['Semua', '4', '5', '6']
                        .map((k) => DropdownMenuItem(
                            value: k,
                            child: Text(
                                k == 'Semua' ? 'Semua Kelas' : 'Kelas $k')))
                        .toList(),
                    onChanged: (v) {
                      _filterKelas = v!;
                      _loadHasil();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterMapel,
                    decoration: const InputDecoration(
                        labelText: 'Mapel', isDense: true),
                    items: ['Semua', ...AppConstants.mapelList]
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      _filterMapel = v!;
                      _loadHasil();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Stats
          if (!_loading && _hasilList.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat('Total', '${_hasilList.length}', Icons.assignment,
                      Colors.blue),
                  _MiniStat(
                      'Lulus', '$lulusCount', Icons.check_circle, Colors.green),
                  _MiniStat('Tidak Lulus', '${_hasilList.length - lulusCount}',
                      Icons.cancel, Colors.red),
                  _MiniStat('Rata-rata', '${avgScore.toStringAsFixed(0)}%',
                      Icons.bar_chart, Colors.orange),
                ],
              ),
            ),

          Expanded(
            child: _loading
                ? const LoadingWidget(message: 'Memuat data...')
                : _hasilList.isEmpty
                    ? const EmptyState(
                        title: 'Belum ada hasil quiz',
                        subtitle: 'Hasil quiz siswa akan muncul di sini',
                        icon: Icons.assignment_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _hasilList.length,
                        itemBuilder: (ctx, i) => _HasilCard(
                          hasil: _hasilList[i],
                          onViewDetail: () => _viewDetail(_hasilList[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf() async {
    setState(() => _downloadingPdf = true);
    try {
      await PdfService.generateHasilReport(
        _hasilList,
        kelas: _filterKelas == 'Semua' ? null : _filterKelas,
        mapel: _filterMapel == 'Semua' ? null : _filterMapel,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal membuat PDF: $e'),
              backgroundColor: DuoColors.red),
        );
      }
    } finally {
      setState(() => _downloadingPdf = false);
    }
  }

  void _viewDetail(HasilModel hasil) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _DetailHasilSheet(hasil: hasil),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _HasilCard extends StatelessWidget {
  final HasilModel hasil;
  final VoidCallback onViewDetail;

  const _HasilCard({required this.hasil, required this.onViewDetail});

  @override
  Widget build(BuildContext context) {
    final mapelColor = AppTheme.mapelColors[hasil.mapel] ?? Colors.blue;
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(hasil.selesaiAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onViewDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GradeWidget(grade: hasil.grade, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hasil.siswaNama,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: mapelColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(hasil.mapel,
                              style:
                                  TextStyle(color: mapelColor, fontSize: 11)),
                        ),
                        const SizedBox(width: 4),
                        Text('Kelas ${hasil.siswaKelas}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ScoreProgressBar(percentage: hasil.persentase),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${hasil.jawabanBenar}/${hasil.totalSoal} benar | ${hasil.persentase.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 12,
                                color: hasil.lulus ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600)),
                        Text(dateStr,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHasilSheet extends StatelessWidget {
  final HasilModel hasil;

  const _DetailHasilSheet({required this.hasil});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      expand: false,
      builder: (ctx, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Detail Jawaban',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Color(0xFFF44336)),
                      tooltip: 'Download PDF',
                      onPressed: () => PdfService.generateDetailHasil(hasil),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close)),
                  ],
                ),
              ],
            ),
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text('${hasil.persentase.toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const Text('Nilai',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                  Column(children: [
                    Text(hasil.grade,
                        style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const Text('Grade',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                  Column(children: [
                    Text('${hasil.jawabanBenar}/${hasil.totalSoal}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Text('Benar',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: hasil.detailJawaban.length,
                itemBuilder: (ctx, i) {
                  final d = hasil.detailJawaban[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: d.benar
                          ? Colors.green.withOpacity(0.05)
                          : Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: d.benar
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(d.benar ? Icons.check_circle : Icons.cancel,
                                color: d.benar ? Colors.green : Colors.red,
                                size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text('${i + 1}. ${d.pertanyaan}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Jawaban: ${d.jawabanSiswa}',
                            style: TextStyle(
                                color: d.benar
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontSize: 12)),
                        if (!d.benar)
                          Text('Benar: ${d.jawabanBenar}',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
