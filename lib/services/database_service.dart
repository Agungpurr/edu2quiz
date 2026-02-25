import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/soal_model.dart';
import '../models/hasil_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;
  final _uuid = const Uuid();

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'eduquiz_v2.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY, nama TEXT NOT NULL, username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL, role TEXT NOT NULL, kelas TEXT, no_absen TEXT,
        xp INTEGER DEFAULT 0, streak INTEGER DEFAULT 0, hearts INTEGER DEFAULT 4,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE soal (
        id TEXT PRIMARY KEY, pertanyaan TEXT NOT NULL,
        pilihan_a TEXT NOT NULL, pilihan_b TEXT NOT NULL,
        pilihan_c TEXT NOT NULL, pilihan_d TEXT NOT NULL,
        jawaban_benar INTEGER NOT NULL, mapel TEXT NOT NULL,
        kelas TEXT NOT NULL, tingkat TEXT NOT NULL, poin INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE aturan (
        id TEXT PRIMARY KEY, kelas TEXT NOT NULL, mapel TEXT NOT NULL,
        jumlah_soal INTEGER NOT NULL DEFAULT 5,
        durasi_menit INTEGER NOT NULL DEFAULT 15,
        min_poin INTEGER NOT NULL DEFAULT 60,
        acak INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL,
        UNIQUE(kelas, mapel)
      )
    ''');
    await db.execute('''
      CREATE TABLE hasil (
        id TEXT PRIMARY KEY, siswa_id TEXT NOT NULL, siswa_nama TEXT NOT NULL,
        siswa_kelas TEXT NOT NULL, mapel TEXT NOT NULL,
        total_soal INTEGER NOT NULL, jawaban_benar INTEGER NOT NULL,
        total_poin INTEGER NOT NULL, maksimal_poin INTEGER NOT NULL,
        durasi_detik INTEGER NOT NULL, selesai_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE detail_jawaban (
        id INTEGER PRIMARY KEY AUTOINCREMENT, hasil_id TEXT NOT NULL,
        soal_id TEXT NOT NULL, pertanyaan TEXT NOT NULL,
        jawaban_siswa TEXT NOT NULL, jawaban_benar TEXT NOT NULL,
        benar INTEGER NOT NULL, poin INTEGER NOT NULL
      )
    ''');

    // Seed guru
    await db.insert('users', {
      'id': _uuid.v4(), 'nama': 'Guru Admin', 'username': 'guru',
      'password': 'guru123', 'role': 'guru',
      'xp': 0, 'streak': 0, 'hearts': 4,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    await _seedSoal(db);
    await _seedAturan(db);
  }

  Future<void> _seedSoal(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final soalList = [
      {'id':_uuid.v4(),'pertanyaan':'FPB dari 24 dan 36 adalah ...','pilihan_a':'6','pilihan_b':'12','pilihan_c':'18','pilihan_d':'24','jawaban_benar':1,'mapel':'Matematika','kelas':'5','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Luas persegi dengan sisi 7 cm adalah ...','pilihan_a':'28 cm²','pilihan_b':'42 cm²','pilihan_c':'49 cm²','pilihan_d':'56 cm²','jawaban_benar':2,'mapel':'Matematika','kelas':'5','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'KPK dari 4 dan 6 adalah ...','pilihan_a':'12','pilihan_b':'18','pilihan_c':'24','pilihan_d':'36','jawaban_benar':0,'mapel':'Matematika','kelas':'5','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'0,75 jika diubah ke pecahan menjadi ...','pilihan_a':'1/2','pilihan_b':'2/3','pilihan_c':'3/4','pilihan_d':'4/5','jawaban_benar':2,'mapel':'Matematika','kelas':'5','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Hasil dari 125 ÷ 5 × 2 adalah ...','pilihan_a':'25','pilihan_b':'50','pilihan_c':'100','pilihan_d':'125','jawaban_benar':1,'mapel':'Matematika','kelas':'5','tingkat':'sulit','poin':20,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'24 × 5 = ...','pilihan_a':'100','pilihan_b':'110','pilihan_c':'120','pilihan_d':'130','jawaban_benar':2,'mapel':'Matematika','kelas':'4','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'48 ÷ 6 = ...','pilihan_a':'6','pilihan_b':'7','pilihan_c':'8','pilihan_d':'9','jawaban_benar':2,'mapel':'Matematika','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Volume kubus rusuk 5 cm adalah ...','pilihan_a':'25 cm³','pilihan_b':'75 cm³','pilihan_c':'100 cm³','pilihan_d':'125 cm³','jawaban_benar':3,'mapel':'Matematika','kelas':'6','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'25% dari 200 adalah ...','pilihan_a':'40','pilihan_b':'50','pilihan_c':'60','pilihan_d':'75','jawaban_benar':1,'mapel':'Matematika','kelas':'6','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Proses fotosintesis menghasilkan ...','pilihan_a':'CO₂ dan Air','pilihan_b':'O₂ dan Glukosa','pilihan_c':'N₂ dan Glukosa','pilihan_d':'H₂ dan Oksigen','jawaban_benar':1,'mapel':'IPA','kelas':'5','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Planet terdekat dengan matahari adalah ...','pilihan_a':'Venus','pilihan_b':'Bumi','pilihan_c':'Merkurius','pilihan_d':'Mars','jawaban_benar':2,'mapel':'IPA','kelas':'5','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Hewan yang berkembang biak dengan bertelur disebut ...','pilihan_a':'Vivipar','pilihan_b':'Ovipar','pilihan_c':'Ovovivipar','pilihan_d':'Uniseluler','jawaban_benar':1,'mapel':'IPA','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Bagian tumbuhan yang menyerap air adalah ...','pilihan_a':'Daun','pilihan_b':'Batang','pilihan_c':'Akar','pilihan_d':'Bunga','jawaban_benar':2,'mapel':'IPA','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Sistem peredaran darah terdiri dari ...','pilihan_a':'Jantung dan Paru-paru','pilihan_b':'Jantung, Pembuluh Darah, dan Darah','pilihan_c':'Ginjal dan Hati','pilihan_d':'Otak dan Sumsum Tulang','jawaban_benar':1,'mapel':'IPA','kelas':'6','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Ibu kota negara Indonesia adalah ...','pilihan_a':'Surabaya','pilihan_b':'Bandung','pilihan_c':'Jakarta','pilihan_d':'Medan','jawaban_benar':2,'mapel':'IPS','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Proklamasi kemerdekaan Indonesia pada tanggal ...','pilihan_a':'16 Agustus 1945','pilihan_b':'17 Agustus 1945','pilihan_c':'18 Agustus 1945','pilihan_d':'19 Agustus 1945','jawaban_benar':1,'mapel':'IPS','kelas':'5','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Suku Dayak berasal dari pulau ...','pilihan_a':'Sumatera','pilihan_b':'Jawa','pilihan_c':'Kalimantan','pilihan_d':'Sulawesi','jawaban_benar':2,'mapel':'IPS','kelas':'5','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Ki Hajar Dewantara adalah tokoh ...','pilihan_a':'Politik','pilihan_b':'Pendidikan','pilihan_c':'Militer','pilihan_d':'Seni','jawaban_benar':1,'mapel':'IPS','kelas':'6','tingkat':'sedang','poin':15,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Sinonim dari kata "bagus" adalah ...','pilihan_a':'Jelek','pilihan_b':'Indah','pilihan_c':'Kotor','pilihan_d':'Kusam','jawaban_benar':1,'mapel':'B.Indonesia','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Antonim dari kata "tinggi" adalah ...','pilihan_a':'Besar','pilihan_b':'Lebar','pilihan_c':'Pendek','pilihan_d':'Panjang','jawaban_benar':2,'mapel':'B.Indonesia','kelas':'4','tingkat':'mudah','poin':10,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Paragraf dengan gagasan utama di awal disebut paragraf ...','pilihan_a':'Induktif','pilihan_b':'Deduktif','pilihan_c':'Campuran','pilihan_d':'Deskriptif','jawaban_benar':1,'mapel':'B.Indonesia','kelas':'5','tingkat':'sulit','poin':20,'created_at':now},
      {'id':_uuid.v4(),'pertanyaan':'Tanda baca akhir kalimat tanya adalah ...','pilihan_a':'Titik (.)','pilihan_b':'Koma (,)','pilihan_c':'Seru (!)','pilihan_d':'Tanya (?)','jawaban_benar':3,'mapel':'B.Indonesia','kelas':'5','tingkat':'mudah','poin':10,'created_at':now},
    ];
    for (final s in soalList) await db.insert('soal', s);
  }

  Future<void> _seedAturan(Database db) async {
    for (final k in ['4','5','6']) {
      for (final m in ['Matematika','IPA','IPS','B.Indonesia']) {
        await db.insert('aturan', {
          'id': _uuid.v4(), 'kelas': k, 'mapel': m,
          'jumlah_soal': 5, 'durasi_menit': 15, 'min_poin': 60, 'acak': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  // ══ USER ══
  Future<UserModel?> login(String username, String password) async {
    final d = await db;
    final r = await d.query('users', where: 'username=? AND password=?', whereArgs: [username, password]);
    return r.isEmpty ? null : UserModel.fromMap(r.first);
  }

  Future<List<UserModel>> getAllSiswa() async {
    final d = await db;
    final r = await d.query('users', where: 'role=?', whereArgs: ['siswa'], orderBy: 'kelas ASC, no_absen ASC');
    return r.map(UserModel.fromMap).toList();
  }

  Future<void> addSiswa(UserModel u) async => (await db).insert('users', u.toMap());
  Future<void> updateSiswa(UserModel u) async => (await db).update('users', u.toMap(), where: 'id=?', whereArgs: [u.id]);
  Future<void> deleteSiswa(String id) async => (await db).delete('users', where: 'id=?', whereArgs: [id]);

  Future<bool> isUsernameExist(String username, {String? excludeId}) async {
    final d = await db;
    final r = await d.query('users',
      where: excludeId != null ? 'username=? AND id!=?' : 'username=?',
      whereArgs: excludeId != null ? [username, excludeId] : [username]);
    return r.isNotEmpty;
  }

  Future<void> updateUserStats(String id, {int? xp, int? streak, int? hearts}) async {
    final d = await db;
    final updates = <String, dynamic>{};
    if (xp != null) updates['xp'] = xp;
    if (streak != null) updates['streak'] = streak;
    if (hearts != null) updates['hearts'] = hearts;
    if (updates.isNotEmpty) await d.update('users', updates, where: 'id=?', whereArgs: [id]);
  }

  // ══ SOAL ══
  Future<List<SoalModel>> getAllSoal({String? kelas, String? mapel}) async {
    final d = await db;
    String? where; List<String>? args;
    if (kelas != null && mapel != null) { where='kelas=? AND mapel=?'; args=[kelas,mapel]; }
    else if (kelas != null) { where='kelas=?'; args=[kelas]; }
    else if (mapel != null) { where='mapel=?'; args=[mapel]; }
    final r = await d.query('soal', where: where, whereArgs: args, orderBy: 'kelas ASC, mapel ASC, created_at DESC');
    return r.map(SoalModel.fromMap).toList();
  }

  Future<List<SoalModel>> getSoalForQuiz(String kelas, String mapel, int jumlah, bool acak) async {
    final d = await db;
    final r = await d.query('soal', where: 'kelas=? AND mapel=?', whereArgs: [kelas, mapel],
        orderBy: acak ? 'RANDOM()' : 'created_at ASC', limit: jumlah);
    return r.map(SoalModel.fromMap).toList();
  }

  Future<void> addSoal(SoalModel s) async => (await db).insert('soal', s.toMap());
  Future<void> updateSoal(SoalModel s) async => (await db).update('soal', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  Future<void> deleteSoal(String id) async => (await db).delete('soal', where: 'id=?', whereArgs: [id]);

  // ══ ATURAN ══
  Future<List<AturanModel>> getAllAturan() async {
    final d = await db;
    final r = await d.query('aturan', orderBy: 'kelas ASC, mapel ASC');
    return r.map(AturanModel.fromMap).toList();
  }

  Future<AturanModel?> getAturan(String kelas, String mapel) async {
    final d = await db;
    final r = await d.query('aturan', where: 'kelas=? AND mapel=?', whereArgs: [kelas, mapel]);
    return r.isEmpty ? null : AturanModel.fromMap(r.first);
  }

  Future<void> upsertAturan(AturanModel a) async =>
      (await db).insert('aturan', a.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  // ══ HASIL ══
  Future<void> saveHasil(HasilModel hasil) async {
    final d = await db;
    await d.insert('hasil', hasil.toMap());
    for (final detail in hasil.detailJawaban) {
      await d.insert('detail_jawaban', detail.toMap(hasil.id));
    }
  }

  Future<List<HasilModel>> getHasilBySiswa(String siswaId) async {
    final d = await db;
    final rows = await d.query('hasil', where: 'siswa_id=?', whereArgs: [siswaId], orderBy: 'selesai_at DESC');
    final List<HasilModel> result = [];
    for (final h in rows) {
      final det = await _getDetail(h['id'] as String);
      result.add(HasilModel.fromMap(h, det));
    }
    return result;
  }

  Future<List<HasilModel>> getAllHasil({String? kelas, String? mapel}) async {
    final d = await db;
    String? where; List<String>? args;
    if (kelas != null && mapel != null) { where='siswa_kelas=? AND mapel=?'; args=[kelas,mapel]; }
    else if (kelas != null) { where='siswa_kelas=?'; args=[kelas]; }
    else if (mapel != null) { where='mapel=?'; args=[mapel]; }
    final rows = await d.query('hasil', where: where, whereArgs: args, orderBy: 'selesai_at DESC');
    final List<HasilModel> result = [];
    for (final h in rows) {
      final det = await _getDetail(h['id'] as String);
      result.add(HasilModel.fromMap(h, det));
    }
    return result;
  }

  Future<List<DetailJawaban>> _getDetail(String hasilId) async {
    final d = await db;
    final r = await d.query('detail_jawaban', where: 'hasil_id=?', whereArgs: [hasilId]);
    return r.map(DetailJawaban.fromMap).toList();
  }
}
