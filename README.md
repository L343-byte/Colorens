# 🎨 Colorlens — Aplikasi Visual & Deteksi Warna untuk Pelajar SMK

Aplikasi mobile & web berbasis **Flutter** yang dirancang khusus untuk membantu pelajar SMK (khususnya jurusan **DKV, Seni Lukis, dan TKJ**) dalam melakukan skrining persepsi buta warna (*Ishihara & HRR test*) serta deteksi klasifikasi nama warna objek fisik secara *real-time* via kamera.

---

## 📁 Struktur Direktori Proyek (Clean & Modular)

Susunan folder telah dirapikan agar terstruktur, tidak ada file/folder sampah, dan setiap berkas sangat mudah ditemukan:

```
colorlens/
├── assets/                          # Aset resmi yang dimuat oleh aplikasi
│   ├── images/logo.png              # Logo resmi aplikasi Colorlens
│   └── images/ishihara/             # Citra piringan tes buta warna Ishihara
│
├── lib/                             # KODE SUMBER UTAMA APLIKASI
│   ├── main.dart                    # Titik masuk utama program (Entry Point)
│   ├── app.dart                     # Konfigurasi MaterialApp, Rute & Tema
│   │
│   ├── config/                      # Pengaturan Global & Variabel Konstan
│   │   ├── constants.dart           # Durasi tes, nama app, konstanta batas
│   │   ├── routes.dart              # Peta navigasi rute halaman
│   │   └── theme.dart               # Palet warna resmi (Navy, Gold, Red, dll)
│   │
│   ├── data/                        # Dataset Statis Soal Tes
│   │   ├── ishihara_data.dart       # 10 Soal piringan angka Ishihara
│   │   └── hrr_data.dart            # 8 Soal piringan bentuk geometris HRR
│   │
│   ├── models/                      # Struktur Objek Data (Data Models)
│   │   ├── user_model.dart          # Objek profil siswa (Nama, Sekolah, Jurusan)
│   │   ├── test_result_model.dart   # Objek hasil nilai diagnosis tes
│   │   ├── ishihara_plate_model.dart# Definisi piringan titik warna Ishihara
│   │   ├── hrr_plate_model.dart     # Definisi kartu piringan geometris HRR
│   │   └── yolo_detection_model.dart# Model deteksi objek & ekstraksi warna
│   │
│   ├── providers/                   # Manajemen State Aplikasi (Provider)
│   │   ├── auth_provider.dart       # Pengelola status login, sesi & error banner
│   │   ├── test_provider.dart       # Pengelola jalannya tes, skor & simpan hasil
│   │   └── camera_provider.dart     # Pengelola aliran kamera & retikel warna
│   │
│   ├── screens/                     # Halaman Antarmuka (UI Pages)
│   │   ├── auth/                    # Layar Login, Register, & Lupa Kata Sandi
│   │   ├── camera/                  # Layar Scanner Kamera Deteksi Warna
│   │   ├── home/                    # Layar Beranda / Dashboard Utama
│   │   ├── onboarding/              # Layar Pengenalan (3 Slide Edukasi)
│   │   ├── profile/                 # Layar Profil Siswa & Pengaturan Akun
│   │   ├── splash/                  # Layar Pembuka (Splash Screen)
│   │   └── test/                    # Layar Pengerjaan & Hasil Tes (Ishihara/HRR)
│   │
│   ├── services/                    # Logika Bisnis & Mesin Pemrosesan (Logic)
│   │   ├── auth_service.dart        # Logika verifikasi akun (Lokal + Firebase)
│   │   ├── firestore_service.dart   # Logika penyimpanan riwayat tes & profil
│   │   ├── camera_service.dart      # Driver kontrol kamera perangkat
│   │   ├── color_detection_service.dart # Ekstraksi piksel & sampling warna
│   │   ├── permission_service.dart  # Penanganan izin akses kamera
│   │   ├── test_scoring_service.dart# Algoritma penilai skor & klasifikasi CVD
│   │   └── yolo_vision_service.dart # Deteksi cerdas objek kabel/cat/komponen
│   │
│   ├── utils/                       # Alat Bantu & Fungsi Pendukung
│   │   ├── color_utils.dart         # Konversi RGB, HSV, & 40+ Nama Warna Indo
│   │   ├── validators.dart          # Validasi form input (Email, Password)
│   │   └── snackbar_utils.dart      # Notifikasi pop-up responsif
│   │
│   └── widgets/                     # Komponen Tampilan yang Dapat Digunakan Ulang
│       ├── camera/                  # Kartu indikator informasi warna di kamera
│       ├── common/                  # Tombol custom, input text field, overlay
│       └── test/                    # Tampilan piringan, pilihan opsi jawaban, chart
│
├── android/                         # Konfigurasi platform Android (Mobile APK)
├── web/                             # Konfigurasi platform Web (Netlify/Hosting)
├── pubspec.yaml                     # Manajemen dependensi pustaka Flutter
└── README.md                        # Panduan ringkas proyek
```

---

## ⚡ Panduan Cepat Menemukan File Kode (*Cheat Sheet*)

| Jika Anda Ingin Mengubah / Memeriksa | Buka Berkas di Lokasi Ini |
| :--- | :--- |
| **Tampilan Halaman Login / Banner Merah** | `lib/screens/auth/login_screen.dart` |
| **Tampilan Pendaftaran Akun (Sekolah & Jurusan)** | `lib/screens/auth/register_screen.dart` |
| **Tampilan Menu Beranda / Dashboard** | `lib/screens/home/dashboard_screen.dart` |
| **Tampilan Layar Scanner Kamera** | `lib/screens/camera/camera_scanner_screen.dart` |
| **Tampilan Pengerjaan & Hasil Tes Ishihara** | `lib/screens/test/ishihara/` |
| **Tampilan Pengerjaan & Hasil Tes HRR** | `lib/screens/test/hrr/` |
| **Kunci Jawaban & Piringan Soal** | `lib/data/ishihara_data.dart` & `hrr_data.dart` |
| **Algoritma Skoring & Diagnosis Nilai** | `lib/services/test_scoring_service.dart` |
| **Kamus 40+ Nama Warna Bahasa Indonesia** | `lib/utils/color_utils.dart` |
| **Warna Utama Tema (Navy Blue & Emas)** | `lib/config/theme.dart` |
| **Berkas Diagram Draw.io / DFD / Flowchart** | `documentation/` atau `~/Desktop/UserFlow_Colorlens/` |

---

## 🚀 Menjalankan Aplikasi

```bash
# 1. Mengambil dependensi pustaka
flutter pub get

# 2. Menjalankan di browser (Web)
flutter run -d chrome

# 3. Mengompilasi rilis Web untuk Netlify
flutter build web --release --base-href "/"
```
