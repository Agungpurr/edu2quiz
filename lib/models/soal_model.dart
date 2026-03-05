import 'package:flutter/material.dart';

// ── SoalModel ────────────────────────────────────────────────────
class SoalModel {
  final String id;
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanBenar;
  final String mapel;
  final String kelas;
  final String tingkat;
  final int poin;
  final DateTime createdAt;
  final String? imageUrl;

  SoalModel({
    required this.id,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenar,
    required this.mapel,
    required this.kelas,
    required this.tingkat,
    required this.poin,
    required this.createdAt,
    this.imageUrl,
  });

  // Getter untuk cek apakah soal punya gambar
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'id': id,
        'pertanyaan': pertanyaan,
        'pilihan_a': pilihan[0],
        'pilihan_b': pilihan[1],
        'pilihan_c': pilihan[2],
        'pilihan_d': pilihan[3],
        'jawaban_benar': jawabanBenar,
        'mapel': mapel,
        'kelas': kelas,
        'tingkat': tingkat,
        'poin': poin,
        'created_at': createdAt.millisecondsSinceEpoch,
        'image_url': imageUrl,
      };

  factory SoalModel.fromMap(Map<String, dynamic> map) => SoalModel(
        id: map['id'],
        pertanyaan: map['pertanyaan'],
        pilihan: [
          map['pilihan_a'],
          map['pilihan_b'],
          map['pilihan_c'],
          map['pilihan_d'],
        ],
        jawabanBenar: map['jawaban_benar'],
        mapel: map['mapel'],
        kelas: map['kelas'],
        tingkat: map['tingkat'],
        poin: map['poin'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
        imageUrl: map['image_url'],
      );
}

// ── AturanModel ──────────────────────────────────────────────────
class AturanModel {
  final String id;
  final String kelas;
  final String mapel;
  int jumlahSoal;
  int durasiMenit;
  int minPoin;
  bool acak;
  final DateTime updatedAt;

  AturanModel({
    required this.id,
    required this.kelas,
    required this.mapel,
    required this.jumlahSoal,
    required this.durasiMenit,
    required this.minPoin,
    required this.acak,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'kelas': kelas,
        'mapel': mapel,
        'jumlah_soal': jumlahSoal,
        'durasi_menit': durasiMenit,
        'min_poin': minPoin,
        'acak': acak ? 1 : 0,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory AturanModel.fromMap(Map<String, dynamic> map) => AturanModel(
        id: map['id'],
        kelas: map['kelas'],
        mapel: map['mapel'],
        jumlahSoal: map['jumlah_soal'],
        durasiMenit: map['durasi_menit'],
        minPoin: map['min_poin'],
        acak: map['acak'] == 1,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      );
}
