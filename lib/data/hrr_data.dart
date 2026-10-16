import 'dart:math';

import 'package:flutter/material.dart';
import 'package:colorlens/models/hrr_plate_model.dart';
import 'package:colorlens/models/ishihara_plate_model.dart';

/// Data & generator plate tes HRR (Hardy-Rand-Rittler) otentik berstandar klinis.
/// Menggunakan Poisson-disc packing multi-ukuran, piringan kartu persegi,
/// bentuk cincin terbuka (annulus), silang diagonal ✕, dan segitiga berongga (hollow triangle).
class HRRTestData {
  static final List<HRRPlate> _cachedPlates = _buildPlates();

  /// Mengambil daftar plate HRR yang diacak untuk setiap sesi tes/siswa.
  /// Menjaga alur klinis (Plate screening di awal, lalu diagnostic),
  /// dengan urutan soal dan pilihan jawaban yang diacak.
  static List<HRRPlate> getShuffledPlates() {
    final allPlates = List<HRRPlate>.from(plates);
    if (allPlates.isEmpty) return [];

    final random = Random();
    final demoPlate = allPlates.first;
    final otherScreening =
        allPlates.where((p) => p.type == 'screening' && p.id != 1).toList()
          ..shuffle(random);
    final diagnostic = allPlates.where((p) => p.type == 'diagnostic').toList()
      ..shuffle(random);

    final orderedPlates = [demoPlate, ...otherScreening, ...diagnostic];

    return orderedPlates.map((plate) {
      final shapes = plate.options.where((o) => o != 'Tidak Terlihat').toList()
        ..shuffle(random);
      final shuffledOptions = [...shapes, 'Tidak Terlihat'];
      return plate.copyWith(options: shuffledOptions);
    }).toList();
  }

  static List<HRRPlate> get plates => _cachedPlates;

  static List<HRRPlate> _buildPlates() {
    const List<String> defaultOptions = [
      'Lingkaran',
      'Segitiga',
      'Silang',
      'Tidak Terlihat',
    ];

    return [
      HRRPlate(
        id: 1,
        type: 'screening',
        targetShape: 'circle',
        correctAnswer: 'Lingkaran',
        options: defaultOptions,
        cvdType: 'screening',
        dots: _generatePlateDots(shape: 'circle', palette: 'orange', seed: 101),
      ),
      HRRPlate(
        id: 2,
        type: 'screening',
        targetShape: 'triangle',
        correctAnswer: 'Segitiga',
        options: defaultOptions,
        cvdType: 'screening',
        dots: _generatePlateDots(
          shape: 'triangle',
          palette: 'orange',
          orient: 'up',
          seed: 202,
        ),
      ),
      HRRPlate(
        id: 3,
        type: 'screening',
        targetShape: 'cross',
        correctAnswer: 'Silang',
        options: defaultOptions,
        cvdType: 'screening',
        dots: _generatePlateDots(
          shape: 'cross',
          palette: 'pea_green',
          seed: 303,
        ),
      ),
      HRRPlate(
        id: 4,
        type: 'screening',
        targetShape: 'circle',
        correctAnswer: 'Lingkaran',
        options: defaultOptions,
        cvdType: 'screening',
        dots: _generatePlateDots(
          shape: 'circle',
          palette: 'pea_green',
          seed: 404,
        ),
      ),
      HRRPlate(
        id: 5,
        type: 'diagnostic',
        targetShape: 'triangle',
        correctAnswer: 'Segitiga',
        options: defaultOptions,
        cvdType: 'protan',
        dots: _generatePlateDots(
          shape: 'triangle',
          palette: 'blue',
          orient: 'left', // Mengarah ke kiri persis seperti foto referensi buku HRR asli
          seed: 505,
        ),
      ),
      HRRPlate(
        id: 6,
        type: 'diagnostic',
        targetShape: 'cross',
        correctAnswer: 'Silang',
        options: defaultOptions,
        cvdType: 'deutan',
        dots: _generatePlateDots(shape: 'cross', palette: 'magenta', seed: 606),
      ),
      HRRPlate(
        id: 7,
        type: 'diagnostic',
        targetShape: 'circle',
        correctAnswer: 'Lingkaran',
        options: defaultOptions,
        cvdType: 'tritan',
        dots: _generatePlateDots(shape: 'circle', palette: 'violet', seed: 707),
      ),
      HRRPlate(
        id: 8,
        type: 'diagnostic',
        targetShape: 'triangle',
        correctAnswer: 'Segitiga',
        options: defaultOptions,
        cvdType: 'protan',
        dots: _generatePlateDots(
          shape: 'triangle',
          palette: 'cyan',
          orient: 'up',
          seed: 808,
        ),
      ),
    ];
  }

  // --- Palet Warna Klinis HRR 4th Edition ---
  static const List<Color> _neutralGreys = [
    Color(0xFF4B4B4B),
    Color(0xFF5F5F5F),
    Color(0xFF7D7D7D),
    Color(0xFF969696),
    Color(0xFFAFAFAF),
    Color(0xFFC8C8C8),
    Color(0xFFDADADA),
    Color(0xFFE6E6E6),
  ];

  static const Map<String, List<Color>> _palettes = {
    'orange': [
      Color(0xFFB58A68),
      Color(0xFFA87D5A),
      Color(0xFFC49875),
      Color(0xFF966F4E),
      Color(0xFFD2A885),
      Color(0xFF8A6243),
    ],
    'pea_green': [
      Color(0xFF7A8C70),
      Color(0xFF889C7E),
      Color(0xFF6B7E62),
      Color(0xFF98AC8E),
      Color(0xFF5D7054),
      Color(0xFFA6BA9C),
    ],
    'blue': [
      Color(0xFF6A8294),
      Color(0xFF7892A6),
      Color(0xFF5C7282),
      Color(0xFF88A2B8),
      Color(0xFF4E6272),
      Color(0xFF96B0C6),
    ],
    'magenta': [
      Color(0xFF9E7585),
      Color(0xFFB08596),
      Color(0xFF8D6575),
      Color(0xFFC095A6),
      Color(0xFF7D5565),
      Color(0xFFCDA4B4),
    ],
    'violet': [
      Color(0xFF857294),
      Color(0xFF9580A6),
      Color(0xFF756284),
      Color(0xFFA590B6),
      Color(0xFF655274),
      Color(0xFFB29EC3),
    ],
    'cyan': [
      Color(0xFF608E94),
      Color(0xFF70A0A6),
      Color(0xFF507E84),
      Color(0xFF80B2B8),
      Color(0xFF426E74),
      Color(0xFF90C2C8),
    ],
  };

  /// Generator titik multi-ukuran berbasis Poisson-disc packing
  /// Generator titik multi-ukuran berbasis Poisson-disc packing dengan geometri bentuk presisi klinis.
  static List<DotData> _generatePlateDots({
    required String shape,
    required String palette,
    String orient = 'up',
    required int seed,
  }) {
    final rand = Random(seed);
    const double margin = 0.03;

    // Tingkatan ukuran titik: Besar (22%), Sedang (45%), Kecil (33%)
    final List<(double, double)> tierWeights = [
      (0.024, 0.22),
      (0.016, 0.45),
      (0.010, 0.33),
    ];

    final List<(double, double, double)> placedDots = [];
    int attempts = 0;

    // Koordinat Segitiga Sama Sisi (Equilateral Triangle) presisi tinggi
    const double rTri = 0.34;
    final Offset p1, p2, p3;
    if (orient == 'left') {
      p1 = const Offset(0.5 - rTri, 0.5);
      p2 = const Offset(0.5 + rTri * 0.5, 0.5 - rTri * 0.8660254);
      p3 = const Offset(0.5 + rTri * 0.5, 0.5 + rTri * 0.8660254);
    } else {
      p1 = const Offset(0.5, 0.5 - rTri);
      p2 = const Offset(0.5 - rTri * 0.8660254, 0.5 + rTri * 0.5);
      p3 = const Offset(0.5 + rTri * 0.8660254, 0.5 + rTri * 0.5);
    }

    // Fungsi detektor batas bentuk geometris klinis
    bool isInsideShape(double px, double py) {
      final double dx = px - 0.5;
      final double dy = py - 0.5;
      final double dist = sqrt(dx * dx + dy * dy);

      if (shape == 'circle') {
        // Cincin Lingkaran (Annulus) simetris dan proporsional
        return dist >= 0.16 && dist <= 0.33;
      } else if (shape == 'cross') {
        // Silang Diagonal ✕ dengan lengan balok persegi rata dan simetris
        const double invSqrt2 = 0.7071067811865475;
        final double u1 = (dx + dy) * invSqrt2;
        final double v1 = (dx - dy) * invSqrt2;
        final double u2 = (dx - dy) * invSqrt2;
        final double v2 = (dx + dy) * invSqrt2;
        const double armL = 0.29;
        const double armW = 0.075;
        return (u1.abs() <= armL && v1.abs() <= armW) ||
            (u2.abs() <= armL && v2.abs() <= armW);
      } else if (shape == 'triangle') {
        // Segitiga Sama Sisi Berongga Tebal dengan sudut tajam rapi
        final double d1 = _distToSegment(px, py, p1.dx, p1.dy, p2.dx, p2.dy);
        final double d2 = _distToSegment(px, py, p2.dx, p2.dy, p3.dx, p3.dy);
        final double d3 = _distToSegment(px, py, p3.dx, p3.dy, p1.dx, p1.dy);
        final double minD = min(d1, min(d2, d3));
        return minD <= 0.068;
      }
      return false;
    }

    // Pass 1: Sebar titik utama secara merata
    while (attempts < 15000 && placedDots.length < 700) {
      attempts++;
      final roll = rand.nextDouble();
      final double baseR;
      if (roll < tierWeights[0].$2) {
        baseR = tierWeights[0].$1;
      } else if (roll < tierWeights[0].$2 + tierWeights[1].$2) {
        baseR = tierWeights[1].$1;
      } else {
        baseR = tierWeights[2].$1;
      }
      final radius = baseR * (0.90 + rand.nextDouble() * 0.20);
      final x =
          margin + radius + rand.nextDouble() * (1.0 - 2 * (margin + radius));
      final y =
          margin + radius + rand.nextDouble() * (1.0 - 2 * (margin + radius));

      bool collides = false;
      for (final dot in placedDots) {
        final dx = x - dot.$1;
        final dy = y - dot.$2;
        if (sqrt(dx * dx + dy * dy) < (radius + dot.$3 + 0.002)) {
          collides = true;
          break;
        }
      }

      if (!collides) {
        placedDots.add((x, y, radius));
        attempts = 0;
      }
    }

    // Pass 2: Isi celah mikro dengan titik-titik kecil untuk kerapatan visual
    int gapAttempts = 0;
    while (gapAttempts < 4000 && placedDots.length < 850) {
      gapAttempts++;
      final radius = 0.007 + rand.nextDouble() * 0.004;
      final x =
          margin + radius + rand.nextDouble() * (1.0 - 2 * (margin + radius));
      final y =
          margin + radius + rand.nextDouble() * (1.0 - 2 * (margin + radius));

      bool collides = false;
      for (final dot in placedDots) {
        final dx = x - dot.$1;
        final dy = y - dot.$2;
        if (sqrt(dx * dx + dy * dy) < (radius + dot.$3 + 0.0018)) {
          collides = true;
          break;
        }
      }

      if (!collides) {
        placedDots.add((x, y, radius));
        gapAttempts = 0;
      }
    }

    final shapeColors = _palettes[palette] ?? _palettes['orange']!;
    final List<DotData> result = [];

    // Pewarnaan dengan 5-Point Sub-Sampling (Anti-Aliased Edge) agar bentuk rapi & tidak bergerigi
    for (final dot in placedDots) {
      final double x = dot.$1;
      final double y = dot.$2;
      final double r = dot.$3;

      int inCount = 0;
      final samples = [
        (x, y),
        (x + r * 0.6, y),
        (x - r * 0.6, y),
        (x, y + r * 0.6),
        (x, y - r * 0.6),
      ];
      for (final s in samples) {
        if (isInsideShape(s.$1, s.$2)) inCount++;
      }

      final bool inShape = inCount >= 3;
      final Color color;
      if (inShape) {
        // 10% peluang menjadi titik abu-abu netral untuk memecah kontur tepi yang terlalu kentara
        if (rand.nextDouble() < 0.10) {
          color = _neutralGreys[rand.nextInt(_neutralGreys.length)];
        } else {
          color = shapeColors[rand.nextInt(shapeColors.length)];
        }
      } else {
        // 5% peluang pengacau (confuser) halus pada background
        if (rand.nextDouble() < 0.05) {
          color = shapeColors[rand.nextInt(shapeColors.length)];
        } else {
          color = _neutralGreys[rand.nextInt(_neutralGreys.length)];
        }
      }

      result.add(DotData(x: x, y: y, radius: r, color: color));
    }

    return result;
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
    final dx = x2 - x1;
    final dy = y2 - y1;
    final l2 = dx * dx + dy * dy;
    if (l2 == 0) {
      return sqrt((px - x1) * (px - x1) + (py - y1) * (py - y1));
    }
    final t = ((px - x1) * dx + (py - y1) * dy) / l2;
    final clampedT = t.clamp(0.0, 1.0);
    final projX = x1 + clampedT * dx;
    final projY = y1 + clampedT * dy;
    final distX = px - projX;
    final distY = py - projY;
    return sqrt(distX * distX + distY * distY);
  }
}
