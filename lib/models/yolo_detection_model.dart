import 'package:flutter/material.dart';

/// Model untuk objek yang terdeteksi oleh AI YOLO beserta analisis warnanya.
class YoloDetectedObject {
  final String id;
  final String label;
  final String category;
  final double confidence;

  // Koordinat relatif layar (0.0 sampai 1.0)
  final double left;
  final double top;
  final double width;
  final double height;

  // Analisis warna spesifik di dalam bounding box objek
  final Color color;
  final String colorName;
  final String hex;
  final int r;
  final int g;
  final int b;

  // Tips adaptasi buta warna untuk objek tersebut
  final String cvdTip;

  const YoloDetectedObject({
    required this.id,
    required this.label,
    required this.category,
    required this.confidence,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.color,
    required this.colorName,
    required this.hex,
    required this.r,
    required this.g,
    required this.b,
    required this.cvdTip,
  });

  Rect toRect(Size screenSize) {
    return Rect.fromLTWH(
      left * screenSize.width,
      top * screenSize.height,
      width * screenSize.width,
      height * screenSize.height,
    );
  }
}
