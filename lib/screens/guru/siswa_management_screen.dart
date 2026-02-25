import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SiswaManagementScreen extends StatefulWidget {
  const SiswaManagementScreen({super.key});

  @override
  State<SiswaManagementScreen> createState() => _SiswaManagementScreenState();
}

class _SiswaManagementScreenState extends State<SiswaManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _db = DatabaseService();
  List<UserModel> _allSiswa = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadSiswa();
  }

  Future<void> _loadSiswa() async {
    setState(() => _loading = true);
    _allSiswa = await _db.getAllSiswa();
    setState(() => _loading = false);
  }

  List<UserModel> _getFilteredSiswa(String? kelas) {
    return _allSiswa.where((s) {
      final matchKelas = kelas == null || s.kelas == kelas;
      final matchSearch = _search.isEmpty ||
          s.nama.toLowerCase().contains(_search.toLowerCase()) ||
          s.username.toLowerCase().contains(_search.toLowerCase());
      return matchKelas && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuoColors.bg,
      appBar: AppBar(
        title: const Text('Manajemen Siswa'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: false,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Kelas 4'),
            Tab(text: 'Kelas 5'),
            Tab(text: 'Kelas 6'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Cari nama atau username...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _SiswaList(
                    siswa: _getFilteredSiswa(null),
                    onEdit: _showForm,
                    onDelete: _deleteSiswa),
                _SiswaList(
                    siswa: _getFilteredSiswa('4'),
                    onEdit: _showForm,
                    onDelete: _deleteSiswa),
                _SiswaList(
                    siswa: _getFilteredSiswa('5'),
                    onEdit: _showForm,
                    onDelete: _deleteSiswa),
                _SiswaList(
                    siswa: _getFilteredSiswa('6'),
                    onEdit: _showForm,
                    onDelete: _deleteSiswa),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(null),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Siswa'),
        backgroundColor: DuoColors.green,
      ),
    );
  }

  Future<void> _deleteSiswa(UserModel siswa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Siswa'),
        content: Text('Hapus data ${siswa.nama}?'),
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
      await _db.deleteSiswa(siswa.id);
      _loadSiswa();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Siswa berhasil dihapus')));
    }
  }

  void _showForm(UserModel? siswa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SiswaFormSheet(
          siswa: siswa,
          onSave: (s) async {
            if (siswa == null) {
              await _db.addSiswa(s);
            } else {
              await _db.updateSiswa(s);
            }
            _loadSiswa();
            if (mounted) Navigator.pop(ctx);
          }),
    );
  }
}

class _SiswaList extends StatelessWidget {
  final List<UserModel> siswa;
  final Function(UserModel) onEdit;
  final Function(UserModel) onDelete;

  const _SiswaList(
      {required this.siswa, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (siswa.isEmpty) {
      return const EmptyState(
        title: 'Belum ada siswa',
        subtitle: 'Tambahkan siswa baru dengan menekan tombol + di bawah',
        icon: Icons.people_outline,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: siswa.length,
      itemBuilder: (ctx, i) {
        final s = siswa[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
              child: Text(
                s.nama[0].toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
              ),
            ),
            title: Text(s.nama,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                'Kelas ${s.kelas} | No. Absen: ${s.noAbsen ?? '-'}\nUsername: ${s.username}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                  onPressed: () => onEdit(s),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: DuoColors.red),
                  onPressed: () => onDelete(s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SiswaFormSheet extends StatefulWidget {
  final UserModel? siswa;
  final Function(UserModel) onSave;

  const SiswaFormSheet({super.key, this.siswa, required this.onSave});

  @override
  State<SiswaFormSheet> createState() => _SiswaFormSheetState();
}

class _SiswaFormSheetState extends State<SiswaFormSheet> {
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _noAbsenCtrl = TextEditingController();
  String _kelas = '4';
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.siswa != null) {
      final s = widget.siswa!;
      _namaCtrl.text = s.nama;
      _usernameCtrl.text = s.username;
      _passwordCtrl.text = s.password;
      _noAbsenCtrl.text = s.noAbsen ?? '';
      _kelas = s.kelas ?? '4';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final exists = await DatabaseService().isUsernameExist(
      _usernameCtrl.text.trim(),
      excludeId: widget.siswa?.id,
    );

    if (exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Username sudah digunakan!'),
              backgroundColor: DuoColors.red),
        );
      }
      setState(() => _saving = false);
      return;
    }

    final siswa = UserModel(
      id: widget.siswa?.id ?? const Uuid().v4(),
      nama: _namaCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: 'siswa',
      kelas: _kelas,
      noAbsen:
          _noAbsenCtrl.text.trim().isEmpty ? null : _noAbsenCtrl.text.trim(),
      createdAt: widget.siswa?.createdAt ?? DateTime.now(),
    );

    await widget.onSave(siswa);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.siswa != null;
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
                  Text(isEdit ? 'Edit Siswa' : 'Tambah Siswa',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nama Lengkap *',
                    prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _kelas,
                      decoration: const InputDecoration(
                          labelText: 'Kelas *', prefixIcon: Icon(Icons.class_)),
                      items: ['4', '5', '6']
                          .map((k) => DropdownMenuItem(
                              value: k, child: Text('Kelas $k')))
                          .toList(),
                      onChanged: (v) => setState(() => _kelas = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _noAbsenCtrl,
                      decoration: const InputDecoration(
                          labelText: 'No. Absen',
                          prefixIcon: Icon(Icons.numbers)),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Username *',
                    prefixIcon: Icon(Icons.account_circle)),
                validator: (v) => v!.isEmpty ? 'Username harus diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) => v!.isEmpty
                    ? 'Password harus diisi'
                    : (v.length < 4 ? 'Minimal 4 karakter' : null),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEdit ? 'Simpan Perubahan' : 'Tambah Siswa'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
