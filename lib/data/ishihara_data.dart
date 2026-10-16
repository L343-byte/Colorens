import 'package:flutter/material.dart';
import 'package:colorlens/models/ishihara_plate_model.dart';

import 'dart:math';

/// Data & generator plate tes Ishihara beresolusi tinggi dan jelas.
class IshiharaTestData {
  /// Mengambil daftar plate dengan urutan soal dan opsi jawaban yang diacak untuk setiap siswa/sesi.
  /// Sesuai standar klinis Ishihara:
  /// - Plate 1 (Angka 12 - Demo/Kalibrasi) selalu di urutan pertama.
  /// - Soal nomor 2-10 diacak agar siswa tidak bisa saling mencontek urutan soal.
  /// - Pilihan jawaban (options) pada setiap soal juga diacak posisinya.
  static List<IshiharaPlate> getShuffledPlates() {
    final allPlates = List<IshiharaPlate>.from(plates);
    if (allPlates.isEmpty) return [];

    final demoPlate = allPlates.first;
    final otherPlates = allPlates.sublist(1);

    final random = Random();
    otherPlates.shuffle(random);

    final orderedPlates = [demoPlate, ...otherPlates];

    return orderedPlates.map((plate) {
      final shuffledOptions = List<int>.from(plate.options)..shuffle(random);
      return plate.copyWith(options: shuffledOptions);
    }).toList();
  }

  static List<IshiharaPlate> get plates {
    return [
      _createPlate(
        id: 1,
        number: 12,
        correctAnswer: 12,
        cvdAnswer:
            12, // Demo plate: semua orang normal & buta warna bisa melihat
        options: [12, 21, 17, 0],
        cvdType: 'demo',
        description: 'Semua orang normal dan buta warna bisa melihat angka 12',
        numberColor: const Color(0xFFCD784B),
        bgColor: const Color(0xFF46735F),
        confuserColors: [
          const Color(0xFF375F4E),
          const Color(0xFF55826E),
          const Color(0xFF648C78),
        ],
        imagePath: 'assets/images/ishihara/plate_1.png',
      ),
      _createPlate(
        id: 2,
        number: 8,
        correctAnswer: 8,
        cvdAnswer: 3,
        options: [8, 3, 6, 0],
        cvdType: 'deutan',
        description: 'Orang normal melihat 8, buta warna merah-hijau melihat 3',
        numberColor: const Color(0xFFB95F4B),
        bgColor: const Color(0xFF5F8250),
        confuserColors: [
          const Color(0xFF4B6E41),
          const Color(0xFF6E915F),
          const Color(0xFF7D9B6E),
        ],
        imagePath: 'assets/images/ishihara/plate_2.png',
      ),
      _createPlate(
        id: 3,
        number: 29,
        correctAnswer: 29,
        cvdAnswer: 70,
        options: [29, 70, 27, 0],
        cvdType: 'protan',
        description:
            'Orang normal melihat 29, buta warna merah-hijau melihat 70',
        numberColor: const Color(0xFFBE6946),
        bgColor: const Color(0xFF5A7D55),
        confuserColors: [
          const Color(0xFF466944),
          const Color(0xFF698C64),
          const Color(0xFF789B73),
        ],
        imagePath: 'assets/images/ishihara/plate_3.png',
      ),
      _createPlate(
        id: 4,
        number: 5,
        correctAnswer: 5,
        cvdAnswer: 2,
        options: [5, 2, 6, 0],
        cvdType: 'deutan',
        description: 'Orang normal melihat 5, buta warna merah-hijau melihat 2',
        numberColor: const Color(0xFFC36E41),
        bgColor: const Color(0xFF50785A),
        confuserColors: [
          const Color(0xFF41644B),
          const Color(0xFF5F8769),
          const Color(0xFF6E9176),
        ],
        imagePath: 'assets/images/ishihara/plate_4.png',
      ),
      _createPlate(
        id: 5,
        number: 3,
        correctAnswer: 3,
        cvdAnswer: 5,
        options: [3, 5, 8, 0],
        cvdType: 'protan',
        description: 'Orang normal melihat 3, buta warna merah-hijau melihat 5',
        numberColor: const Color(0xFFB45A4B),
        bgColor: const Color(0xFF5F7D50),
        confuserColors: [
          const Color(0xFF4E6C41),
          const Color(0xFF708C5F),
          const Color(0xFF7D966C),
        ],
        imagePath: 'assets/images/ishihara/plate_5.png',
      ),
      _createPlate(
        id: 6,
        number: 15,
        correctAnswer: 15,
        cvdAnswer: 17,
        options: [15, 17, 1, 0],
        cvdType: 'deutan',
        description: 'Orang normal melihat 15, buta warna melihat 17',
        numberColor: const Color(0xFFBE6446),
        bgColor: const Color(0xFF55785F),
        confuserColors: [
          const Color(0xFF44664E),
          const Color(0xFF66886E),
          const Color(0xFF76947A),
        ],
        imagePath: 'assets/images/ishihara/plate_6.png',
      ),
      _createPlate(
        id: 7,
        number: 74,
        correctAnswer: 74,
        cvdAnswer: 21,
        options: [74, 21, 71, 0],
        cvdType: 'protan',
        description: 'Orang normal melihat 74, buta warna melihat 21',
        numberColor: const Color(0xFFB95F50),
        bgColor: const Color(0xFF5A7D55),
        confuserColors: [
          const Color(0xFF486944),
          const Color(0xFF6C8C66),
          const Color(0xFF7A9873),
        ],
        imagePath: 'assets/images/ishihara/plate_7.png',
      ),
      _createPlate(
        id: 8,
        number: 6,
        correctAnswer: 6,
        cvdAnswer: null,
        options: [6, 9, 8, 0],
        cvdType: 'deutan',
        description: 'Orang normal melihat 6, buta warna tidak melihat angka',
        numberColor: const Color(0xFFAF5546),
        bgColor: const Color(0xFF5C8052),
        confuserColors: [
          const Color(0xFF4B6E42),
          const Color(0xFF6E8E62),
          const Color(0xFF7C9A70),
        ],
        imagePath: 'assets/images/ishihara/plate_8.png',
      ),
      _createPlate(
        id: 9,
        number: 45,
        correctAnswer: 45,
        cvdAnswer: null,
        options: [45, 42, 54, 0],
        cvdType: 'tritan',
        description: 'Orang normal melihat 45, buta warna tidak melihat angka',
        numberColor: const Color(0xFF557DAF),
        bgColor: const Color(0xFFB4A05A),
        confuserColors: [
          const Color(0xFFA08C4B),
          const Color(0xFFC3AF69),
          const Color(0xFFD2BE78),
        ],
        imagePath: 'assets/images/ishihara/plate_9.png',
      ),
      _createPlate(
        id: 10,
        number: 7,
        correctAnswer: 7,
        cvdAnswer: null,
        options: [7, 1, 2, 0],
        cvdType: 'protan',
        description: 'Orang normal melihat 7, buta warna tidak melihat angka',
        numberColor: const Color(0xFFAF554B),
        bgColor: const Color(0xFF50786E),
        confuserColors: [
          const Color(0xFF41665C),
          const Color(0xFF5F877D),
          const Color(0xFF6E948A),
        ],
        imagePath: 'assets/images/ishihara/plate_10.png',
      ),
    ];
  }

  static IshiharaPlate _createPlate({
    required int id,
    required int number,
    required int correctAnswer,
    int? cvdAnswer,
    required List<int> options,
    required String cvdType,
    required String description,
    required Color numberColor,
    required Color bgColor,
    required List<Color> confuserColors,
    String? imagePath,
  }) {
    return IshiharaPlate(
      id: id,
      correctAnswer: correctAnswer,
      cvdAnswer: cvdAnswer,
      options: options,
      cvdType: cvdType,
      description: description,
      imagePath: imagePath,
      dots: _generatePlateData(
        number,
        seed: id * 100,
        numberColor: numberColor,
        bgColor: bgColor,
        confuserColors: confuserColors,
      ),
    );
  }

  /// Menghasilkan titik-titik padat dan tebal yang membentuk angka secara jelas
  static List<DotData> _generatePlateData(
    int number, {
    required int seed,
    required Color numberColor,
    required Color bgColor,
    required List<Color> confuserColors,
  }) {
    final List<DotData> dots = [];
    final rand = Random(seed);
    final String numStr = number.toString();

    // Resolusi grid lebih padat (34 baris x 34 kolom)
    const int steps = 34;
    const double stepSize = 1.0 / steps;
    const double radiusCenter = 0.5;
    const double maxPlateRadius = 0.47;

    // Ketebalan coretan angka
    const double strokeWidth = 0.048;

    for (int r = 0; r < steps; r++) {
      for (int c = 0; c < steps; c++) {
        // Koordinat titik dengan jitter acak agar tampak natural
        final double x =
            (c + 0.5 + (rand.nextDouble() - 0.5) * 0.55) * stepSize;
        final double y =
            (r + 0.5 + (rand.nextDouble() - 0.5) * 0.55) * stepSize;

        // Pastikan hanya berada di dalam piringan bulat
        final double distFromCenter = sqrt(
          pow(x - radiusCenter, 2) + pow(y - radiusCenter, 2),
        );
        if (distFromCenter > maxPlateRadius) continue;

        // Cek apakah koordinat ini merupakan bagian dari angka
        final bool isNumber = _isPointInsideNumber(x, y, numStr, strokeWidth);

        // Ukuran titik (radius) yang cukup rapat
        final double baseRadius = isNumber ? 0.019 : 0.017;
        final double radius = baseRadius + rand.nextDouble() * 0.007;

        Color dotColor;
        // Rentang variasi luminance luas (0.72 - 1.28) untuk mengeliminasi petunjuk terang-gelap
        final double shadeFactor = 0.72 + rand.nextDouble() * 0.56;

        if (isNumber) {
          // 8% peluang titik pengacau di dalam angka (memecah siluet padat angka)
          if (rand.nextDouble() < 0.08) {
            final Color chosenConfuser =
                confuserColors[rand.nextInt(confuserColors.length)];
            dotColor = _adjustColor(chosenConfuser, shadeFactor);
          } else {
            dotColor = _adjustColor(numberColor, shadeFactor);
          }
        } else {
          // 4% peluang titik pengacau berwana angka terselip di background
          if (rand.nextDouble() < 0.04) {
            dotColor = _adjustColor(numberColor, shadeFactor);
          } else {
            final List<Color> palette = [bgColor, ...confuserColors];
            final Color chosenBg = palette[rand.nextInt(palette.length)];
            dotColor = _adjustColor(chosenBg, shadeFactor);
          }
        }

        dots.add(DotData(x: x, y: y, radius: radius, color: dotColor));
      }
    }

    return dots;
  }

  /// Menyesuaikan r, g, b warna untuk efek variasi titik alami
  static Color _adjustColor(Color color, double factor) {
    final r = (color.r * 255.0).round().clamp(0, 255);
    final g = (color.g * 255.0).round().clamp(0, 255);
    final b = (color.b * 255.0).round().clamp(0, 255);
    return Color.fromARGB(
      255,
      (r * factor).clamp(0, 255).toInt(),
      (g * factor).clamp(0, 255).toInt(),
      (b * factor).clamp(0, 255).toInt(),
    );
  }

  /// Memeriksa apakah titik (x, y) berada dalam batas coretan tebal angka
  static bool _isPointInsideNumber(
    double px,
    double py,
    String numStr,
    double strokeWidth,
  ) {
    if (numStr.length == 1) {
      return _isInsideDigit(
        px,
        py,
        numStr[0],
        0.30,
        0.20,
        0.70,
        0.80,
        strokeWidth,
      );
    } else if (numStr.length == 2) {
      // Dua digit berdampingan (misal 12, 29, 74, 45, 15)
      final bool d1 = _isInsideDigit(
        px,
        py,
        numStr[0],
        0.17,
        0.20,
        0.49,
        0.80,
        strokeWidth,
      );
      final bool d2 = _isInsideDigit(
        px,
        py,
        numStr[1],
        0.51,
        0.20,
        0.83,
        0.80,
        strokeWidth,
      );
      return d1 || d2;
    }
    return false;
  }

  /// Cek keberadaan titik di dalam satu digit
  static bool _isInsideDigit(
    double px,
    double py,
    String char,
    double minX,
    double minY,
    double maxX,
    double maxY,
    double strokeWidth,
  ) {
    // Abaikan jika jauh di luar bounding box digit
    if (px < minX - strokeWidth ||
        px > maxX + strokeWidth ||
        py < minY - strokeWidth ||
        py > maxY + strokeWidth) {
      return false;
    }

    // Normalisasi koordinat ke range 0.0 - 1.0 dalam box digit
    final double u = (px - minX) / (maxX - minX);
    final double v = (py - minY) / (maxY - minY);

    final List<List<double>> segments = _getDigitSegments(char);
    for (final seg in segments) {
      final double dist = _distToSegment(u, v, seg[0], seg[1], seg[2], seg[3]);
      // Konversi jarak kembali ke skala piringan
      final double realDist = dist * (maxX - minX);
      if (realDist <= strokeWidth) {
        return true;
      }
    }
    return false;
  }

  /// Garis kerangka coretan untuk setiap angka 0-9
  static List<List<double>> _getDigitSegments(String char) {
    switch (char) {
      case '1':
        return [
          [0.50, 0.05, 0.50, 0.95], // Tiang vertikal
          [0.22, 0.30, 0.50, 0.05], // Moncong atas
          [0.25, 0.95, 0.75, 0.95], // Kaki bawah
        ];
      case '2':
        return [
          [0.15, 0.25, 0.50, 0.05], // Busur atas kiri
          [0.50, 0.05, 0.85, 0.25], // Busur atas kanan
          [0.85, 0.25, 0.80, 0.45], // Turun kanan
          [0.80, 0.45, 0.15, 0.95], // Garis miring ke kiri bawah
          [0.15, 0.95, 0.85, 0.95], // Garis dasar horizontal
        ];
      case '3':
        return [
          [0.15, 0.08, 0.85, 0.08], // Garis atas
          [0.85, 0.08, 0.48, 0.45], // Garis miring tengah
          [0.48, 0.45, 0.85, 0.65], // Lengkung tengah ke kanan
          [0.85, 0.65, 0.65, 0.92], // Lengkung kanan ke bawah
          [0.65, 0.92, 0.15, 0.92], // Bawah
        ];
      case '4':
        return [
          [0.72, 0.05, 0.15, 0.68], // Miring kiri
          [0.15, 0.68, 0.92, 0.68], // Horizontal
          [0.72, 0.15, 0.72, 0.95], // Tiang vertikal kanan
        ];
      case '5':
        return [
          [0.85, 0.08, 0.18, 0.08], // Garis atas
          [0.18, 0.08, 0.18, 0.45], // Vertikal kiri atas
          [0.18, 0.45, 0.82, 0.48], // Horizontal tengah
          [0.82, 0.48, 0.85, 0.78], // Vertikal kanan
          [0.85, 0.78, 0.55, 0.94], // Lengkung bawah kanan
          [0.55, 0.94, 0.15, 0.88], // Ujung bawah kiri
        ];
      case '6':
        return [
          [0.78, 0.12, 0.20, 0.50], // Miring dari atas ke kiri tengah
          [0.20, 0.50, 0.20, 0.88], // Kiri bawah
          [0.20, 0.88, 0.52, 0.96], // Bawah
          [0.52, 0.96, 0.84, 0.85], // Kanan bawah
          [0.84, 0.85, 0.80, 0.52], // Kanan tengah
          [0.80, 0.52, 0.20, 0.52], // Tutup lingkaran tengah
        ];
      case '7':
        return [
          [0.15, 0.08, 0.85, 0.08], // Garis atas
          [0.85, 0.08, 0.40, 0.95], // Garis miring panjang ke bawah
        ];
      case '8':
        return [
          // Lingkaran atas
          [0.50, 0.06, 0.80, 0.26],
          [0.80, 0.26, 0.50, 0.48],
          [0.50, 0.48, 0.20, 0.26],
          [0.20, 0.26, 0.50, 0.06],
          // Lingkaran bawah
          [0.50, 0.48, 0.84, 0.72],
          [0.84, 0.72, 0.50, 0.94],
          [0.50, 0.94, 0.16, 0.72],
          [0.16, 0.72, 0.50, 0.48],
        ];
      case '9':
        return [
          [0.82, 0.50, 0.20, 0.50], // Tutup tengah
          [0.20, 0.50, 0.18, 0.20], // Kiri atas
          [0.18, 0.20, 0.50, 0.06], // Puncak atas
          [0.50, 0.06, 0.82, 0.20], // Kanan atas
          [0.82, 0.20, 0.82, 0.80], // Tiang kanan
          [0.82, 0.80, 0.38, 0.95], // Lengkung bawah
        ];
      case '0':
        return [
          [0.50, 0.06, 0.84, 0.30],
          [0.84, 0.30, 0.84, 0.70],
          [0.84, 0.70, 0.50, 0.94],
          [0.50, 0.94, 0.16, 0.70],
          [0.16, 0.70, 0.16, 0.30],
          [0.16, 0.30, 0.50, 0.06],
        ];
      default:
        return [];
    }
  }

  /// Menghitung jarak terpendek dari titik (px, py) ke segmen garis (x1, y1)-(x2, y2)
  static double _distToSegment(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    final double dx = x2 - x1;
    final double dy = y2 - y1;
    final double l2 = dx * dx + dy * dy;
    if (l2 == 0) {
      return sqrt(pow(px - x1, 2) + pow(py - y1, 2));
    }
    final double t = ((px - x1) * dx + (py - y1) * dy) / l2;
    final double clampedT = t.clamp(0.0, 1.0);
    final double projX = x1 + clampedT * dx;
    final double projY = y1 + clampedT * dy;
    return sqrt(pow(px - projX, 2) + pow(py - projY, 2));
  }
}
