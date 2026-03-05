// aturan_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/soal_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';

class AturanScreen extends StatefulWidget {
  const AturanScreen({super.key});

  @override
  State<AturanScreen> createState() => _AturanScreenState();
}

class _AturanScreenState extends State<AturanScreen> {
  final _db = DatabaseService();
  List<AturanModel> _aturanList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _aturanList = await _db.getAllAturan();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bg,
      appBar: AppBar(title: const Text('Aturan Quiz')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _aturanList.length,
              itemBuilder: (ctx, i) {
                final a = _aturanList[i];
                final mapelColor = AppTheme.mapelColors[a.mapel] ?? Colors.blue;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: mapelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        AppTheme.mapelEmoji[a.mapel] ?? '📘',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text('${a.mapel} - Kelas ${a.kelas}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${a.jumlahSoal} soal | ${a.durasiMenit} menit | Min. ${a.minPoin}%${a.acak ? " | Acak" : ""}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                      onPressed: () => _showEditDialog(a),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEditDialog(AturanModel aturan) {
    int jumlah = aturan.jumlahSoal;
    int durasi = aturan.durasiMenit;
    int minPoin = aturan.minPoin;
    bool acak = aturan.acak;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Aturan ${aturan.mapel} - Kelas ${aturan.kelas}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Jumlah Soal:')),
                  DropdownButton<int>(
                    value: jumlah,
                    items: [5, 10, 15, 20]
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text('$n soal')))
                        .toList(),
                    onChanged: (v) => setModalState(() => jumlah = v!),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Durasi:')),
                  DropdownButton<int>(
                    value: durasi,
                    items: [10, 15, 20, 30, 45, 60]
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text('$n menit')))
                        .toList(),
                    onChanged: (v) => setModalState(() => durasi = v!),
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Nilai Minimum:')),
                  DropdownButton<int>(
                    value: minPoin,
                    items: [50, 60, 70, 75, 80]
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text('$n%')))
                        .toList(),
                    onChanged: (v) => setModalState(() => minPoin = v!),
                  ),
                ],
              ),
              SwitchListTile(
                title: const Text('Acak Soal'),
                value: acak,
                onChanged: (v) => setModalState(() => acak = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                aturan.jumlahSoal == jumlah;
                final updated = AturanModel(
                  id: aturan.id,
                  kelas: aturan.kelas,
                  mapel: aturan.mapel,
                  jumlahSoal: jumlah,
                  durasiMenit: durasi,
                  minPoin: minPoin,
                  acak: acak,
                  updatedAt: DateTime.now(),
                );
                await _db.upsertAturan(updated);
                Navigator.pop(ctx);
                _load();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
