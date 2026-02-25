// models/hasil_model.dart
class HasilModel {
  final String id;
  final String siswaId;
  final String siswaNama;
  final String siswaKelas;
  final String mapel;
  final int totalSoal;
  final int jawabanBenar;
  final int totalPoin;
  final int maksimalPoin;
  final int durasiDetik;
  final List<DetailJawaban> detailJawaban;
  final DateTime selesaiAt;

  HasilModel({
    required this.id,
    required this.siswaId,
    required this.siswaNama,
    required this.siswaKelas,
    required this.mapel,
    required this.totalSoal,
    required this.jawabanBenar,
    required this.totalPoin,
    required this.maksimalPoin,
    required this.durasiDetik,
    required this.detailJawaban,
    required this.selesaiAt,
  });

  double get persentase => totalSoal > 0 ? (jawabanBenar / totalSoal) * 100 : 0;
  bool get lulus => persentase >= 60;

  String get grade {
    if (persentase >= 90) return 'A';
    if (persentase >= 80) return 'B';
    if (persentase >= 70) return 'C';
    if (persentase >= 60) return 'D';
    return 'E';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'siswa_id': siswaId,
      'siswa_nama': siswaNama,
      'siswa_kelas': siswaKelas,
      'mapel': mapel,
      'total_soal': totalSoal,
      'jawaban_benar': jawabanBenar,
      'total_poin': totalPoin,
      'maksimal_poin': maksimalPoin,
      'durasi_detik': durasiDetik,
      'selesai_at': selesaiAt.millisecondsSinceEpoch,
    };
  }

  factory HasilModel.fromMap(Map<String, dynamic> map, List<DetailJawaban> detail) {
    return HasilModel(
      id: map['id'],
      siswaId: map['siswa_id'],
      siswaNama: map['siswa_nama'],
      siswaKelas: map['siswa_kelas'],
      mapel: map['mapel'],
      totalSoal: map['total_soal'],
      jawabanBenar: map['jawaban_benar'],
      totalPoin: map['total_poin'],
      maksimalPoin: map['maksimal_poin'],
      durasiDetik: map['durasi_detik'],
      detailJawaban: detail,
      selesaiAt: DateTime.fromMillisecondsSinceEpoch(map['selesai_at']),
    );
  }
}

class DetailJawaban {
  final String soalId;
  final String pertanyaan;
  final String jawabanSiswa;
  final String jawabanBenar;
  final bool benar;
  final int poin;

  DetailJawaban({
    required this.soalId,
    required this.pertanyaan,
    required this.jawabanSiswa,
    required this.jawabanBenar,
    required this.benar,
    required this.poin,
  });

  Map<String, dynamic> toMap(String hasilId) {
    return {
      'hasil_id': hasilId,
      'soal_id': soalId,
      'pertanyaan': pertanyaan,
      'jawaban_siswa': jawabanSiswa,
      'jawaban_benar': jawabanBenar,
      'benar': benar ? 1 : 0,
      'poin': poin,
    };
  }

  factory DetailJawaban.fromMap(Map<String, dynamic> map) {
    return DetailJawaban(
      soalId: map['soal_id'],
      pertanyaan: map['pertanyaan'],
      jawabanSiswa: map['jawaban_siswa'],
      jawabanBenar: map['jawaban_benar'],
      benar: map['benar'] == 1,
      poin: map['poin'],
    );
  }
}
