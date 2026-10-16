import 'dart:math';

import 'package:flutter/material.dart';

/// Model hasil pencocokan kabel LAN UTP untuk jurusan TKJ
class LanCableMatch {
  final String name;
  final int t568bPin;
  final int t568aPin;
  final String wireColorDesc;
  final String functionDesc;
  final bool isCvdRisk;
  final String cvdWarning;
  final Color referenceColor;

  const LanCableMatch({
    required this.name,
    required this.t568bPin,
    required this.t568aPin,
    required this.wireColorDesc,
    required this.functionDesc,
    required this.isCvdRisk,
    required this.cvdWarning,
    required this.referenceColor,
  });
}

/// Utility class for color operations, conversions, TKJ, and DKV analysis.
class ColorUtils {
  /// Converts RGB to Hex string (#RRGGBB).
  static String rgbToHex(int r, int g, int b) {
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// Converts Hex string to RGB map.
  static Map<String, int> hexToRgb(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    }
    return {
      'r': int.parse(hex.substring(0, 2), radix: 16),
      'g': int.parse(hex.substring(2, 4), radix: 16),
      'b': int.parse(hex.substring(4, 6), radix: 16),
    };
  }

  /// Calculates Euclidean distance between two RGB colors.
  static double colorDistance(int r1, int g1, int b1, int r2, int g2, int b2) {
    return sqrt(pow(r2 - r1, 2) + pow(g2 - g1, 2) + pow(b2 - b1, 2));
  }

  /// Konversi RGB ke perkiraan persentase CMYK (untuk kebutuhan cetak DKV).
  static Map<String, int> rgbToCmyk(int r, int g, int b) {
    if (r == 0 && g == 0 && b == 0) {
      return {'c': 0, 'm': 0, 'y': 0, 'k': 100};
    }
    final double rNorm = r / 255.0;
    final double gNorm = g / 255.0;
    final double bNorm = b / 255.0;

    final double k = 1.0 - [rNorm, gNorm, bNorm].reduce(max);
    if ((1.0 - k) <= 0.0001) {
      return {'c': 0, 'm': 0, 'y': 0, 'k': 100};
    }

    final double c = (1.0 - rNorm - k) / (1.0 - k);
    final double m = (1.0 - gNorm - k) / (1.0 - k);
    final double y = (1.0 - bNorm - k) / (1.0 - k);

    return {
      'c': (c * 100).round().clamp(0, 100),
      'm': (m * 100).round().clamp(0, 100),
      'y': (y * 100).round().clamp(0, 100),
      'k': (k * 100).round().clamp(0, 100),
    };
  }

  /// Menghitung warna komplementer (kontras harmoni lingkaran warna 180° untuk DKV).
  static Color getComplementaryColor(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    final compHue = (hsv[0] + 180.0) % 360.0;
    return _hsvToColor(compHue, hsv[1], hsv[2]);
  }

  /// Menentukan temperatur warna: Hangat, Dingin, atau Netral.
  static String getColorTemperature(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    final h = hsv[0];
    final s = hsv[1];
    if (s < 0.15) return 'Netral (Neutral)';
    if ((h >= 0 && h <= 70) || (h >= 330 && h <= 360)) {
      return 'Hangat (Warm)';
    }
    return 'Dingin (Cool)';
  }

  /// Warna teks berbobot kontras (Hitam / Putih) berdasarkan luminance WCAG.
  static Color getContrastTextColor(int r, int g, int b) {
    final double luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.55 ? Colors.black87 : Colors.white;
  }

  /// Kategori warna umum (Primer/Sekunder/Tersier/Netral).
  static String getColorCategory(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    final h = hsv[0];
    final s = hsv[1];
    final v = hsv[2];

    if (s < 0.15 || v < 0.15) return 'Netral (Achromatic)';

    // Klasifikasi warna dasar seni rupa & desain
    if ((h >= 345 || h < 15) || (h >= 210 && h < 250) || (h >= 45 && h < 65)) {
      return 'Warna Primer (Merah/Biru/Kuning)';
    } else if ((h >= 15 && h < 45) ||
        (h >= 80 && h < 160) ||
        (h >= 270 && h < 320)) {
      return 'Warna Sekunder (Oranye/Hijau/Ungu)';
    }
    return 'Warna Tersier / Variasi';
  }

  /// Mencocokkan warna ke standar 8 kabel LAN UTP (T568A & T568B) untuk anak TKJ.
  static LanCableMatch matchLanCable(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    final double h = hsv[0];
    final double s = hsv[1];
    final double v = hsv[2];

    // Daftar 8 kabel UTP standar dengan karakteristik HSV dan RGB
    // 1. Putih-Oranye: Seringkali bernilai V tinggi dengan sedikit semburat oranye
    // 2. Oranye: Hue 15-40, S sedang-tinggi
    // 3. Putih-Hijau: V tinggi, sedikit semburat hijau
    // 4. Biru: Hue 190-240, S sedang-tinggi
    // 5. Putih-Biru: V tinggi, sedikit semburat biru
    // 6. Hijau: Hue 80-165, S sedang-tinggi
    // 7. Putih-Coklat: V tinggi, sedikit semburat coklat
    // 8. Coklat: Hue 15-45, V gelap (0.18 - 0.55)

    // Evaluasi kabel belang (Putih-X) bila saturation rendah/sedang dan value terang
    final bool isStripeWhite = (s < 0.45 && v > 0.65) || (s < 0.35 && v > 0.50);

    if (isStripeWhite) {
      if (h >= 170 && h <= 250) {
        return const LanCableMatch(
          name: 'Putih-Biru (White-Blue)',
          t568bPin: 5,
          t568aPin: 5,
          wireColorDesc: 'Kabel putih bergaris biru',
          functionDesc: 'Telephony / PoE Pair (Pin 5)',
          isCvdRisk: false,
          cvdWarning: 'Relatif aman. Berada di posisi tengah bersebelahan dengan Biru murni.',
          referenceColor: Color(0xFFC8E1FF),
        );
      } else if (h >= 65 && h <= 170) {
        return const LanCableMatch(
          name: 'Putih-Hijau (White-Green)',
          t568bPin: 3,
          t568aPin: 1,
          wireColorDesc: 'Kabel putih bergaris hijau',
          functionDesc: 'Data Receive Positif (RX+ T568B) / TX+ (T568A)',
          isCvdRisk: true,
          cvdWarning: '⚠️ Perhatian CVD: Sering tertukar dengan Putih-Oranye atau Putih-Coklat!',
          referenceColor: Color(0xFFC7F3D6),
        );
      } else if (h >= 10 && h < 65) {
        // Bedakan Putih-Oranye vs Putih-Coklat
        if (v > 0.78 || h >= 25) {
          return const LanCableMatch(
            name: 'Putih-Oranye (White-Orange)',
            t568bPin: 1,
            t568aPin: 3,
            wireColorDesc: 'Kabel putih bergaris oranye',
            functionDesc: 'Data Transmit Positif (TX+ T568B) / RX+ (T568A)',
            isCvdRisk: true,
            cvdWarning: '⚠️ Perhatian CVD: Kabel Pin 1 T568B (paling kiri saat klip RJ-45 di bawah).',
            referenceColor: Color(0xFFFFDFC4),
          );
        } else {
          return const LanCableMatch(
            name: 'Putih-Coklat (White-Brown)',
            t568bPin: 7,
            t568aPin: 7,
            wireColorDesc: 'Kabel putih bergaris coklat',
            functionDesc: 'Gigabit Spare / Ground (Pin 7 T568B)',
            isCvdRisk: true,
            cvdWarning: '⚠️ Perhatian CVD: Sering tertukar dengan Putih-Hijau oleh penderita Buta Warna!',
            referenceColor: Color(0xFFE4D5C7),
          );
        }
      }
    }

    // Evaluasi kabel warna solid
    // HIJAU (Green) vs COKLAT (Brown) - KRUSIAL untuk penderita Buta Warna Parsial!
    if (h >= 75 && h <= 165) {
      return const LanCableMatch(
        name: 'Hijau (Green Solid)',
        t568bPin: 6,
        t568aPin: 2,
        wireColorDesc: 'Kabel hijau solid',
        functionDesc: 'Data Receive Negatif (RX- T568B) / Pin 2 (T568A)',
        isCvdRisk: true,
        cvdWarning: '🚨 KRUSIAL TKJ: Ini HIJAU (Pin 6), BUKAN Coklat! Jangan salah pasang di Pin 8.',
        referenceColor: Color(0xFF2E7D32),
      );
    }

    // COKLAT (Brown)
    if (h >= 15 && h <= 45 && v < 0.60) {
      return const LanCableMatch(
        name: 'Coklat (Brown Solid)',
        t568bPin: 8,
        t568aPin: 8,
        wireColorDesc: 'Kabel coklat solid',
        functionDesc: 'Gigabit Spare / Ground (Pin 8 T568B - Paling Kanan)',
        isCvdRisk: true,
        cvdWarning: '🚨 KRUSIAL TKJ: Ini COKLAT (Pin 8 paling kanan), BUKAN Hijau (Pin 6)!',
        referenceColor: Color(0xFF5D4037),
      );
    }

    // BIRU (Blue)
    if (h >= 180 && h <= 255) {
      return const LanCableMatch(
        name: 'Biru (Blue Solid)',
        t568bPin: 4,
        t568aPin: 4,
        wireColorDesc: 'Kabel biru solid',
        functionDesc: 'Telephony / PoE Positif (Pin 4)',
        isCvdRisk: false,
        cvdWarning: 'Relatif mudah dikenali penderita buta warna merah-hijau.',
        referenceColor: Color(0xFF1976D2),
      );
    }

    // ORANYE (Orange)
    if ((h >= 15 && h < 45) && v >= 0.60) {
      return const LanCableMatch(
        name: 'Oranye (Orange Solid)',
        t568bPin: 2,
        t568aPin: 6,
        wireColorDesc: 'Kabel oranye solid',
        functionDesc: 'Data Transmit Negatif (TX- T568B) / RX- (T568A)',
        isCvdRisk: true,
        cvdWarning: '⚠️ Perhatian: Jangan tertukar dengan Coklat di ruangan redup! Posisi Pin 2.',
        referenceColor: Color(0xFFEF6C00),
      );
    }

    // Default ke perhitungan Euclidean RGB terdekat bila di luar ambang HSV
    return _matchNearestLanCableEuclidean(r, g, b);
  }

  static LanCableMatch _matchNearestLanCableEuclidean(int r, int g, int b) {
    final candidates = [
      (
        const LanCableMatch(
          name: 'Putih-Oranye',
          t568bPin: 1,
          t568aPin: 3,
          wireColorDesc: 'Kabel putih bergaris oranye',
          functionDesc: 'Data TX+ (Pin 1 T568B)',
          isCvdRisk: true,
          cvdWarning: 'Posisi Pin 1 standar T568B.',
          referenceColor: Color(0xFFFFDFC4),
        ),
        250,
        220,
        195,
      ),
      (
        const LanCableMatch(
          name: 'Oranye Solid',
          t568bPin: 2,
          t568aPin: 6,
          wireColorDesc: 'Kabel oranye solid',
          functionDesc: 'Data TX- (Pin 2 T568B)',
          isCvdRisk: true,
          cvdWarning: 'Posisi Pin 2 standar T568B.',
          referenceColor: Color(0xFFEF6C00),
        ),
        239,
        108,
        0,
      ),
      (
        const LanCableMatch(
          name: 'Putih-Hijau',
          t568bPin: 3,
          t568aPin: 1,
          wireColorDesc: 'Kabel putih bergaris hijau',
          functionDesc: 'Data RX+ (Pin 3 T568B)',
          isCvdRisk: true,
          cvdWarning: '⚠️ Waspada tertukar dengan Putih-Coklat.',
          referenceColor: Color(0xFFC7F3D6),
        ),
        210,
        245,
        220,
      ),
      (
        const LanCableMatch(
          name: 'Biru Solid',
          t568bPin: 4,
          t568aPin: 4,
          wireColorDesc: 'Kabel biru solid',
          functionDesc: 'PoE / Telephony (Pin 4)',
          isCvdRisk: false,
          cvdWarning: 'Pin 4 di tengah konektor RJ45.',
          referenceColor: Color(0xFF1976D2),
        ),
        25,
        118,
        210,
      ),
      (
        const LanCableMatch(
          name: 'Putih-Biru',
          t568bPin: 5,
          t568aPin: 5,
          wireColorDesc: 'Kabel putih bergaris biru',
          functionDesc: 'PoE / Telephony (Pin 5)',
          isCvdRisk: false,
          cvdWarning: 'Pin 5 di tengah bersebelahan dengan Biru.',
          referenceColor: Color(0xFFC8E1FF),
        ),
        215,
        230,
        255,
      ),
      (
        const LanCableMatch(
          name: 'Hijau Solid',
          t568bPin: 6,
          t568aPin: 2,
          wireColorDesc: 'Kabel hijau solid',
          functionDesc: 'Data RX- (Pin 6 T568B)',
          isCvdRisk: true,
          cvdWarning: '🚨 KRUSIAL: Ini Hijau (Pin 6), bukan Coklat!',
          referenceColor: Color(0xFF2E7D32),
        ),
        46,
        125,
        50,
      ),
      (
        const LanCableMatch(
          name: 'Putih-Coklat',
          t568bPin: 7,
          t568aPin: 7,
          wireColorDesc: 'Kabel putih bergaris coklat',
          functionDesc: 'Ground / Spare (Pin 7 T568B)',
          isCvdRisk: true,
          cvdWarning: '⚠️ Waspada tertukar dengan Putih-Hijau.',
          referenceColor: Color(0xFFE4D5C7),
        ),
        228,
        213,
        199,
      ),
      (
        const LanCableMatch(
          name: 'Coklat Solid',
          t568bPin: 8,
          t568aPin: 8,
          wireColorDesc: 'Kabel coklat solid',
          functionDesc: 'Ground / Spare (Pin 8 T568B - Paling Kanan)',
          isCvdRisk: true,
          cvdWarning:
              '🚨 KRUSIAL: Ini Coklat (Pin 8 paling kanan), bukan Hijau!',
          referenceColor: Color(0xFF5D4037),
        ),
        93,
        64,
        55,
      ),
    ];

    LanCableMatch bestMatch = candidates.first.$1;
    double minDistance = double.infinity;

    for (final candidate in candidates) {
      final double dist = colorDistance(
        r,
        g,
        b,
        candidate.$2,
        candidate.$3,
        candidate.$4,
      );
      if (dist < minDistance) {
        minDistance = dist;
        bestMatch = candidate.$1;
      }
    }

    return bestMatch;
  }

  /// Gets Indonesian color name based on RGB values using HSV.
  static String getColorNameIndonesian(int r, int g, int b) {
    final hsv = _rgbToHsv(r, g, b);
    final h = hsv[0];
    final s = hsv[1];
    final v = hsv[2];

    if (v < 0.15) return 'Hitam';
    if (v > 0.90 && s < 0.12) return 'Putih';
    if (s < 0.15) {
      if (v < 0.40) return 'Abu-abu Tua';
      if (v > 0.70) return 'Abu-abu Muda';
      return 'Abu-abu';
    }

    if (h < 15 || h >= 345) {
      if (v < 0.50) return 'Merah Tua / Marun';
      if (s < 0.55 && v > 0.80) return 'Merah Muda (Pink)';
      return 'Merah';
    }
    if (h >= 15 && h < 45) {
      if (v < 0.55) return 'Coklat Tua';
      if (s < 0.60 && v > 0.70) return 'Coklat Muda / Krem';
      if (v < 0.70) return 'Coklat';
      return 'Oranye';
    }
    if (h >= 45 && h < 70) {
      if (s > 0.70 && v > 0.70) return 'Emas (Gold)';
      if (v < 0.60) return 'Kuning Tua / Mustard';
      return 'Kuning';
    }
    if (h >= 70 && h < 165) {
      if (v < 0.40) return 'Hijau Tua';
      if (v > 0.80 && s < 0.60) return 'Hijau Muda / Lime';
      return 'Hijau';
    }
    if (h >= 165 && h < 200) {
      return 'Cyan / Biru Toska';
    }
    if (h >= 200 && h < 260) {
      if (v < 0.35) return 'Biru Dongker (Navy)';
      if (v < 0.55) return 'Biru Tua';
      if (v > 0.80 && s < 0.60) return 'Biru Muda / Langit';
      return 'Biru';
    }
    if (h >= 260 && h < 315) {
      if (v > 0.80 && s < 0.45) return 'Ungu Muda (Lavender)';
      return 'Ungu';
    }
    if (h >= 315 && h < 345) {
      return 'Magenta';
    }

    return 'Tidak Diketahui';
  }

  static List<double> _rgbToHsv(int r, int g, int b) {
    double rNorm = r / 255.0;
    double gNorm = g / 255.0;
    double bNorm = b / 255.0;

    double cMax = [rNorm, gNorm, bNorm].reduce(max);
    double cMin = [rNorm, gNorm, bNorm].reduce(min);
    double diff = cMax - cMin;

    double h = 0.0;
    if (diff == 0.0) {
      h = 0.0;
    } else if (cMax == rNorm) {
      h = 60.0 * (((gNorm - bNorm) / diff) % 6.0);
    } else if (cMax == gNorm) {
      h = 60.0 * (((bNorm - rNorm) / diff) + 2.0);
    } else {
      h = 60.0 * (((rNorm - gNorm) / diff) + 4.0);
    }
    if (h < 0.0) {
      h += 360.0;
    }

    double s = cMax == 0.0 ? 0.0 : diff / cMax;
    double v = cMax;

    return [h, s, v];
  }

  static Color _hsvToColor(double h, double s, double v) {
    final double c = v * s;
    final double x = c * (1.0 - (((h / 60.0) % 2.0) - 1.0).abs());
    final double m = v - c;

    double rPrime = 0;
    double gPrime = 0;
    double bPrime = 0;

    if (h >= 0 && h < 60) {
      rPrime = c;
      gPrime = x;
    } else if (h >= 60 && h < 120) {
      rPrime = x;
      gPrime = c;
    } else if (h >= 120 && h < 180) {
      gPrime = c;
      bPrime = x;
    } else if (h >= 180 && h < 240) {
      gPrime = x;
      bPrime = c;
    } else if (h >= 240 && h < 300) {
      rPrime = x;
      bPrime = c;
    } else {
      rPrime = c;
      bPrime = x;
    }

    final int r = ((rPrime + m) * 255).round().clamp(0, 255);
    final int g = ((gPrime + m) * 255).round().clamp(0, 255);
    final int b = ((bPrime + m) * 255).round().clamp(0, 255);

    return Color.fromARGB(255, r, g, b);
  }
}
