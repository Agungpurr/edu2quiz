![WhatsApp Image 2026-03-19 at 23 30 37](https://github.com/user-attachments/assets/abade66c-b789-4540-b118-d4d0d00864b9)# 🦉 EduQuiz — Belajar Seru Tiap Hari! ✨

> Aplikasi mobile kuis edukasi interaktif berbasis **Flutter** yang membuat belajar jadi menyenangkan setiap harinya.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge)

---

## 📋 Daftar Isi

- [Overview](#overview)
- [Tampilan Aplikasi](#tampilan-aplikasi)
- [Fitur](#fitur)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Cara Menjalankan](#cara-menjalankan)
- [Kontribusi](#kontribusi)

---

## 🔍 Overview

**EduQuiz** adalah aplikasi kuis edukasi mobile yang dibangun dengan Flutter, mendukung platform Android dan iOS. Dirancang dengan antarmuka yang ramah pengguna dan berwarna cerah, EduQuiz menghadirkan pengalaman belajar yang menyenangkan dan interaktif untuk semua kalangan.

---

## 📱 Tampilan Aplikasi

Halaman login EduQuiz menampilkan maskot burung hantu yang ikonik dengan tema hijau cerah, form username & password, serta tombol **MASUK** yang responsif.

---

## ✨ Fitur

- 🔐 **Autentikasi** — Login dengan username & password (dengan toggle show/hide password)
- 🎯 **Kuis Interaktif** — Soal-soal edukatif yang menarik dan beragam
- 🔊 **Efek Suara** — Audio feedback saat menjawab soal (fitur `add_soud_music`)
- 📊 **Tracking Progress** — Pantau perkembangan belajar pengguna
- 🎨 **UI Playful** — Desain cerah dan bersahabat dengan maskot burung hantu
- 📱 **Cross-platform** — Berjalan di Android & iOS dari satu codebase

---

## 🛠️ Tech Stack

| Teknologi | Keterangan |
|-----------|------------|
| Flutter | Framework UI cross-platform |
| Dart | Bahasa pemrograman utama |
| Android / iOS / Web / Desktop | Target platform |

---

## 📁 Struktur Proyek

```
edu2quiz/
├── android/              # Konfigurasi native Android
├── ios/                  # Konfigurasi native iOS
├── linux/                # Support Linux desktop
├── macos/                # Support macOS desktop
├── web/                  # Support web browser
├── windows/              # Support Windows desktop
├── assets/               # Gambar, ikon, audio, dsb.
├── test/                 # Unit & widget testing
│
├── lib/                  # Source code utama
│   ├── models/           # Data model & entitas
│   ├── screens/          # Halaman-halaman UI
│   ├── services/         # Logika bisnis & API service
│   ├── utils/            # Helper & utilitas
│   ├── widgets/          # Reusable widget komponen
│   └── main.dart         # Entry point aplikasi
│
├── .gitignore
├── .metadata
├── pubspec.yaml          # Dependensi & konfigurasi Flutter
└── README.md
```

---

## 🚀 Cara Menjalankan

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) versi 3.x atau lebih baru
- Dart SDK (sudah termasuk dalam Flutter)
- Android Studio / VS Code dengan ekstensi Flutter
- Emulator Android / iOS Simulator, atau perangkat fisik

### Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/Agungpurr/edu2quiz.git
   cd edu2quiz
   ```

2. **Install dependensi**
   ```bash
   flutter pub get
   ```

3. **Periksa perangkat yang tersedia**
   ```bash
   flutter devices
   ```

4. **Jalankan aplikasi**
   ```bash
   flutter run
   ```

### Build untuk Produksi

```bash
# Android APK
flutter build apk --release

# Android App Bundle (untuk Play Store)
flutter build appbundle --release

# iOS (memerlukan macOS + Xcode)
flutter build ios --release
```

---

## 🧪 Testing

```bash
# Jalankan semua test
flutter test

# Test dengan coverage
flutter test --coverage
```

---

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch baru: `git checkout -b feature/nama-fitur`
3. Commit perubahan: `git commit -m "feat: deskripsi fitur"`
4. Push ke branch: `git push origin feature/nama-fitur`
5. Buat Pull Request

### Konvensi Commit

```
feat:     fitur baru
fix:      perbaikan bug
style:    perubahan tampilan/UI
refactor: refactoring kode
test:     menambah atau mengubah test
docs:     perubahan dokumentasi
```

---

![WhatsApp Image 2026-03-19 at 23 30 37](https://github.com/user-attachments/assets/4753f825-7d38-4269-89a2-e62e2d9db714)


## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

<div align="center">



🦉 **EduQuiz** — *Belajar Seru Tiap Hari!* ✨

Dibuat dengan ❤️ oleh **Agungpurr**

</div>
