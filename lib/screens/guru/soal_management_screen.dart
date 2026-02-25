import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/soal_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SoalManagementScreen extends StatefulWidget {
  const SoalManagementScreen({super.key});

  @override
  State<SoalManagementScreen> createState() => _SoalManagementScreenState();
}

class _SoalManagementScreenState extends State<SoalManagementScreen> {
  final _db = DatabaseService();
  List<SoalModel> _soalList = [];
  bool _loading = true;
  String _filterKelas = 'Semua';
  String _filterMapel = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadSoal();
  }

  Future<void> _loadSoal() async {
    setState(() => _loading = true);
    final kelas = _filterKelas == 'Semua' ? null : _filterKelas;
    final mapel = _filterMapel == 'Semua' ? null : _filterMapel;
    _soalList = await _db.getAllSoal(kelas: kelas, mapel: mapel);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bg,
      appBar: AppBar(title: const Text('Bank Soal')),
      body: Column(
        children: [
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
                      _loadSoal();
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
                      _loadSoal();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (!_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('${_soalList.length} soal ditemukan',
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const LoadingWidget(message: 'Memuat soal...')
                : _soalList.isEmpty
                    ? EmptyState(
                        title: 'Belum ada soal',
                        subtitle: 'Tambahkan soal baru',
                        icon: Icons.quiz_outlined,
                        onAction: () => _showForm(null),
                        actionLabel: 'Tambah Soal',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _soalList.length,
                        itemBuilder: (ctx, i) => _SoalCard(
                          soal: _soalList[i],
                          onEdit: () => _showForm(_soalList[i]),
                          onDelete: () => _deleteSoal(_soalList[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Soal'),
      ),
    );
  }

  Future<void> _deleteSoal(SoalModel soal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: Text('Hapus soal ini?\n\n"${soal.pertanyaan}"'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: DuoColors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteSoal(soal.id);
      _loadSoal();
    }
  }

  void _showForm(SoalModel? soal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SoalFormSheet(
        soal: soal,
        onSave: (s) async {
          if (soal == null) {
            await _db.addSoal(s);
          } else {
            await _db.updateSoal(s);
          }
          _loadSoal();
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _SoalCard extends StatelessWidget {
  final SoalModel soal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SoalCard(
      {required this.soal, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final mapelColor = AppTheme.mapelColors[soal.mapel] ?? Colors.blue;
    final tingkatColor =
        AppConstants.tingkatColors[soal.tingkat] ?? Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: mapelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(soal.mapel,
                      style: TextStyle(
                          color: mapelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Kelas ${soal.kelas}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: tingkatColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                      AppConstants.tingkatLabel[soal.tingkat] ?? soal.tingkat,
                      style: TextStyle(color: tingkatColor, fontSize: 11)),
                ),
                const Spacer(),
                Text('+${soal.poin} poin',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(soal.pertanyaan,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...soal.pilihan.asMap().entries.map((e) {
              final isBenar = e.key == soal.jawabanBenar;
              return Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 6, bottom: 2),
                    decoration: BoxDecoration(
                      color:
                          isBenar ? const Color(0xFF4CAF50) : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + e.key),
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isBenar ? Colors.white : Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              fontSize: 13,
                              color: isBenar
                                  ? const Color(0xFF2E7D32)
                                  : Colors.black87,
                              fontWeight: isBenar
                                  ? FontWeight.w600
                                  : FontWeight.normal))),
                ],
              );
            }),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit')),
                TextButton.icon(
                  onPressed: onDelete,
                  icon:
                      const Icon(Icons.delete, size: 16, color: DuoColors.red),
                  label: const Text('Hapus',
                      style: TextStyle(color: DuoColors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SoalFormSheet extends StatefulWidget {
  final SoalModel? soal;
  final Function(SoalModel) onSave;

  const SoalFormSheet({super.key, this.soal, required this.onSave});

  @override
  State<SoalFormSheet> createState() => _SoalFormSheetState();
}

class _SoalFormSheetState extends State<SoalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pertanyaanCtrl = TextEditingController();
  final List<TextEditingController> _pilihanCtrl =
      List.generate(4, (_) => TextEditingController());
  String _kelas = '4';
  String _mapel = 'Matematika';
  String _tingkat = 'sedang';
  int _jawabanBenar = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.soal != null) {
      final s = widget.soal!;
      _pertanyaanCtrl.text = s.pertanyaan;
      for (int i = 0; i < 4; i++) _pilihanCtrl[i].text = s.pilihan[i];
      _kelas = s.kelas;
      _mapel = s.mapel;
      _tingkat = s.tingkat;
      _jawabanBenar = s.jawabanBenar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.soal != null ? 'Edit Soal' : 'Tambah Soal',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _kelas,
                      decoration: const InputDecoration(
                          labelText: 'Kelas', isDense: true),
                      items: ['4', '5', '6']
                          .map((k) => DropdownMenuItem(
                              value: k, child: Text('Kelas $k')))
                          .toList(),
                      onChanged: (v) => setState(() => _kelas = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _mapel,
                      decoration: const InputDecoration(
                          labelText: 'Mapel', isDense: true),
                      items: AppConstants.mapelList
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) => setState(() => _mapel = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tingkat,
                decoration:
                    const InputDecoration(labelText: 'Tingkat Kesulitan'),
                items: AppConstants.tingkatList
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(children: [
                            Icon(Icons.circle,
                                size: 12, color: AppConstants.tingkatColors[t]),
                            const SizedBox(width: 8),
                            Text(AppConstants.tingkatLabel[t] ?? t),
                            Text(' (+${AppConstants.tingkatPoin[t]} poin)',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _tingkat = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pertanyaanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Pertanyaan *', alignLabelWithHint: true),
                validator: (v) => v!.isEmpty ? 'Pertanyaan harus diisi' : null,
              ),
              const SizedBox(height: 12),
              const Text('Pilihan Jawaban (pilih yang benar)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _jawabanBenar = i),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _jawabanBenar == i
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _jawabanBenar == i
                                      ? Colors.white
                                      : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _pilihanCtrl[i],
                          decoration: InputDecoration(
                            hintText: 'Pilihan ${String.fromCharCode(65 + i)}',
                            isDense: true,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Pilihan harus diisi' : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Jawaban benar: Pilihan ${String.fromCharCode(65 + _jawabanBenar)}',
                      style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.soal != null
                          ? 'Simpan Perubahan'
                          : 'Tambah Soal'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final soal = SoalModel(
      id: widget.soal?.id ?? const Uuid().v4(),
      pertanyaan: _pertanyaanCtrl.text.trim(),
      pilihan: _pilihanCtrl.map((c) => c.text.trim()).toList(),
      jawabanBenar: _jawabanBenar,
      mapel: _mapel,
      kelas: _kelas,
      tingkat: _tingkat,
      poin: AppConstants.tingkatPoin[_tingkat] ?? 10,
      createdAt: widget.soal?.createdAt ?? DateTime.now(),
    );
    await widget.onSave(soal);
    setState(() => _saving = false);
  }
}
