import 'package:eduquiz_app/models/lesson_model.dart';
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
    final path = join(await getDatabasesPath(),
        'eduquiz_v5.db'); // ← v3 agar onCreate jalan ulang
    return openDatabase(path, version: 2, onCreate: _onCreate);
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
        jumlah_soal INTEGER NOT NULL DEFAULT 10,
        durasi_menit INTEGER NOT NULL DEFAULT 15,
        min_poin INTEGER NOT NULL DEFAULT 60,
        acak INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL,
        UNIQUE(kelas, mapel)
      )
    ''');

    await db.execute('''
  CREATE TABLE lesson_progress (
    siswa_id TEXT NOT NULL,
    lesson_id TEXT NOT NULL,
    selesai INTEGER NOT NULL,
    skor_tertinggi INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    PRIMARY KEY (siswa_id, lesson_id)
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

    await db.insert('users', {
      'id': _uuid.v4(),
      'nama': 'Guru Admin',
      'username': 'guru',
      'password': 'guru123',
      'role': 'guru',
      'xp': 0,
      'streak': 0,
      'hearts': 4,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    await _seedSoal(db);
    await _seedAturan(db);
  }

  Future<void> _seedSoal(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Helper agar tidak perlu tulis ulang field yang sama
    Map<String, dynamic> s(
      String pertanyaan,
      String a,
      String b,
      String c,
      String d,
      int benar,
      String mapel,
      String kelas,
      String tingkat,
    ) =>
        {
          'id': _uuid.v4(),
          'pertanyaan': pertanyaan,
          'pilihan_a': a,
          'pilihan_b': b,
          'pilihan_c': c,
          'pilihan_d': d,
          'jawaban_benar': benar,
          'mapel': mapel,
          'kelas': kelas,
          'tingkat': tingkat,
          'poin': tingkat == 'mudah'
              ? 10
              : tingkat == 'sedang'
                  ? 15
                  : 20,
          'created_at': now,
        };

    final soalList = [
      // ════════════════════════════════════════════════
      // MATEMATIKA KELAS 5 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Luas persegi dengan sisi 7 cm adalah ...', '28 cm²', '42 cm²',
          '49 cm²', '56 cm²', 2, 'Matematika', '5', 'mudah'),
      s('Hasil dari 125 + 375 adalah ...', '400', '450', '500', '550', 2,
          'Matematika', '5', 'mudah'),
      s('900 ÷ 30 = ...', '3', '30', '300', '3000', 1, 'Matematika', '5',
          'mudah'),
      s('12 × 12 = ...', '124', '134', '144', '154', 2, 'Matematika', '5',
          'mudah'),
      s('450 − 175 = ...', '265', '275', '285', '295', 1, 'Matematika', '5',
          'mudah'),
      s(
          'Kelipatan 5 yang kurang dari 30 adalah ...',
          '5,10,15,20,25',
          '5,10,15,20,30',
          '10,20,30',
          '5,15,25',
          0,
          'Matematika',
          '5',
          'mudah'),
      s('6² (6 pangkat 2) = ...', '12', '18', '36', '64', 2, 'Matematika', '5',
          'mudah'),
      s('Bilangan prima antara 10 dan 20 adalah ...', '11 dan 13', '12 dan 14',
          '11, 13 dan 17', '11, 13, 17 dan 19', 3, 'Matematika', '5', 'mudah'),
      s('Nilai 3/4 sama dengan ...', '0,25', '0,50', '0,75', '1,00', 2,
          'Matematika', '5', 'mudah'),
      s('250 × 4 = ...', '800', '900', '1000', '1100', 2, 'Matematika', '5',
          'mudah'),

      // MATEMATIKA KELAS 5 — sedang (10 soal)
      s('FPB dari 24 dan 36 adalah ...', '6', '12', '18', '24', 1, 'Matematika',
          '5', 'sedang'),
      s('KPK dari 4 dan 6 adalah ...', '12', '18', '24', '36', 0, 'Matematika',
          '5', 'sedang'),
      s('0,75 jika diubah ke pecahan menjadi ...', '1/2', '2/3', '3/4', '4/5',
          2, 'Matematika', '5', 'sedang'),
      s('Keliling persegi panjang 8 cm × 5 cm adalah ...', '13 cm', '26 cm',
          '40 cm', '80 cm', 1, 'Matematika', '5', 'sedang'),
      s('FPB dari 18 dan 27 adalah ...', '3', '6', '9', '18', 2, 'Matematika',
          '5', 'sedang'),
      s('1/2 + 1/4 = ...', '1/6', '2/6', '3/4', '1', 2, 'Matematika', '5',
          'sedang'),
      s('Luas segitiga dengan alas 10 cm dan tinggi 6 cm adalah ...', '16 cm²',
          '30 cm²', '60 cm²', '120 cm²', 1, 'Matematika', '5', 'sedang'),
      s('KPK dari 6 dan 8 adalah ...', '12', '16', '24', '48', 2, 'Matematika',
          '5', 'sedang'),
      s('3/5 diubah ke persen menjadi ...', '35%', '50%', '60%', '65%', 2,
          'Matematika', '5', 'sedang'),
      s('Jika panjang = 12 dan lebar = 7, luas persegi panjang = ...', '38',
          '58', '84', '98', 2, 'Matematika', '5', 'sedang'),

      // MATEMATIKA KELAS 5 — sulit (10 soal)
      s('Hasil dari 125 ÷ 5 × 2 adalah ...', '25', '50', '100', '125', 1,
          'Matematika', '5', 'sulit'),
      s('Jika 3x + 7 = 22, maka x = ...', '3', '4', '5', '6', 2, 'Matematika',
          '5', 'sulit'),
      s('Volume kubus dengan rusuk 4 m adalah ...', '16 m³', '48 m³', '64 m³',
          '96 m³', 2, 'Matematika', '5', 'sulit'),
      s('Hasil dari (24 + 16) × 3 − 10 = ...', '100', '110', '120', '130', 1,
          'Matematika', '5', 'sulit'),
      s('Jika 5y − 3 = 17, maka y = ...', '2', '3', '4', '5', 2, 'Matematika',
          '5', 'sulit'),
      s('Sebuah kolam berbentuk kubus, volumenya 216 m³. Panjang rusuknya = ...',
          '4 m', '5 m', '6 m', '7 m', 2, 'Matematika', '5', 'sulit'),
      s('2/3 × 3/4 = ...', '1/2', '5/7', '6/12', '3/6', 0, 'Matematika', '5',
          'sulit'),
      s('Nilai dari 4³ adalah ...', '12', '24', '48', '64', 3, 'Matematika',
          '5', 'sulit'),
      s('FPB dari 48, 60, dan 72 adalah ...', '6', '12', '24', '36', 1,
          'Matematika', '5', 'sulit'),
      s('Perimeter segitiga sama sisi dengan sisi 13 cm adalah ...', '26 cm',
          '36 cm', '39 cm', '42 cm', 2, 'Matematika', '5', 'sulit'),

      // ════════════════════════════════════════════════
      // MATEMATIKA KELAS 4 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('48 ÷ 6 = ...', '6', '7', '8', '9', 2, 'Matematika', '4', 'mudah'),
      s('24 × 5 = ...', '100', '110', '120', '130', 2, 'Matematika', '4',
          'mudah'),
      s('100 − 37 = ...', '53', '63', '73', '83', 1, 'Matematika', '4',
          'mudah'),
      s('7 × 8 = ...', '48', '54', '56', '64', 2, 'Matematika', '4', 'mudah'),
      s('81 ÷ 9 = ...', '7', '8', '9', '10', 2, 'Matematika', '4', 'mudah'),
      s('Nilai angka 5 dalam bilangan 3.582 adalah ...', '5', '50', '500',
          '5000', 2, 'Matematika', '4', 'mudah'),
      s('200 + 450 = ...', '550', '600', '650', '700', 2, 'Matematika', '4',
          'mudah'),
      s('35 × 2 = ...', '60', '65', '70', '75', 2, 'Matematika', '4', 'mudah'),
      s('120 ÷ 4 = ...', '20', '25', '30', '35', 2, 'Matematika', '4', 'mudah'),
      s(
          'Bilangan genap di antara 11 dan 20 adalah ...',
          '11,13,15,17,19',
          '12,14,16,18,20',
          '12,14,16,18',
          '13,15,17,19',
          2,
          'Matematika',
          '4',
          'mudah'),

      // MATEMATIKA KELAS 4 — sedang (10 soal)
      s('FPB dari 12 dan 18 adalah ...', '3', '6', '9', '12', 1, 'Matematika',
          '4', 'sedang'),
      s('KPK dari 3 dan 5 adalah ...', '8', '10', '15', '30', 2, 'Matematika',
          '4', 'sedang'),
      s('Luas persegi sisi 9 cm adalah ...', '18 cm²', '36 cm²', '72 cm²',
          '81 cm²', 3, 'Matematika', '4', 'sedang'),
      s('Keliling persegi sisi 11 cm adalah ...', '33 cm', '44 cm', '55 cm',
          '66 cm', 1, 'Matematika', '4', 'sedang'),
      s('1/2 + 1/3 = ...', '2/5', '2/6', '5/6', '3/5', 2, 'Matematika', '4',
          'sedang'),
      s('Hasil 4 × 25 + 10 = ...', '100', '110', '120', '130', 1, 'Matematika',
          '4', 'sedang'),
      s('FPB dari 16 dan 24 adalah ...', '4', '6', '8', '12', 2, 'Matematika',
          '4', 'sedang'),
      s('72 ÷ 8 × 3 = ...', '21', '24', '27', '30', 2, 'Matematika', '4',
          'sedang'),
      s('Pecahan 2/8 senilai dengan ...', '1/2', '1/4', '1/6', '1/8', 1,
          'Matematika', '4', 'sedang'),
      s('KPK dari 4 dan 10 adalah ...', '10', '20', '40', '80', 1, 'Matematika',
          '4', 'sedang'),

      // MATEMATIKA KELAS 4 — sulit (10 soal)
      s('Jika 2x + 4 = 14, maka x = ...', '3', '4', '5', '6', 2, 'Matematika',
          '4', 'sulit'),
      s('Luas persegi panjang 15 cm × 9 cm adalah ...', '48 cm²', '105 cm²',
          '135 cm²', '150 cm²', 2, 'Matematika', '4', 'sulit'),
      s('KPK dari 6, 8, dan 12 adalah ...', '12', '24', '48', '96', 1,
          'Matematika', '4', 'sulit'),
      s('3/4 × 8 = ...', '4', '6', '8', '12', 1, 'Matematika', '4', 'sulit'),
      s('Sebuah kolam panjang 8 m, lebar 5 m, dalam 2 m. Volumenya = ...',
          '40 m³', '60 m³', '80 m³', '100 m³', 2, 'Matematika', '4', 'sulit'),
      s('(48 ÷ 6) + (7 × 5) = ...', '40', '43', '45', '48', 1, 'Matematika',
          '4', 'sulit'),
      s('FPB dari 30, 45, dan 60 adalah ...', '5', '10', '15', '30', 2,
          'Matematika', '4', 'sulit'),
      s('Hasil dari 3² + 4² = ...', '14', '20', '25', '30', 2, 'Matematika',
          '4', 'sulit'),
      s('Jika 4y − 8 = 12, maka y = ...', '4', '5', '6', '7', 1, 'Matematika',
          '4', 'sulit'),
      s('Nilai dari 5³ − 100 = ...', '15', '25', '125', '25', 1, 'Matematika',
          '4', 'sulit'),

      // ════════════════════════════════════════════════
      // MATEMATIKA KELAS 6 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('25% dari 200 adalah ...', '40', '50', '60', '75', 1, 'Matematika', '6',
          'mudah'),
      s('Volume kubus rusuk 5 cm adalah ...', '25 cm³', '75 cm³', '100 cm³',
          '125 cm³', 3, 'Matematika', '6', 'mudah'),
      s('50% dari 300 adalah ...', '100', '150', '200', '250', 1, 'Matematika',
          '6', 'mudah'),
      s('π × 7² ≈ ... (π = 3,14)', '143,24', '153,86', '163,24', '173,86', 1,
          'Matematika', '6', 'mudah'),
      s('Diameter lingkaran = 20 cm, jari-jarinya = ...', '5 cm', '10 cm',
          '20 cm', '40 cm', 1, 'Matematika', '6', 'mudah'),
      s('Luas persegi sisi 13 cm = ...', '52 cm²', '104 cm²', '169 cm²',
          '196 cm²', 2, 'Matematika', '6', 'mudah'),
      s('75% dari 400 = ...', '200', '250', '300', '350', 2, 'Matematika', '6',
          'mudah'),
      s('5.000 ÷ 25 = ...', '20', '50', '100', '200', 3, 'Matematika', '6',
          'mudah'),
      s('Bilangan yang habis dibagi 2 dan 3 antara 1-20 adalah ...', '6 dan 12',
          '6, 12, dan 18', '4 dan 8', '3 dan 9', 1, 'Matematika', '6', 'mudah'),
      s('Hasil dari 15² = ...', '125', '175', '225', '250', 2, 'Matematika',
          '6', 'mudah'),

      // MATEMATIKA KELAS 6 — sedang (10 soal)
      s(
          'Luas trapesium dengan sisi sejajar 8 dan 12 cm, tinggi 5 cm = ...',
          '40 cm²',
          '50 cm²',
          '60 cm²',
          '70 cm²',
          1,
          'Matematika',
          '6',
          'sedang'),
      s('Volume balok 10 × 4 × 3 cm = ...', '100 cm³', '120 cm³', '140 cm³',
          '160 cm³', 1, 'Matematika', '6', 'sedang'),
      s('Keliling lingkaran dengan r = 7 cm (π = 22/7) = ...', '22 cm', '44 cm',
          '66 cm', '88 cm', 1, 'Matematika', '6', 'sedang'),
      s('Diskon 20% dari Rp 50.000 = ...', 'Rp 8.000', 'Rp 10.000', 'Rp 12.000',
          'Rp 15.000', 1, 'Matematika', '6', 'sedang'),
      s('FPB dari 72 dan 96 adalah ...', '12', '18', '24', '36', 2,
          'Matematika', '6', 'sedang'),
      s('3,6 + 1,75 = ...', '5,25', '5,35', '5,45', '5,55', 1, 'Matematika',
          '6', 'sedang'),
      s('Luas lingkaran dengan d = 14 cm (π = 22/7) = ...', '44 cm²', '154 cm²',
          '176 cm²', '196 cm²', 1, 'Matematika', '6', 'sedang'),
      s('Rasio 3:5 dari 400 = ...', '120 dan 200', '100 dan 300', '150 dan 250',
          '200 dan 200', 2, 'Matematika', '6', 'sedang'),
      s('KPK dari 12, 15, dan 20 adalah ...', '30', '60', '120', '180', 1,
          'Matematika', '6', 'sedang'),
      s('2,4 × 1,5 = ...', '3,0', '3,6', '4,0', '4,8', 1, 'Matematika', '6',
          'sedang'),

      // MATEMATIKA KELAS 6 — sulit (10 soal)
      s('Jika 2x + 3y = 16 dan x = 2, maka y = ...', '3', '4', '5', '6', 1,
          'Matematika', '6', 'sulit'),
      s('Volume tabung r = 7 cm, t = 10 cm (π = 22/7) = ...', '1.320 cm³',
          '1.540 cm³', '1.760 cm³', '2.200 cm³', 1, 'Matematika', '6', 'sulit'),
      s('Persentase kenaikan dari 80 ke 100 adalah ...', '15%', '20%', '25%',
          '30%', 2, 'Matematika', '6', 'sulit'),
      s('Akar kuadrat dari 289 adalah ...', '15', '16', '17', '18', 2,
          'Matematika', '6', 'sulit'),
      s('Luas permukaan kubus sisi 6 cm = ...', '144 cm²', '180 cm²', '216 cm²',
          '252 cm²', 2, 'Matematika', '6', 'sulit'),
      s('Jika 7a − 3 = 39, maka a = ...', '4', '5', '6', '7', 2, 'Matematika',
          '6', 'sulit'),
      s(
          'Volume prisma segitiga alas 6 cm, tinggi alas 4 cm, tinggi prisma 10 cm = ...',
          '80 cm³',
          '100 cm³',
          '120 cm³',
          '160 cm³',
          2,
          'Matematika',
          '6',
          'sulit'),
      s('Kecepatan 60 km/jam, waktu 2,5 jam, jarak = ...', '100 km', '120 km',
          '150 km', '200 km', 2, 'Matematika', '6', 'sulit'),
      s('Median dari 3, 7, 5, 9, 1 adalah ...', '3', '5', '7', '9', 1,
          'Matematika', '6', 'sulit'),
      s('Mean dari 6, 8, 10, 12, 14 adalah ...', '8', '9', '10', '11', 2,
          'Matematika', '6', 'sulit'),

      // ════════════════════════════════════════════════
      // IPA KELAS 5 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Planet terdekat dengan matahari adalah ...', 'Venus', 'Bumi',
          'Merkurius', 'Mars', 2, 'IPA', '5', 'mudah'),
      s('Air mendidih pada suhu ...', '80°C', '90°C', '100°C', '110°C', 2,
          'IPA', '5', 'mudah'),
      s('Organ pernapasan manusia adalah ...', 'Jantung', 'Paru-paru', 'Ginjal',
          'Hati', 1, 'IPA', '5', 'mudah'),
      s('Hewan yang bernapas dengan insang adalah ...', 'Katak', 'Ikan',
          'Kura-kura', 'Buaya', 1, 'IPA', '5', 'mudah'),
      s('Makhluk hidup membutuhkan ... untuk bertahan hidup', 'Emas',
          'Makan dan minum', 'Teknologi', 'Listrik', 1, 'IPA', '5', 'mudah'),
      s('Benda yang dapat menghantarkan listrik disebut ...', 'Isolator',
          'Konduktor', 'Semikonduktor', 'Dielektrik', 1, 'IPA', '5', 'mudah'),
      s('Matahari termasuk benda langit berupa ...', 'Planet', 'Satelit',
          'Bintang', 'Asteroid', 2, 'IPA', '5', 'mudah'),
      s('Proses perubahan air menjadi uap disebut ...', 'Kondensasi',
          'Evaporasi', 'Presipitasi', 'Infiltrasi', 1, 'IPA', '5', 'mudah'),
      s(
          'Tumbuhan hijau membuat makanan sendiri melalui proses ...',
          'Respirasi',
          'Transpirasi',
          'Fotosintesis',
          'Oksidasi',
          2,
          'IPA',
          '5',
          'mudah'),
      s(
          'Gaya yang menarik benda ke pusat bumi disebut ...',
          'Gaya gesek',
          'Gaya magnet',
          'Gaya gravitasi',
          'Gaya pegas',
          2,
          'IPA',
          '5',
          'mudah'),

      // IPA KELAS 5 — sedang (10 soal)
      s('Proses fotosintesis menghasilkan ...', 'CO₂ dan Air', 'O₂ dan Glukosa',
          'N₂ dan Glukosa', 'H₂ dan Oksigen', 1, 'IPA', '5', 'sedang'),
      s(
          'Bahan utama yang dibutuhkan untuk fotosintesis adalah ...',
          'O₂ dan Air',
          'CO₂ dan Air',
          'Glukosa dan Air',
          'N₂ dan CO₂',
          1,
          'IPA',
          '5',
          'sedang'),
      s('Hewan yang mengalami metamorfosis sempurna adalah ...', 'Belalang',
          'Kupu-kupu', 'Capung', 'Kecoa', 1, 'IPA', '5', 'sedang'),
      s('Lapisan atmosfer terdekat dengan bumi adalah ...', 'Stratosfer',
          'Troposfer', 'Mesosfer', 'Termosfer', 1, 'IPA', '5', 'sedang'),
      s('Perubahan wujud dari gas ke cair disebut ...', 'Menguap', 'Membeku',
          'Mengembun', 'Mencair', 2, 'IPA', '5', 'sedang'),
      s(
          'Sel darah merah berfungsi untuk ...',
          'Melawan kuman',
          'Membawa oksigen',
          'Membekukan darah',
          'Mengangkut sari makanan',
          1,
          'IPA',
          '5',
          'sedang'),
      s(
          'Penyebab utama hujan asam adalah ...',
          'Debu vulkanik',
          'Gas SO₂ dan NOx',
          'Uap air laut',
          'Asap rokok',
          1,
          'IPA',
          '5',
          'sedang'),
      s('Getaran yang merambat disebut ...', 'Energi', 'Gelombang', 'Frekuensi',
          'Amplitudo', 1, 'IPA', '5', 'sedang'),
      s('Alat untuk mengukur suhu adalah ...', 'Barometer', 'Termometer',
          'Hygrometer', 'Anemometer', 1, 'IPA', '5', 'sedang'),
      s('Bagian mata yang mengatur intensitas cahaya masuk adalah ...',
          'Retina', 'Kornea', 'Pupil', 'Lensa mata', 2, 'IPA', '5', 'sedang'),

      // IPA KELAS 5 — sulit (10 soal)
      s(
          'Gaya gravitasi bumi menyebabkan benda ...',
          'Bergerak ke atas',
          'Melayang di udara',
          'Jatuh ke bawah',
          'Diam di tempat',
          2,
          'IPA',
          '5',
          'sulit'),
      s('Daya listrik = tegangan × arus. Jika V=220V dan I=2A, daya = ...',
          '110 W', '222 W', '440 W', '880 W', 2, 'IPA', '5', 'sulit'),
      s('Organisme yang menguraikan sisa makhluk hidup disebut ...', 'Produsen',
          'Konsumen', 'Dekomposer', 'Predator', 2, 'IPA', '5', 'sulit'),
      s(
          'Hukum kekekalan energi berbunyi ...',
          'Energi dapat diciptakan',
          'Energi dapat dimusnahkan',
          'Energi tidak dapat diciptakan dan dimusnahkan',
          'Energi selalu bertambah',
          2,
          'IPA',
          '5',
          'sulit'),
      s(
          'Fungsi klorofil pada tumbuhan adalah ...',
          'Menyerap air',
          'Menyerap cahaya matahari',
          'Mengangkut nutrisi',
          'Melindungi daun',
          1,
          'IPA',
          '5',
          'sulit'),
      s('Jaringan yang menghubungkan tulang dengan otot adalah ...', 'Ligamen',
          'Tendon', 'Kartilago', 'Kolagen', 1, 'IPA', '5', 'sulit'),
      s('Kecepatan cahaya di udara ≈ ...', '3 × 10⁶ m/s', '3 × 10⁷ m/s',
          '3 × 10⁸ m/s', '3 × 10⁹ m/s', 2, 'IPA', '5', 'sulit'),
      s('Planet yang memiliki cincin paling terlihat adalah ...', 'Jupiter',
          'Saturnus', 'Uranus', 'Neptunus', 1, 'IPA', '5', 'sulit'),
      s('Partikel terkecil penyusun materi adalah ...', 'Molekul', 'Atom',
          'Proton', 'Quark', 1, 'IPA', '5', 'sulit'),
      s('Proses pencernaan di lambung dibantu oleh enzim ...', 'Amilase',
          'Lipase', 'Pepsin', 'Maltase', 2, 'IPA', '5', 'sulit'),

      // ════════════════════════════════════════════════
      // IPA KELAS 4 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Hewan yang berkembang biak dengan bertelur disebut ...', 'Vivipar',
          'Ovipar', 'Ovovivipar', 'Uniseluler', 1, 'IPA', '4', 'mudah'),
      s('Bagian tumbuhan yang menyerap air adalah ...', 'Daun', 'Batang',
          'Akar', 'Bunga', 2, 'IPA', '4', 'mudah'),
      s('Hewan pemakan tumbuhan disebut ...', 'Karnivora', 'Herbivora',
          'Omnivora', 'Insektivora', 1, 'IPA', '4', 'mudah'),
      s('Bagian tumbuhan yang berfungsi untuk fotosintesis adalah ...', 'Akar',
          'Batang', 'Daun', 'Buah', 2, 'IPA', '4', 'mudah'),
      s('Es batu jika dipanaskan akan ...', 'Membeku', 'Mencair', 'Menguap',
          'Mengembun', 1, 'IPA', '4', 'mudah'),
      s('Ayam berkembang biak dengan cara ...', 'Melahirkan', 'Bertelur',
          'Membelah diri', 'Bertunas', 1, 'IPA', '4', 'mudah'),
      s('Benda yang tidak dapat menghantarkan panas disebut ...', 'Konduktor',
          'Isolator', 'Semikonduktor', 'Kapasitor', 1, 'IPA', '4', 'mudah'),
      s('Hewan pemakan daging disebut ...', 'Herbivora', 'Omnivora',
          'Karnivora', 'Insektivora', 2, 'IPA', '4', 'mudah'),
      s('Indra penglihat manusia adalah ...', 'Telinga', 'Hidung', 'Mata',
          'Lidah', 2, 'IPA', '4', 'mudah'),
      s(
          'Proses berkeringat pada manusia membantu untuk ...',
          'Menjaga keseimbangan',
          'Mengatur suhu tubuh',
          'Menambah energi',
          'Memproses makanan',
          1,
          'IPA',
          '4',
          'mudah'),

      // IPA KELAS 4 — sedang (10 soal)
      s('Metamorfosis tidak sempurna terjadi pada ...', 'Kupu-kupu', 'Nyamuk',
          'Belalang', 'Katak', 2, 'IPA', '4', 'sedang'),
      s(
          'Fungsi batang pada tumbuhan adalah ...',
          'Menyerap air',
          'Mengangkut air dan nutrisi',
          'Membuat makanan',
          'Perkembangbiakan',
          1,
          'IPA',
          '4',
          'sedang'),
      s(
          'Rantai makanan yang benar adalah ...',
          'Elang → Tikus → Padi',
          'Padi → Tikus → Elang',
          'Tikus → Padi → Elang',
          'Elang → Padi → Tikus',
          1,
          'IPA',
          '4',
          'sedang'),
      s('Perubahan wujud benda dari cair ke padat disebut ...', 'Mencair',
          'Menguap', 'Membeku', 'Mengembun', 2, 'IPA', '4', 'sedang'),
      s('Organ yang menyaring darah pada manusia adalah ...', 'Jantung',
          'Paru-paru', 'Ginjal', 'Usus', 2, 'IPA', '4', 'sedang'),
      s('Habitat asli ikan adalah ...', 'Darat', 'Air', 'Pohon', 'Tanah', 1,
          'IPA', '4', 'sedang'),
      s('Tumbuhan yang menyimpan cadangan makanan di umbi adalah ...', 'Mangga',
          'Singkong', 'Pepaya', 'Rambutan', 1, 'IPA', '4', 'sedang'),
      s('Magnet menarik benda yang terbuat dari ...', 'Plastik', 'Kayu', 'Besi',
          'Karet', 2, 'IPA', '4', 'sedang'),
      s('Proses penguapan air dari daun tumbuhan disebut ...', 'Fotosintesis',
          'Respirasi', 'Transpirasi', 'Absorbsi', 2, 'IPA', '4', 'sedang'),
      s(
          'Hewan yang mengalami hibernasi biasanya bersembunyi karena ...',
          'Musim panas',
          'Musim dingin',
          'Musim hujan',
          'Musim kemarau',
          1,
          'IPA',
          '4',
          'sedang'),

      // IPA KELAS 4 — sulit (10 soal)
      s('Proses penyerbukan yang dibantu angin disebut ...', 'Entomofili',
          'Anemofili', 'Hidrofili', 'Zoogami', 1, 'IPA', '4', 'sulit'),
      s('Lapisan tanah yang paling subur adalah ...', 'Lapisan C', 'Lapisan B',
          'Lapisan A', 'Lapisan Bedrock', 2, 'IPA', '4', 'sulit'),
      s('Energi yang tersimpan dalam makanan adalah energi ...', 'Kinetik',
          'Potensial kimia', 'Listrik', 'Mekanik', 1, 'IPA', '4', 'sulit'),
      s('Hewan yang dapat menghasilkan sutra adalah ...', 'Lebah', 'Ulat sutra',
          'Laba-laba', 'Belalang', 1, 'IPA', '4', 'sulit'),
      s('Zat hijau daun yang berperan dalam fotosintesis adalah ...',
          'Selulosa', 'Stomata', 'Klorofil', 'Vakuola', 2, 'IPA', '4', 'sulit'),
      s(
          'Tulang yang melindungi jantung dan paru-paru adalah ...',
          'Tulang belakang',
          'Tulang rusuk',
          'Tulang dada',
          'Tulang rusuk dan dada',
          3,
          'IPA',
          '4',
          'sulit'),
      s(
          'Pelangi terbentuk karena ...',
          'Hujan lebat',
          'Pembiasan cahaya oleh tetesan air',
          'Cahaya bulan',
          'Pantulan cahaya tanah',
          1,
          'IPA',
          '4',
          'sulit'),
      s(
          'Sifat cahaya yang dapat menembus benda bening disebut ...',
          'Pemantulan',
          'Pembiasan',
          'Perambatan',
          'Tembus cahaya',
          3,
          'IPA',
          '4',
          'sulit'),
      s(
          'Gaya yang bekerja ketika dua benda bergesekan adalah ...',
          'Gaya gravitasi',
          'Gaya gesek',
          'Gaya pegas',
          'Gaya magnet',
          1,
          'IPA',
          '4',
          'sulit'),
      s('Ekosistem buatan yang dibuat manusia adalah ...', 'Hutan', 'Sungai',
          'Danau', 'Sawah', 3, 'IPA', '4', 'sulit'),

      // ════════════════════════════════════════════════
      // IPA KELAS 6 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s(
          'Sistem peredaran darah terdiri dari ...',
          'Jantung dan Paru-paru',
          'Jantung, Pembuluh Darah, dan Darah',
          'Ginjal dan Hati',
          'Otak dan Sumsum Tulang',
          1,
          'IPA',
          '6',
          'mudah'),
      s('Tata surya kita berada di galaksi ...', 'Andromeda', 'Triangulum',
          'Bima Sakti', 'Magellan', 2, 'IPA', '6', 'mudah'),
      s('Jumlah planet dalam tata surya kita adalah ...', '7', '8', '9', '10',
          1, 'IPA', '6', 'mudah'),
      s('Revolusi bumi memakan waktu ...', '24 jam', '30 hari', '365 hari',
          '12 bulan lebih 1 hari', 2, 'IPA', '6', 'mudah'),
      s(
          'Rotasi bumi menyebabkan terjadinya ...',
          'Pergantian musim',
          'Gerhana bulan',
          'Siang dan malam',
          'Pasang surut air laut',
          2,
          'IPA',
          '6',
          'mudah'),
      s('Penyakit yang disebabkan oleh virus adalah ...', 'TBC', 'Malaria',
          'Flu', 'Kolera', 2, 'IPA', '6', 'mudah'),
      s(
          'Bahan bakar fosil terbentuk dari ...',
          'Batuan vulkanik',
          'Sisa makhluk hidup jutaan tahun lalu',
          'Air laut',
          'Gas bumi murni',
          1,
          'IPA',
          '6',
          'mudah'),
      s('Alat gerak aktif pada manusia adalah ...', 'Tulang', 'Sendi', 'Otot',
          'Ligamen', 2, 'IPA', '6', 'mudah'),
      s(
          'Bulan berputar mengelilingi bumi disebut ...',
          'Rotasi bulan',
          'Revolusi bulan',
          'Gerhana bulan',
          'Fase bulan',
          1,
          'IPA',
          '6',
          'mudah'),
      s(
          'Energi matahari dapat diubah menjadi energi listrik oleh ...',
          'Generator',
          'Turbin',
          'Panel surya',
          'Kabel listrik',
          2,
          'IPA',
          '6',
          'mudah'),

      // IPA KELAS 6 — sedang (10 soal)
      s(
          'Gerhana matahari terjadi ketika ...',
          'Bumi berada di antara matahari dan bulan',
          'Bulan berada di antara matahari dan bumi',
          'Matahari tertutup awan',
          'Bulan memancarkan cahaya',
          1,
          'IPA',
          '6',
          'sedang'),
      s(
          'Fungsi ginjal adalah ...',
          'Memompa darah',
          'Menyaring darah dan menghasilkan urine',
          'Menghasilkan empedu',
          'Menyerap sari makanan',
          1,
          'IPA',
          '6',
          'sedang'),
      s(
          'Proses adaptasi hewan terhadap lingkungan bertujuan untuk ...',
          'Mencari makan saja',
          'Bertahan hidup',
          'Berkembang biak saja',
          'Bermain',
          1,
          'IPA',
          '6',
          'sedang'),
      s(
          'Pencemaran udara utamanya disebabkan oleh ...',
          'Hujan lebat',
          'Asap kendaraan dan pabrik',
          'Angin kencang',
          'Sinar matahari',
          1,
          'IPA',
          '6',
          'sedang'),
      s('Sumber energi terbarukan adalah ...', 'Minyak bumi', 'Batu bara',
          'Angin', 'Gas alam', 2, 'IPA', '6', 'sedang'),
      s('Tulang rawan terdapat pada ...', 'Gigi', 'Cuping hidung dan telinga',
          'Kuku', 'Rambut', 1, 'IPA', '6', 'sedang'),
      s(
          'Tumbuhan yang hidup di lingkungan kering (xerofit) contohnya ...',
          'Teratai',
          'Eceng gondok',
          'Kaktus',
          'Lumut',
          2,
          'IPA',
          '6',
          'sedang'),
      s('Sel saraf disebut juga ...', 'Eritrosit', 'Neuron', 'Trombosit',
          'Leukosit', 1, 'IPA', '6', 'sedang'),
      s('Planet yang paling besar di tata surya adalah ...', 'Saturnus',
          'Jupiter', 'Uranus', 'Neptunus', 1, 'IPA', '6', 'sedang'),
      s(
          'Energi alternatif yang berasal dari panas bumi disebut ...',
          'Energi surya',
          'Energi angin',
          'Energi geotermal',
          'Energi pasang surut',
          2,
          'IPA',
          '6',
          'sedang'),

      // IPA KELAS 6 — sulit (10 soal)
      s(
          'Proses pembelahan sel yang menghasilkan sel anak identik disebut ...',
          'Meiosis',
          'Mitosis',
          'Fertilisasi',
          'Diferensiasi',
          1,
          'IPA',
          '6',
          'sulit'),
      s('Jika massa = 10 kg dan percepatan gravitasi = 10 m/s², berat benda = ...',
          '1 N', '10 N', '100 N', '1000 N', 2, 'IPA', '6', 'sulit'),
      s(
          'Perubahan energi yang terjadi pada panel surya adalah ...',
          'Kimia → Listrik',
          'Cahaya → Listrik',
          'Panas → Mekanik',
          'Listrik → Cahaya',
          1,
          'IPA',
          '6',
          'sulit'),
      s(
          'Hukum Newton I menyatakan bahwa benda diam akan tetap diam jika ...',
          'Diberi gaya',
          'Tidak ada gaya luar yang bekerja padanya',
          'Ada gaya gesek',
          'Massa benda besar',
          1,
          'IPA',
          '6',
          'sulit'),
      s(
          'Fenomena El Niño disebabkan oleh ...',
          'Letusan gunung berapi',
          'Perubahan arus air laut Pasifik',
          'Badai magnet matahari',
          'Pencairan kutub',
          1,
          'IPA',
          '6',
          'sulit'),
      s('DNA tersimpan di dalam ...', 'Ribosom', 'Mitokondria',
          'Inti sel (nukleus)', 'Membran sel', 2, 'IPA', '6', 'sulit'),
      s('Tekanan darah normal manusia dewasa adalah ...', '80/60 mmHg',
          '100/70 mmHg', '120/80 mmHg', '140/90 mmHg', 2, 'IPA', '6', 'sulit'),
      s('Produk yang menggunakan prinsip bioteknologi adalah ...', 'Plastik',
          'Tempe', 'Benang wol', 'Kertas', 1, 'IPA', '6', 'sulit'),
      s(
          'Fenomena aurora terjadi akibat ...',
          'Hujan meteor',
          'Interaksi angin matahari dengan medan magnet bumi',
          'Gerhana bulan',
          'Letusan gunung es',
          1,
          'IPA',
          '6',
          'sulit'),
      s('Asam amino adalah unit penyusun ...', 'Karbohidrat', 'Lemak',
          'Protein', 'Vitamin', 2, 'IPA', '6', 'sulit'),

      // ════════════════════════════════════════════════
      // IPS KELAS 5 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s(
          'Proklamasi kemerdekaan Indonesia pada tanggal ...',
          '16 Agustus 1945',
          '17 Agustus 1945',
          '18 Agustus 1945',
          '19 Agustus 1945',
          1,
          'IPS',
          '5',
          'mudah'),
      s('Suku Dayak berasal dari pulau ...', 'Sumatera', 'Jawa', 'Kalimantan',
          'Sulawesi', 2, 'IPS', '5', 'mudah'),
      s('Ibu kota Provinsi Jawa Barat adalah ...', 'Semarang', 'Surabaya',
          'Bandung', 'Yogyakarta', 2, 'IPS', '5', 'mudah'),
      s('Pulau terbesar di Indonesia adalah ...', 'Jawa', 'Sumatera',
          'Kalimantan', 'Papua', 3, 'IPS', '5', 'mudah'),
      s(
          'Lagu kebangsaan Indonesia adalah ...',
          'Bagimu Negeri',
          'Garuda Pancasila',
          'Indonesia Raya',
          'Berkibarlah Benderaku',
          2,
          'IPS',
          '5',
          'mudah'),
      s('Pancasila terdiri dari ... sila', '3', '4', '5', '6', 2, 'IPS', '5',
          'mudah'),
      s('Simbol negara Indonesia adalah ...', 'Merak', 'Garuda Pancasila',
          'Komodo', 'Harimau', 1, 'IPS', '5', 'mudah'),
      s('Ibu kota negara Indonesia adalah ...', 'Surabaya', 'Bandung',
          'Jakarta', 'Medan', 2, 'IPS', '5', 'mudah'),
      s('Bendera Indonesia berwarna ...', 'Biru dan putih', 'Merah dan putih',
          'Hijau dan kuning', 'Merah putih dan hijau', 1, 'IPS', '5', 'mudah'),
      s('Bahasa persatuan Indonesia adalah ...', 'Bahasa Jawa', 'Bahasa Sunda',
          'Bahasa Indonesia', 'Bahasa Melayu', 2, 'IPS', '5', 'mudah'),

      // IPS KELAS 5 — sedang (10 soal)
      s('Pahlawan nasional "Bapak Koperasi" adalah ...', 'Soekarno', 'Hatta',
          'Sudirman', 'Kartini', 1, 'IPS', '5', 'sedang'),
      s(
          'Sidang BPUPKI pertama membahas tentang ...',
          'Wilayah Indonesia',
          'Dasar negara',
          'UUD 1945',
          'Kabinet pertama',
          1,
          'IPS',
          '5',
          'sedang'),
      s('Kerajaan Hindu tertua di Indonesia adalah ...', 'Majapahit',
          'Sriwijaya', 'Kutai', 'Tarumanegara', 2, 'IPS', '5', 'sedang'),
      s('Tari Saman berasal dari provinsi ...', 'Sumatera Selatan',
          'Sumatera Utara', 'Aceh', 'Riau', 2, 'IPS', '5', 'sedang'),
      s('Mata uang negara Jepang adalah ...', 'Won', 'Yuan', 'Yen', 'Ringgit',
          2, 'IPS', '5', 'sedang'),
      s(
          'Gunung tertinggi di Indonesia adalah ...',
          'Gunung Rinjani',
          'Gunung Semeru',
          'Puncak Jaya',
          'Gunung Merapi',
          2,
          'IPS',
          '5',
          'sedang'),
      s(
          'Sungai terpanjang di Indonesia adalah ...',
          'Sungai Musi',
          'Sungai Barito',
          'Sungai Kapuas',
          'Sungai Mahakam',
          2,
          'IPS',
          '5',
          'sedang'),
      s(
          'Kerajaan Majapahit mencapai puncak kejayaan di bawah Raja ...',
          'Raden Wijaya',
          'Hayam Wuruk',
          'Ken Arok',
          'Tribhuwana',
          1,
          'IPS',
          '5',
          'sedang'),
      s('Negara anggota ASEAN yang ibu kotanya adalah Bangkok adalah ...',
          'Vietnam', 'Myanmar', 'Thailand', 'Kamboja', 2, 'IPS', '5', 'sedang'),
      s('Rumah adat Jawa Tengah adalah ...', 'Joglo', 'Rumah Gadang',
          'Tongkonan', 'Baileo', 0, 'IPS', '5', 'sedang'),

      // IPS KELAS 5 — sulit (10 soal)
      s(
          'Dampak positif letak geografis Indonesia sebagai negara kepulauan adalah ...',
          'Sering terjadi bencana alam',
          'Kaya sumber daya alam laut',
          'Sulit membangun infrastruktur',
          'Rawan konflik antardaerah',
          1,
          'IPS',
          '5',
          'sulit'),
      s(
          'Perbedaan mendasar antara demokrasi langsung dan demokrasi perwakilan adalah ...',
          'Jumlah pemilih',
          'Cara rakyat menyampaikan kedaulatan',
          'Sistem pemilihan presiden',
          'Ada tidaknya partai politik',
          1,
          'IPS',
          '5',
          'sulit'),
      s(
          'Faktor penyebab keberagaman budaya di Indonesia adalah ...',
          'Perbedaan iklim saja',
          'Letak geografis, sejarah, dan pengaruh luar',
          'Sistem pemerintahan',
          'Luas wilayah',
          1,
          'IPS',
          '5',
          'sulit'),
      s(
          'Globalisasi membawa dampak negatif berupa ...',
          'Kemudahan komunikasi',
          'Pertukaran budaya positif',
          'Masuknya budaya asing yang tidak sesuai',
          'Perdagangan internasional',
          2,
          'IPS',
          '5',
          'sulit'),
      s('Sistem tanam paksa (cultuurstelsel) diterapkan oleh ...', 'Raffles',
          'Van den Bosch', 'Daendels', 'De Kock', 1, 'IPS', '5', 'sulit'),
      s(
          'Dokumen Piagam Jakarta berisi rumusan awal dari ...',
          'UUD 1945',
          'Pancasila',
          'Proklamasi kemerdekaan',
          'Pembentukan NKRI',
          1,
          'IPS',
          '5',
          'sulit'),
      s(
          'Perbedaan antara kegiatan ekonomi primer dan sekunder adalah ...',
          'Lokasi usaha',
          'Sumber bahan baku vs pengolahan',
          'Jumlah tenaga kerja',
          'Nilai produk yang dihasilkan',
          1,
          'IPS',
          '5',
          'sulit'),
      s(
          'Fungsi utama Sumpah Pemuda 1928 adalah ...',
          'Memproklamasikan kemerdekaan',
          'Mempersatukan pemuda Indonesia',
          'Membentuk tentara nasional',
          'Merancang UUD',
          1,
          'IPS',
          '5',
          'sulit'),
      s('Tokoh yang merumuskan teks proklamasi bersama Soekarno adalah ...',
          'Soeharto', 'Hatta', 'Sjahrir', 'Sudirman', 1, 'IPS', '5', 'sulit'),
      s(
          'Peristiwa Rengasdengklok bertujuan untuk ...',
          'Mendesak Jepang menyerah',
          'Mengamankan Soekarno-Hatta agar segera proklamasi',
          'Mempersiapkan persenjataan',
          'Membentuk pemerintahan baru',
          1,
          'IPS',
          '5',
          'sulit'),

      // ════════════════════════════════════════════════
      // IPS KELAS 4 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Ibu kota negara Indonesia adalah ...', 'Surabaya', 'Bandung',
          'Jakarta', 'Medan', 2, 'IPS', '4', 'mudah'),
      s('Nama presiden pertama Indonesia adalah ...', 'Soeharto', 'Habibie',
          'Soekarno', 'Wahid', 2, 'IPS', '4', 'mudah'),
      s('Indonesia terletak di benua ...', 'Afrika', 'Amerika', 'Asia', 'Eropa',
          2, 'IPS', '4', 'mudah'),
      s(
          'Pulau Jawa diapit oleh selat ...',
          'Lombok dan Bali',
          'Sunda dan Madura',
          'Karimata dan Bangka',
          'Malaka dan Bangka',
          1,
          'IPS',
          '4',
          'mudah'),
      s(
          'Kegiatan ekonomi yang menghasilkan bahan langsung dari alam disebut ...',
          'Produksi sekunder',
          'Produksi primer',
          'Distribusi',
          'Konsumsi',
          1,
          'IPS',
          '4',
          'mudah'),
      s('Penemu bola lampu adalah ...', 'Albert Einstein', 'Thomas Edison',
          'Alexander Bell', 'Nikola Tesla', 1, 'IPS', '4', 'mudah'),
      s(
          'Masyarakat yang tinggal di daerah pantai banyak bekerja sebagai ...',
          'Petani',
          'Nelayan',
          'Pedagang',
          'Buruh pabrik',
          1,
          'IPS',
          '4',
          'mudah'),
      s('Kegiatan membuat kain di pabrik termasuk kegiatan ...', 'Produksi',
          'Distribusi', 'Konsumsi', 'Pertukaran', 0, 'IPS', '4', 'mudah'),
      s('Wahana transportasi udara adalah ...', 'Kapal', 'Kereta api',
          'Pesawat terbang', 'Bus', 2, 'IPS', '4', 'mudah'),
      s('ASEAN didirikan pada tahun ...', '1965', '1967', '1970', '1975', 1,
          'IPS', '4', 'mudah'),

      // IPS KELAS 4 — sedang (10 soal)
      s('Kenampakan alam daratan yang lebih rendah dari daerah sekitarnya disebut ...',
          'Gunung', 'Bukit', 'Lembah', 'Dataran tinggi', 2, 'IPS', '4', 'sedang'),
      s('Sumber daya alam yang dapat diperbaharui adalah ...', 'Minyak bumi',
          'Batu bara', 'Hutan', 'Emas', 2, 'IPS', '4', 'sedang'),
      s(
          'Peta yang menunjukkan kepadatan penduduk disebut peta ...',
          'Topografi',
          'Korografi',
          'Tematik',
          'Atlas',
          2,
          'IPS',
          '4',
          'sedang'),
      s('Pertukaran barang tanpa menggunakan uang disebut ...', 'Jual beli',
          'Barter', 'Lelang', 'Kredit', 1, 'IPS', '4', 'sedang'),
      s(
          'Provinsi yang terletak paling barat di Indonesia adalah ...',
          'Sumatera Utara',
          'Sumatera Barat',
          'Aceh',
          'Riau',
          2,
          'IPS',
          '4',
          'sedang'),
      s(
          'Kegiatan mendistribusikan barang dari produsen ke konsumen adalah tugas ...',
          'Petani',
          'Distributor/pedagang',
          'Konsumen',
          'Pabrik',
          1,
          'IPS',
          '4',
          'sedang'),
      s(
          'Dataran tinggi di Jawa Barat yang terkenal adalah ...',
          'Dataran tinggi Dieng',
          'Dataran tinggi Tengger',
          'Dataran tinggi Bandung',
          'Dataran tinggi Ijen',
          2,
          'IPS',
          '4',
          'sedang'),
      s(
          'Batas negara Indonesia di sebelah barat adalah ...',
          'Samudra Pasifik',
          'Samudra Hindia',
          'Laut China Selatan',
          'Samudra Atlantik',
          1,
          'IPS',
          '4',
          'sedang'),
      s('Raja Hayam Wuruk berasal dari kerajaan ...', 'Sriwijaya', 'Majapahit',
          'Demak', 'Mataram', 1, 'IPS', '4', 'sedang'),
      s('Alat ukur arah mata angin pada peta disebut ...', 'Skala', 'Legenda',
          'Mawar angin', 'Koordinat', 2, 'IPS', '4', 'sedang'),

      // IPS KELAS 4 — sulit (10 soal)
      s(
          'Salah satu dampak perpindahan penduduk dari desa ke kota adalah ...',
          'Meningkatnya hasil pertanian',
          'Padatnya penduduk kota',
          'Berkurangnya polusi kota',
          'Meratanya pembangunan',
          1,
          'IPS',
          '4',
          'sulit'),
      s('Kebijakan ekonomi yang bertujuan melindungi produk dalam negeri disebut ...',
          'Ekspor', 'Impor', 'Proteksi', 'Liberalisasi', 2, 'IPS', '4', 'sulit'),
      s(
          'Faktor yang mendorong terjadinya urbanisasi adalah ...',
          'Lahan pertanian luas',
          'Lapangan kerja terbatas di desa',
          'Biaya hidup murah di kota',
          'Pendidikan kurang di kota',
          1,
          'IPS',
          '4',
          'sulit'),
      s(
          'Salah satu cara menjaga kelestarian sumber daya alam adalah ...',
          'Menebang hutan sembarangan',
          'Reboisasi',
          'Membakar lahan',
          'Menguras air tanah',
          1,
          'IPS',
          '4',
          'sulit'),
      s('Candi Borobudur dibangun pada masa kerajaan ...', 'Majapahit',
          'Sriwijaya', 'Syailendra', 'Demak', 2, 'IPS', '4', 'sulit'),
      s(
          'Alasan Indonesia disebut negara agraris adalah ...',
          'Banyak industri besar',
          'Sebagian besar penduduk bertani',
          'Hasil tambang melimpah',
          'Banyak pelabuhan besar',
          1,
          'IPS',
          '4',
          'sulit'),
      s('Bentuk kerjasama ASEAN di bidang ekonomi diwujudkan melalui ...',
          'NATO', 'AFTA', 'G20', 'WTO', 1, 'IPS', '4', 'sulit'),
      s(
          'Perbedaan antara peta dan globe adalah ...',
          'Globe lebih akurat karena berbentuk bulat',
          'Peta lebih akurat dari globe',
          'Globe hanya menampilkan satu benua',
          'Peta hanya untuk laut',
          0,
          'IPS',
          '4',
          'sulit'),
      s(
          'Salah satu hak asasi manusia yang paling mendasar adalah ...',
          'Hak memiliki rumah mewah',
          'Hak hidup',
          'Hak mendapat jabatan',
          'Hak kaya raya',
          1,
          'IPS',
          '4',
          'sulit'),
      s('Kegiatan ekonomi yang bertujuan memenuhi kebutuhan sendiri disebut ekonomi ...',
          'Pasar', 'Subsistem', 'Komersil', 'Industri', 1, 'IPS', '4', 'sulit'),

      // ════════════════════════════════════════════════
      // IPS KELAS 6 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Ki Hajar Dewantara adalah tokoh ...', 'Politik', 'Pendidikan',
          'Militer', 'Seni', 1, 'IPS', '6', 'mudah'),
      s(
          'Negara yang berbatasan darat dengan Indonesia di Kalimantan adalah ...',
          'Filipina',
          'Malaysia',
          'Singapura',
          'Brunei Darussalam',
          1,
          'IPS',
          '6',
          'mudah'),
      s('ASEAN berdiri pada tanggal ...', '8 Agustus 1967', '17 Agustus 1945',
          '1 Januari 1970', '5 Juni 1960', 0, 'IPS', '6', 'mudah'),
      s(
          'Negara dengan penduduk terbanyak di dunia adalah ...',
          'Amerika Serikat',
          'India',
          'China',
          'Indonesia',
          2,
          'IPS',
          '6',
          'mudah'),
      s('Tokoh yang dikenal dengan sebutan "Bapak Pembangunan" Indonesia adalah ...',
          'Soekarno', 'Hatta', 'Soeharto', 'Habibie', 2, 'IPS', '6', 'mudah'),
      s('Salah satu negara anggota G20 adalah ...', 'Swiss', 'Norwegia',
          'Indonesia', 'Israel', 2, 'IPS', '6', 'mudah'),
      s('PBB (Perserikatan Bangsa-Bangsa) didirikan pada tahun ...', '1944',
          '1945', '1946', '1950', 1, 'IPS', '6', 'mudah'),
      s('Negara yang menjadi tuan rumah markas besar PBB adalah ...', 'Inggris',
          'Perancis', 'Amerika Serikat', 'Swiss', 2, 'IPS', '6', 'mudah'),
      s('Bentuk pemerintahan Indonesia adalah ...', 'Monarki', 'Oligarki',
          'Republik', 'Federal', 2, 'IPS', '6', 'mudah'),
      s('Sidang umum PBB disebut ...', 'Dewan Keamanan', 'Majelis Umum',
          'Sekretariat', 'Mahkamah Internasional', 1, 'IPS', '6', 'mudah'),

      // IPS KELAS 6 — sedang (10 soal)
      s(
          'Tujuan utama negara berkembang bergabung dengan organisasi internasional adalah ...',
          'Mendapat kekuatan militer',
          'Mendapat bantuan dan kerjasama pembangunan',
          'Menguasai negara lain',
          'Menghindari pajak',
          1,
          'IPS',
          '6',
          'sedang'),
      s(
          'Faktor penyebab kemiskinan antara lain ...',
          'Pendidikan tinggi',
          'Rendahnya kualitas SDM',
          'Banyaknya lapangan kerja',
          'Teknologi maju',
          1,
          'IPS',
          '6',
          'sedang'),
      s(
          'Sistem ekonomi yang mengutamakan kebebasan individu disebut ...',
          'Sosialisme',
          'Komunisme',
          'Kapitalisme',
          'Campuran',
          2,
          'IPS',
          '6',
          'sedang'),
      s('Kerja sama negara-negara pengekspor minyak tergabung dalam ...',
          'ASEAN', 'WTO', 'OPEC', 'IMF', 2, 'IPS', '6', 'sedang'),
      s(
          'Dampak negatif globalisasi bagi budaya lokal adalah ...',
          'Meningkatnya pariwisata',
          'Terkikisnya budaya lokal oleh budaya asing',
          'Pertukaran seniman internasional',
          'Ekspor kerajinan meningkat',
          1,
          'IPS',
          '6',
          'sedang'),
      s('Perang Dunia II berakhir pada tahun ...', '1943', '1944', '1945',
          '1946', 2, 'IPS', '6', 'sedang'),
      s(
          'Ekspor Indonesia ke luar negeri berarti Indonesia menjual produk ke ...',
          'Dalam negeri',
          'Luar negeri',
          'Daerah terpencil',
          'Pulau terluar',
          1,
          'IPS',
          '6',
          'sedang'),
      s(
          'Negara yang paling banyak menggunakan energi di dunia adalah ...',
          'Rusia',
          'India',
          'China',
          'Amerika Serikat',
          3,
          'IPS',
          '6',
          'sedang'),
      s('Lembaga internasional yang menangani masalah kesehatan dunia adalah ...',
          'UNESCO', 'UNICEF', 'WHO', 'FAO', 2, 'IPS', '6', 'sedang'),
      s(
          'Salah satu contoh bentuk kerjasama bilateral Indonesia adalah ...',
          'Keanggotaan ASEAN',
          'Perjanjian dagang dengan Jepang',
          'Sidang PBB',
          'Konferensi G20',
          1,
          'IPS',
          '6',
          'sedang'),

      // IPS KELAS 6 — sulit (10 soal)
      s(
          'Salah satu dampak positif perdagangan internasional bagi Indonesia adalah ...',
          'Hilangnya industri lokal',
          'Devisa negara bertambah',
          'Ketergantungan pada produk asing',
          'Pengangguran meningkat',
          1,
          'IPS',
          '6',
          'sulit'),
      s(
          'Perbedaan sistem ekonomi kapitalis dan sosialis terletak pada ...',
          'Jumlah penduduk',
          'Kepemilikan alat produksi',
          'Luas wilayah',
          'Jenis mata uang',
          1,
          'IPS',
          '6',
          'sulit'),
      s(
          'Reformasi 1998 di Indonesia dipicu oleh ...',
          'Pemilu tidak jujur',
          'Krisis ekonomi dan tuntutan demokratisasi',
          'Konflik militer',
          'Bencana alam besar',
          1,
          'IPS',
          '6',
          'sulit'),
      s('Lembaga yang berfungsi mengatur perdagangan internasional adalah ...',
          'IMF', 'World Bank', 'WTO', 'UNDP', 2, 'IPS', '6', 'sulit'),
      s(
          'Salah satu indikator negara maju adalah ...',
          'Angka kemiskinan tinggi',
          'Pendapatan per kapita tinggi',
          'Ketergantungan pada pertanian',
          'Angka buta huruf tinggi',
          1,
          'IPS',
          '6',
          'sulit'),
      s('Konferensi Asia-Afrika 1955 diselenggarakan di ...', 'Jakarta',
          'Bandung', 'Surabaya', 'Yogyakarta', 1, 'IPS', '6', 'sulit'),
      s(
          'Tujuan dibentuknya ASEAN Free Trade Area (AFTA) adalah ...',
          'Membatasi perdagangan antarnegara ASEAN',
          'Menghapus hambatan perdagangan di kawasan ASEAN',
          'Membentuk mata uang bersama ASEAN',
          'Menyatukan militer ASEAN',
          1,
          'IPS',
          '6',
          'sulit'),
      s(
          'Gerakan Non-Blok didirikan oleh negara-negara yang tidak ingin ...',
          'Bergabung dengan PBB',
          'Berpihak pada blok Barat atau Timur',
          'Melakukan perdagangan internasional',
          'Membentuk organisasi regional',
          1,
          'IPS',
          '6',
          'sulit'),
      s(
          'Salah satu ciri utama negara berkembang adalah ...',
          'Teknologi canggih dan modern',
          'Industrialisasi tinggi',
          'Ketergantungan pada sektor primer',
          'Pendidikan berkualitas tinggi',
          2,
          'IPS',
          '6',
          'sulit'),
      s(
          'Perjanjian internasional yang mengikat negara penandatangannya disebut ...',
          'Resolusi',
          'Deklarasi',
          'Traktat/Perjanjian',
          'Manifesto',
          2,
          'IPS',
          '6',
          'sulit'),

      // ════════════════════════════════════════════════
      // B.INDONESIA KELAS 4 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Sinonim dari kata "bagus" adalah ...', 'Jelek', 'Indah', 'Kotor',
          'Kusam', 1, 'B.Indonesia', '4', 'mudah'),
      s('Antonim dari kata "tinggi" adalah ...', 'Besar', 'Lebar', 'Pendek',
          'Panjang', 2, 'B.Indonesia', '4', 'mudah'),
      s('Antonim dari kata "gelap" adalah ...', 'Hitam', 'Kelam', 'Terang',
          'Biru', 2, 'B.Indonesia', '4', 'mudah'),
      s('Sinonim dari "gembira" adalah ...', 'Sedih', 'Senang', 'Marah',
          'Kecewa', 1, 'B.Indonesia', '4', 'mudah'),
      s('Kata "berlari" merupakan kata kerja yang berawalan ...', 'Ber-', 'Me-',
          'Di-', 'Ter-', 0, 'B.Indonesia', '4', 'mudah'),
      s(
          'Kalimat yang menyatakan perintah diakhiri dengan tanda baca ...',
          'Titik (.)',
          'Koma (,)',
          'Seru (!)',
          'Tanya (?)',
          2,
          'B.Indonesia',
          '4',
          'mudah'),
      s('Kata depan "di" digunakan untuk menunjukkan ...', 'Waktu', 'Tempat',
          'Arah', 'Sebab', 1, 'B.Indonesia', '4', 'mudah'),
      s('Sinonim dari kata "cerdas" adalah ...', 'Bodoh', 'Lamban', 'Pandai',
          'Malas', 2, 'B.Indonesia', '4', 'mudah'),
      s('Antonim dari kata "kaya" adalah ...', 'Dermawan', 'Pelit', 'Miskin',
          'Tamak', 2, 'B.Indonesia', '4', 'mudah'),
      s('Kalimat "Ibu memasak di dapur" memiliki pola ...', 'S-P', 'S-P-O',
          'S-P-K', 'S-P-O-K', 2, 'B.Indonesia', '4', 'mudah'),

      // B.INDONESIA KELAS 4 — sedang (10 soal)
      s(
          'Paragraf yang kalimat utamanya di awal adalah jenis paragraf ...',
          'Induktif',
          'Deduktif',
          'Campuran',
          'Naratif',
          1,
          'B.Indonesia',
          '4',
          'sedang'),
      s(
          'Kata majemuk adalah gabungan dua kata yang ...',
          'Bunyi sama',
          'Membentuk makna baru',
          'Dipisahkan dengan tanda hubung selalu',
          'Berasal dari bahasa asing',
          1,
          'B.Indonesia',
          '4',
          'sedang'),
      s(
          'Teks yang berisi langkah-langkah melakukan sesuatu disebut teks ...',
          'Narasi',
          'Deskripsi',
          'Prosedur',
          'Argumentasi',
          2,
          'B.Indonesia',
          '4',
          'sedang'),
      s(
          '"Gunung itu sangat tinggi hingga menyentuh awan." Kalimat ini termasuk ...',
          'Kalimat fakta',
          'Kalimat opini',
          'Kalimat majemuk',
          'Majas hiperbola',
          3,
          'B.Indonesia',
          '4',
          'sedang'),
      s(
          'Imbuhan "-kan" pada kata "bacakan" berfungsi ...',
          'Menyatakan tempat',
          'Menyatakan tindakan untuk orang lain',
          'Menyatakan pasif',
          'Menyatakan waktu',
          1,
          'B.Indonesia',
          '4',
          'sedang'),
      s('Kata "perjalanan" mendapat imbuhan ...', 'Per-', 'Per-an', '-an',
          'Per-kan', 1, 'B.Indonesia', '4', 'sedang'),
      s('Kalimat pasif ditandai oleh penggunaan awalan ...', 'Me-', 'Ber-',
          'Di-', 'Se-', 2, 'B.Indonesia', '4', 'sedang'),
      s('Makna tersirat dalam sebuah teks disebut makna ...', 'Denotatif',
          'Konotatif', 'Tersurat', 'Tersirat', 3, 'B.Indonesia', '4', 'sedang'),
      s(
          'Teks yang menceritakan pengalaman nyata penulis disebut teks ...',
          'Fiksi',
          'Non-fiksi',
          'Prosedur',
          'Eksposisi',
          1,
          'B.Indonesia',
          '4',
          'sedang'),
      s('Kata baku dari "aktifitas" adalah ...', 'Aktifitas', 'Aktivitas',
          'Aktipitas', 'Akktivitas', 1, 'B.Indonesia', '4', 'sedang'),

      // B.INDONESIA KELAS 4 — sulit (10 soal)
      s(
          'Majas yang membandingkan dua hal berbeda menggunakan kata "seperti" atau "bagaikan" disebut ...',
          'Metafora',
          'Personifikasi',
          'Simile',
          'Hiperbola',
          2,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Teks argumentasi bertujuan untuk ...',
          'Menghibur pembaca',
          'Meyakinkan pembaca dengan argumen',
          'Mendeskripsikan suatu tempat',
          'Menceritakan pengalaman',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Penggunaan huruf kapital yang benar adalah pada ...',
          'Setiap kata dalam kalimat',
          'Awal kalimat dan nama diri',
          'Kata sambung',
          'Akhir kalimat',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Kata homofon adalah kata yang ...',
          'Makna sama tulisan beda',
          'Bunyi sama makna berbeda',
          'Tulisan sama makna beda',
          'Makna dan tulisan sama',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Sinonim kontekstual berarti sinonim yang berlaku ...',
          'Selalu di semua konteks',
          'Hanya dalam konteks tertentu',
          'Hanya dalam puisi',
          'Hanya dalam pidato',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Kalimat efektif harus memiliki sifat ...',
          'Panjang dan detail',
          'Singkat, padat, dan jelas',
          'Menggunakan kata kiasan',
          'Selalu berima',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Penggunaan tanda titik dua (:) yang benar adalah ...',
          'Setelah subjek kalimat',
          'Sebelum perincian atau kutipan',
          'Di tengah kata ulang',
          'Setelah akhir kalimat tanya',
          1,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Kata "mempermasalahkan" terdiri dari imbuhan ...',
          'Me- + per- + -kan',
          'Memper- + -kan',
          'Me- + -per- + masalah + -kan',
          'Semua benar',
          0,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Paragraf yang kalimat utamanya berada di tengah disebut paragraf ...',
          'Deduktif',
          'Induktif',
          'Ineratif',
          'Campuran',
          2,
          'B.Indonesia',
          '4',
          'sulit'),
      s(
          'Ejaan yang Disempurnakan (EYD) berfungsi untuk ...',
          'Membuat bahasa terasa asing',
          'Menyeragamkan penulisan bahasa Indonesia',
          'Mengganti bahasa daerah',
          'Menghapus kata serapan',
          1,
          'B.Indonesia',
          '4',
          'sulit'),

      // ════════════════════════════════════════════════
      // B.INDONESIA KELAS 5 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Tanda baca akhir kalimat tanya adalah ...', 'Titik (.)', 'Koma (,)',
          'Seru (!)', 'Tanya (?)', 3, 'B.Indonesia', '5', 'mudah'),
      s('Kalimat yang mengungkapkan perasaan disebut kalimat ...', 'Perintah',
          'Tanya', 'Seru', 'Berita', 2, 'B.Indonesia', '5', 'mudah'),
      s('Kata "menulis" berasal dari kata dasar ...', 'Nulis', 'Tulis', 'Ulis',
          'Tuli', 1, 'B.Indonesia', '5', 'mudah'),
      s('Antonim dari "rajin" adalah ...', 'Giat', 'Tekun', 'Malas', 'Cerdas',
          2, 'B.Indonesia', '5', 'mudah'),
      s('Sinonim dari "melihat" adalah ...', 'Mendengar', 'Merasakan',
          'Memandang', 'Menyentuh', 2, 'B.Indonesia', '5', 'mudah'),
      s(
          'Huruf kapital digunakan pada awal ...',
          'Setiap kata',
          'Kalimat dan nama diri',
          'Kata benda saja',
          'Kata kerja saja',
          1,
          'B.Indonesia',
          '5',
          'mudah'),
      s('Kata "berlayar" memiliki awalan ...', 'Be-', 'Ber-', 'Bel-', 'Bela-',
          1, 'B.Indonesia', '5', 'mudah'),
      s('Teks yang berisi informasi kejadian nyata disebut teks ...', 'Fiksi',
          'Non-fiksi', 'Pantun', 'Dongeng', 1, 'B.Indonesia', '5', 'mudah'),
      s('Sinonim dari "berani" adalah ...', 'Takut', 'Pengecut', 'Gagah berani',
          'Pemberani', 3, 'B.Indonesia', '5', 'mudah'),
      s('Antonim dari "terang" adalah ...', 'Benderang', 'Sinar', 'Gelap',
          'Cahaya', 2, 'B.Indonesia', '5', 'mudah'),

      // B.INDONESIA KELAS 5 — sedang (10 soal)
      s(
          'Paragraf dengan gagasan utama di awal disebut paragraf ...',
          'Induktif',
          'Deduktif',
          'Campuran',
          'Deskriptif',
          1,
          'B.Indonesia',
          '5',
          'sedang'),
      s('Kata "permasalahan" mendapat imbuhan ...', 'Per-', '-an', 'Per-an',
          'Me-', 2, 'B.Indonesia', '5', 'sedang'),
      s('Isi dari pantun terletak pada baris ke ...', '1 dan 2', '2 dan 3',
          '3 dan 4', '1 dan 4', 2, 'B.Indonesia', '5', 'sedang'),
      s(
          'Teks yang menggambarkan suatu objek secara rinci disebut teks ...',
          'Narasi',
          'Deskripsi',
          'Eksposisi',
          'Persuasi',
          1,
          'B.Indonesia',
          '5',
          'sedang'),
      s('Kata "pemain" terbentuk dari kata dasar "main" ditambah imbuhan ...',
          'Pe-', '-an', 'Pe-an', 'Pem-', 0, 'B.Indonesia', '5', 'sedang'),
      s(
          'Majas "Angin berbisik di telingaku" menggunakan majas ...',
          'Hiperbola',
          'Personifikasi',
          'Simile',
          'Metafora',
          1,
          'B.Indonesia',
          '5',
          'sedang'),
      s(
          'Kalimat utama yang berada di akhir paragraf merupakan ciri paragraf ...',
          'Deduktif',
          'Induktif',
          'Ineratif',
          'Naratif',
          1,
          'B.Indonesia',
          '5',
          'sedang'),
      s('Kata "ketidakhadiran" mendapat imbuhan ...', 'Ke-an', 'Ketidak-an',
          'Ke- + tidak + -an', 'Semua benar', 2, 'B.Indonesia', '5', 'sedang'),
      s(
          'Teks eksposisi bertujuan untuk ...',
          'Menghibur',
          'Menjelaskan dan memberi informasi',
          'Meyakinkan dengan bukti',
          'Menceritakan pengalaman',
          1,
          'B.Indonesia',
          '5',
          'sedang'),
      s(
          'Frasa "buah tangan" berarti ...',
          'Buah yang dipegang tangan',
          'Oleh-oleh',
          'Tangan yang membawa buah',
          'Pekerjaan tangan',
          1,
          'B.Indonesia',
          '5',
          'sedang'),

      // B.INDONESIA KELAS 5 — sulit (10 soal)
      s(
          'Paragraf dengan gagasan utama di akhir disebut paragraf ...',
          'Deduktif',
          'Induktif',
          'Campuran',
          'Deskriptif',
          1,
          'B.Indonesia',
          '5',
          'sulit'),
      s(
          'Kata polisemi adalah kata yang ...',
          'Bunyinya sama maknanya beda',
          'Tulisannya sama maknanya beda',
          'Memiliki banyak makna',
          'Berasal dari bahasa asing',
          2,
          'B.Indonesia',
          '5',
          'sulit'),
      s('Konjungsi yang menyatakan sebab adalah ...', 'Tetapi', 'Dan', 'Karena',
          'Atau', 2, 'B.Indonesia', '5', 'sulit'),
      s('Nomina adalah kata yang menyatakan ...', 'Tindakan', 'Keadaan',
          'Benda', 'Jumlah', 2, 'B.Indonesia', '5', 'sulit'),
      s('Kalimat "Meskipun hujan, dia tetap berangkat" menggunakan konjungsi ...',
          'Sebab', 'Akibat', 'Konsesi', 'Syarat', 2, 'B.Indonesia', '5', 'sulit'),
      s(
          'Teks persuasi berbeda dari teks argumentasi karena ...',
          'Persuasi tanpa bukti',
          'Persuasi bertujuan mengajak/mempengaruhi',
          'Argumentasi lebih panjang',
          'Persuasi hanya untuk iklan',
          1,
          'B.Indonesia',
          '5',
          'sulit'),
      s(
          'Afiks gabungan "memper-...-kan" pada kata "memperdengarkan" memiliki makna ...',
          'Melakukan sesuatu',
          'Membuat orang lain dapat mendengar',
          'Mendengar dengan baik',
          'Mendengar berulang kali',
          1,
          'B.Indonesia',
          '5',
          'sulit'),
      s(
          'Makna denotatif adalah makna yang ...',
          'Konotatif dan kiasan',
          'Sebenarnya dan literal',
          'Berubah-ubah',
          'Budaya dan kontekstual',
          1,
          'B.Indonesia',
          '5',
          'sulit'),
      s(
          'Unsur intrinsik cerita yang menunjukkan waktu dan tempat kejadian adalah ...',
          'Tema',
          'Alur',
          'Latar',
          'Sudut pandang',
          2,
          'B.Indonesia',
          '5',
          'sulit'),
      s(
          'Kalimat majemuk bertingkat terdiri dari ...',
          'Dua klausa setara',
          'Klausa utama dan klausa bawahan',
          'Dua klausa bawahan',
          'Tiga klausa setara',
          1,
          'B.Indonesia',
          '5',
          'sulit'),

      // ════════════════════════════════════════════════
      // B.INDONESIA KELAS 6 — mudah (10 soal)
      // ════════════════════════════════════════════════
      s('Sinonim dari kata "pintar" adalah ...', 'Bodoh', 'Pandai', 'Lambat',
          'Malas', 1, 'B.Indonesia', '6', 'mudah'),
      s('Antonim dari kata "awal" adalah ...', 'Pertama', 'Mulai', 'Akhir',
          'Depan', 2, 'B.Indonesia', '6', 'mudah'),
      s('Kalimat berita biasanya diakhiri dengan tanda ...', '?', '!', '.', ',',
          2, 'B.Indonesia', '6', 'mudah'),
      s(
          'Kata yang digunakan untuk menghubungkan dua kata atau kalimat disebut ...',
          'Kata benda',
          'Kata kerja',
          'Kata sambung (konjungsi)',
          'Kata sifat',
          2,
          'B.Indonesia',
          '6',
          'mudah'),
      s('"Saya" merupakan kata ganti orang ...', 'Pertama', 'Kedua', 'Ketiga',
          'Keempat', 0, 'B.Indonesia', '6', 'mudah'),
      s('Paragraf adalah kumpulan beberapa ...', 'Kata', 'Huruf', 'Kalimat',
          'Wacana', 2, 'B.Indonesia', '6', 'mudah'),
      s('Kata "makanan" dibentuk dari kata dasar "makan" ditambah imbuhan ...',
          'Me-', '-an', 'Ma-', 'Makan-', 1, 'B.Indonesia', '6', 'mudah'),
      s('Sinonim dari "lelah" adalah ...', 'Semangat', 'Segar', 'Capek', 'Kuat',
          2, 'B.Indonesia', '6', 'mudah'),
      s(
          'Tanda koma (,) digunakan untuk ...',
          'Mengakhiri kalimat',
          'Memisahkan bagian kalimat',
          'Mengawali kalimat',
          'Menandai nama orang',
          1,
          'B.Indonesia',
          '6',
          'mudah'),
      s('Kata "keindahan" mengandung imbuhan ...', 'Ke-', '-an', 'Ke-an', 'In-',
          2, 'B.Indonesia', '6', 'mudah'),

      // B.INDONESIA KELAS 6 — sedang (10 soal)
      s(
          'Unsur-unsur paragraf terdiri dari ...',
          'Kalimat topik saja',
          'Kalimat topik dan kalimat penjelas',
          'Kalimat penjelas saja',
          'Kalimat topik, penjelas, dan penutup',
          3,
          'B.Indonesia',
          '6',
          'sedang'),
      s(
          'Jenis karangan yang menceritakan pengalaman disebut ...',
          'Eksposisi',
          'Argumentasi',
          'Narasi',
          'Deskripsi',
          2,
          'B.Indonesia',
          '6',
          'sedang'),
      s(
          'Teks laporan hasil observasi berisi ...',
          'Opini penulis',
          'Hasil pengamatan nyata',
          'Cerita fiksi',
          'Langkah-langkah',
          1,
          'B.Indonesia',
          '6',
          'sedang'),
      s(
          'Makna konotatif dari "buaya darat" adalah ...',
          'Hewan buaya',
          'Orang yang suka menipu/jahat',
          'Tanah berlumpur',
          'Tempat berbahaya',
          1,
          'B.Indonesia',
          '6',
          'sedang'),
      s('Syair terdiri dari ... baris per bait', '2', '3', '4', '5', 2,
          'B.Indonesia', '6', 'sedang'),
      s(
          'Cerita yang berasal dari rakyat dan diwariskan secara lisan disebut ...',
          'Novel',
          'Cerpen',
          'Folklor/legenda',
          'Biografi',
          2,
          'B.Indonesia',
          '6',
          'sedang'),
      s(
          'Kalimat langsung ditandai dengan penggunaan ...',
          'Tanda titik',
          'Tanda petik ("...")',
          'Tanda tanya',
          'Tanda seru',
          1,
          'B.Indonesia',
          '6',
          'sedang'),
      s('Kata "keberhasilan" mendapat imbuhan ...', 'Ke-an', 'Ber-',
          'Ke-ber-an', 'Ke- + ber- + -an', 3, 'B.Indonesia', '6', 'sedang'),
      s(
          'Teks yang berisi penjelasan suatu proses atau cara kerja disebut teks ...',
          'Narasi',
          'Eksplanasi',
          'Deskripsi',
          'Persuasi',
          1,
          'B.Indonesia',
          '6',
          'sedang'),
      s(
          'Adjektiva adalah kata yang menyatakan ...',
          'Tindakan',
          'Sifat atau keadaan',
          'Benda',
          'Bilangan',
          1,
          'B.Indonesia',
          '6',
          'sedang'),

      // B.INDONESIA KELAS 6 — sulit (10 soal)
      s(
          'Kalimat "Dia berlari secepat kilat" menggunakan majas ...',
          'Personifikasi',
          'Hiperbola',
          'Simile',
          'Metafora',
          2,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Teks editorial berbeda dari berita karena ...',
          'Editorial berisi berita objektif',
          'Editorial berisi opini redaksi',
          'Berita berisi opini penulis',
          'Keduanya sama saja',
          1,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Alur maju dalam cerita berarti ...',
          'Cerita mundur ke masa lalu',
          'Cerita melompat-lompat',
          'Cerita bergerak dari awal ke akhir secara kronologis',
          'Cerita tanpa konflik',
          2,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Kata "dipertanggungjawabkan" mendapat imbuhan ...',
          'Di-kan',
          'Di-per-kan',
          'Di-per-...-kan',
          'Di-pertanggung-kan',
          2,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Sudut pandang orang ketiga dalam cerita menggunakan kata ganti ...',
          'Aku, saya',
          'Kamu, kau',
          'Dia, mereka, ia',
          'Kami, kita',
          2,
          'B.Indonesia',
          '6',
          'sulit'),
      s('Kesalahan ejaan yang benar dari "photo copy" adalah ...', 'Foto Copy',
          'Fotocopy', 'Fotokopi', 'Photo Kopi', 2, 'B.Indonesia', '6', 'sulit'),
      s(
          'Fungsi teks prosedur adalah untuk ...',
          'Menghibur pembaca dengan cerita',
          'Memberi panduan melakukan sesuatu langkah demi langkah',
          'Meyakinkan pembaca dengan data',
          'Menjelaskan sebab-akibat',
          1,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Kalimat ambigu adalah kalimat yang ...',
          'Sangat panjang',
          'Memiliki dua makna yang berbeda',
          'Tidak bersubjek',
          'Menggunakan bahasa asing',
          1,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Repetisi dalam gaya bahasa adalah pengulangan ...',
          'Rima di akhir baris',
          'Kata atau frasa untuk penekanan',
          'Struktur kalimat',
          'Paragraf',
          1,
          'B.Indonesia',
          '6',
          'sulit'),
      s(
          'Kata serapan "manajemen" berasal dari bahasa ...',
          'Belanda: "management"',
          'Inggris: "management"',
          'Portugis: "manejo"',
          'Arab: "manajim"',
          1,
          'B.Indonesia',
          '6',
          'sulit'),
    ];

    for (final soal in soalList) {
      await db.insert('soal', soal);
    }
  }

  Future<void> _seedAturan(Database db) async {
    for (final k in ['4', '5', '6']) {
      for (final m in ['Matematika', 'IPA', 'IPS', 'B.Indonesia']) {
        await db.insert('aturan', {
          'id': _uuid.v4(),
          'kelas': k,
          'mapel': m,
          'jumlah_soal': 10, // ← 10 soal per quiz
          'durasi_menit': 15,
          'min_poin': 60,
          'acak': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  // ══ USER ══
  Future<UserModel?> login(String username, String password) async {
    final d = await db;
    final r = await d.query('users',
        where: 'username=? AND password=?', whereArgs: [username, password]);
    return r.isEmpty ? null : UserModel.fromMap(r.first);
  }

  Future<List<UserModel>> getAllSiswa() async {
    final d = await db;
    final r = await d.query('users',
        where: 'role=?',
        whereArgs: ['siswa'],
        orderBy: 'kelas ASC, no_absen ASC');
    return r.map(UserModel.fromMap).toList();
  }

  Future<void> addSiswa(UserModel u) async =>
      (await db).insert('users', u.toMap());
  Future<void> updateSiswa(UserModel u) async =>
      (await db).update('users', u.toMap(), where: 'id=?', whereArgs: [u.id]);
  Future<void> deleteSiswa(String id) async =>
      (await db).delete('users', where: 'id=?', whereArgs: [id]);

  Future<bool> isUsernameExist(String username, {String? excludeId}) async {
    final d = await db;
    final r = await d.query('users',
        where: excludeId != null ? 'username=? AND id!=?' : 'username=?',
        whereArgs: excludeId != null ? [username, excludeId] : [username]);
    return r.isNotEmpty;
  }

  Future<void> updateUserStats(String id,
      {int? xp, int? streak, int? hearts}) async {
    final d = await db;
    final updates = <String, dynamic>{};
    if (xp != null) updates['xp'] = xp;
    if (streak != null) updates['streak'] = streak;
    if (hearts != null) updates['hearts'] = hearts;
    if (updates.isNotEmpty)
      await d.update('users', updates, where: 'id=?', whereArgs: [id]);
  }

  // ══ SOAL ══
  Future<List<SoalModel>> getAllSoal({String? kelas, String? mapel}) async {
    final d = await db;
    String? where;
    List<String>? args;
    if (kelas != null && mapel != null) {
      where = 'kelas=? AND mapel=?';
      args = [kelas, mapel];
    } else if (kelas != null) {
      where = 'kelas=?';
      args = [kelas];
    } else if (mapel != null) {
      where = 'mapel=?';
      args = [mapel];
    }
    final r = await d.query('soal',
        where: where,
        whereArgs: args,
        orderBy: 'kelas ASC, mapel ASC, created_at DESC');
    return r.map(SoalModel.fromMap).toList();
  }

  Future<List<SoalModel>> getSoalForQuiz(
    String kelas,
    String mapel,
    int jumlah,
    bool acak, {
    String? tingkat,
  }) async {
    final d = await db;
    String where = 'kelas=? AND mapel=?';
    List<dynamic> args = [kelas, mapel];
    if (tingkat != null) {
      where += ' AND tingkat=?';
      args.add(tingkat);
    }
    final r = await d.query(
      'soal',
      where: where,
      whereArgs: args,
      orderBy: acak ? 'RANDOM()' : 'created_at ASC',
      limit: jumlah,
    );
    return r.map(SoalModel.fromMap).toList();
  }

  Future<void> addSoal(SoalModel s) async =>
      (await db).insert('soal', s.toMap());
  Future<void> updateSoal(SoalModel s) async =>
      (await db).update('soal', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  Future<void> deleteSoal(String id) async =>
      (await db).delete('soal', where: 'id=?', whereArgs: [id]);

  // ══ ATURAN ══
  Future<List<AturanModel>> getAllAturan() async {
    final d = await db;
    final r = await d.query('aturan', orderBy: 'kelas ASC, mapel ASC');
    return r.map(AturanModel.fromMap).toList();
  }

  Future<AturanModel?> getAturan(String kelas, String mapel) async {
    final d = await db;
    final r = await d.query('aturan',
        where: 'kelas=? AND mapel=?', whereArgs: [kelas, mapel]);
    return r.isEmpty ? null : AturanModel.fromMap(r.first);
  }

  Future<void> upsertAturan(AturanModel a) async =>
      (await db).insert('aturan', a.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

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
    final rows = await d.query('hasil',
        where: 'siswa_id=?', whereArgs: [siswaId], orderBy: 'selesai_at DESC');
    final List<HasilModel> result = [];
    for (final h in rows) {
      final det = await _getDetail(h['id'] as String);
      result.add(HasilModel.fromMap(h, det));
    }
    return result;
  }

  Future<List<HasilModel>> getAllHasil({String? kelas, String? mapel}) async {
    final d = await db;
    String? where;
    List<String>? args;
    if (kelas != null && mapel != null) {
      where = 'siswa_kelas=? AND mapel=?';
      args = [kelas, mapel];
    } else if (kelas != null) {
      where = 'siswa_kelas=?';
      args = [kelas];
    } else if (mapel != null) {
      where = 'mapel=?';
      args = [mapel];
    }
    final rows = await d.query('hasil',
        where: where, whereArgs: args, orderBy: 'selesai_at DESC');
    final List<HasilModel> result = [];
    for (final h in rows) {
      final det = await _getDetail(h['id'] as String);
      result.add(HasilModel.fromMap(h, det));
    }
    return result;
  }

  Future<List<DetailJawaban>> _getDetail(String hasilId) async {
    final d = await db;
    final r = await d
        .query('detail_jawaban', where: 'hasil_id=?', whereArgs: [hasilId]);
    return r.map(DetailJawaban.fromMap).toList();
  }

  Future<void> saveLessonProgress(LessonProgress progress) async {
    final d = await db;
    await d.insert(
        'lesson_progress',
        {
          'siswa_id': progress.siswaId,
          'lesson_id': progress.lessonId,
          'selesai': progress.selesai ? 1 : 0,
          'skor_tertinggi': progress.skorTertinggi,
          'updated_at': progress.updatedAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<LessonProgress>> getLessonProgress(String siswaId) async {
    final d = await db;
    final rows = await d.query(
      'lesson_progress',
      where: 'siswa_id = ?',
      whereArgs: [siswaId],
    );
    return rows
        .map((r) => LessonProgress(
              siswaId: r['siswa_id'] as String,
              lessonId: r['lesson_id'] as String,
              selesai: (r['selesai'] as int) == 1,
              skorTertinggi: r['skor_tertinggi'] as int,
              updatedAt:
                  DateTime.fromMillisecondsSinceEpoch(r['updated_at'] as int),
            ))
        .toList();
  }
}
