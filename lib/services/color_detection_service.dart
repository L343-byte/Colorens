import 'package:camera/camera.dart';
import 'package:colorlens/utils/color_utils.dart';

/// Layanan untuk mendeteksi warna dari gambar kamera.
class ColorDetectionService {
  /// Mendeteksi warna pada titik tertentu dari CameraImage (format YUV420).
  /// relativeX dan relativeY adalah koordinat yang dinormalisasi (0-1).
  static Map<String, dynamic> detectColorFromImage(
    CameraImage image,
    double relativeX,
    double relativeY,
  ) {
    // Validasi format
    if (image.format.group != ImageFormatGroup.yuv420) {
      return analyzeColorFromRgb(0, 0, 0);
    }

    final int width = image.width;
    final int height = image.height;

    // Titik pusat
    final int targetX = (width * relativeX).toInt().clamp(0, width - 1);
    final int targetY = (height * relativeY).toInt().clamp(0, height - 1);

    int totalR = 0;
    int totalG = 0;
    int totalB = 0;
    int sampleCount = 0;

    // Sample area 10x10 untuk stabilitas warna
    const int sampleSize = 5; // Radius 5 piksel (10x10 total area)

    final int startX = (targetX - sampleSize).clamp(0, width - 1);
    final int endX = (targetX + sampleSize).clamp(0, width - 1);
    final int startY = (targetY - sampleSize).clamp(0, height - 1);
    final int endY = (targetY + sampleSize).clamp(0, height - 1);

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int y = startY; y <= endY; y++) {
      for (int x = startX; x <= endX; x++) {
        final int yIndex = y * yRowStride + x;
        final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final int yValue = yPlane.bytes[yIndex];
        final int uValue = uPlane.bytes[uvIndex];
        final int vValue = vPlane.bytes[uvIndex];

        final (r, g, b) = _yuv420ToRgb(yValue, uValue, vValue);

        totalR += r;
        totalG += g;
        totalB += b;
        sampleCount++;
      }
    }

    if (sampleCount == 0) return analyzeColorFromRgb(0, 0, 0);

    final int avgR = totalR ~/ sampleCount;
    final int avgG = totalG ~/ sampleCount;
    final int avgB = totalB ~/ sampleCount;

    return analyzeColorFromRgb(avgR, avgG, avgB);
  }

  /// Konversi dari format YUV420 ke RGB.
  static (int r, int g, int b) _yuv420ToRgb(int y, int u, int v) {
    // Rumus standar YUV to RGB
    int c = y - 16;
    int d = u - 128;
    int e = v - 128;

    int r = (298 * c + 409 * e + 128) >> 8;
    int g = (298 * c - 100 * d - 208 * e + 128) >> 8;
    int b = (298 * c + 516 * d + 128) >> 8;

    return (r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
  }

  /// Menganalisis nilai RGB untuk mendapatkan nama, hex, kategori, kabel LAN TKJ, dan harmoni DKV.
  static Map<String, dynamic> analyzeColorFromRgb(int r, int g, int b) {
    final String name = ColorUtils.getColorNameIndonesian(r, g, b);
    final String hex = ColorUtils.rgbToHex(r, g, b);
    final String category = ColorUtils.getColorCategory(r, g, b);
    final LanCableMatch lanCable = ColorUtils.matchLanCable(r, g, b);
    final complementary = ColorUtils.getComplementaryColor(r, g, b);
    final cmyk = ColorUtils.rgbToCmyk(r, g, b);
    final temperature = ColorUtils.getColorTemperature(r, g, b);

    return {
      'r': r,
      'g': g,
      'b': b,
      'name': name,
      'hex': hex,
      'category': category,
      'lanCable': lanCable,
      'complementary': complementary,
      'cmyk': cmyk,
      'temperature': temperature,
    };
  }
}
