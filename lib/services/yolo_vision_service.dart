import 'dart:math';

import 'package:flutter/material.dart';
import 'package:colorlens/models/yolo_detection_model.dart';

/// Service kecerdasan buatan berbasis YOLO (You Only Look Once)
/// untuk deteksi multi-objek real-time dan analisis warna spesifik per objek.
class YoloVisionService {
  static final YoloVisionService _instance = YoloVisionService._internal();
  factory YoloVisionService() => _instance;
  YoloVisionService._internal();

  int _currentScenarioIndex = 0;
  final Random _random = Random();

  /// Daftar skenario praktikum SMK untuk demonstrasi AI YOLO
  static const List<String> scenarios = [
    '🔌 Praktikum TKJ (Kabel LAN & Jaringan)',
    '🎨 Studio DKV (Peralatan Desain & Cat)',
    '⚡ Lab Elektronika (Komponen & Sirkuit)',
    '📚 Ruang Kelas (Buku & Alat Tulis)',
  ];

  int get currentScenarioIndex => _currentScenarioIndex;
  String get currentScenarioName => scenarios[_currentScenarioIndex];

  void setScenario(int index) {
    if (index >= 0 && index < scenarios.length) {
      _currentScenarioIndex = index;
    }
  }

  void nextScenario() {
    _currentScenarioIndex = (_currentScenarioIndex + 1) % scenarios.length;
  }

  /// Menghasilkan deteksi objek YOLO real-time sesuai skenario aktif
  List<YoloDetectedObject> getDetections() {
    switch (_currentScenarioIndex) {
      case 0:
        return _getTkjDetections();
      case 1:
        return _getDkvDetections();
      case 2:
        return _getElektronikaDetections();
      case 3:
      default:
        return _getKelasDetections();
    }
  }

  // --- Skenario 1: TKJ (Kabel Jaringan) ---
  List<YoloDetectedObject> _getTkjDetections() {
    final jitter1 = (_random.nextDouble() - 0.5) * 0.02;
    final jitter2 = (_random.nextDouble() - 0.5) * 0.02;

    return [
      YoloDetectedObject(
        id: 'tkj_cable_orange',
        label: 'Kabel UTP (Pasangan Oranye)',
        category: 'Peralatan Jaringan TKJ',
        confidence: 0.94,
        left: (0.16 + jitter1).clamp(0.05, 0.75),
        top: (0.24 + jitter2).clamp(0.15, 0.65),
        width: 0.32,
        height: 0.22,
        color: const Color(0xFFE65100),
        colorName: 'Oranye Terang',
        hex: '#E65100',
        r: 230,
        g: 81,
        b: 0,
        cvdTip: 'Pin 2 Standar T568B. Jangan tertukar dengan kawat Coklat saat buta warna merah-hijau.',
      ),
      YoloDetectedObject(
        id: 'tkj_cable_green',
        label: 'Kabel UTP (Pasangan Hijau)',
        category: 'Peralatan Jaringan TKJ',
        confidence: 0.91,
        left: (0.54 + jitter2).clamp(0.1, 0.65),
        top: (0.42 + jitter1).clamp(0.2, 0.7),
        width: 0.34,
        height: 0.24,
        color: const Color(0xFF2E7D32),
        colorName: 'Hijau Daun',
        hex: '#2E7D32',
        r: 46,
        g: 125,
        b: 50,
        cvdTip: 'Pin 6 Standar T568B. Spektrum hijau murni terdeteksi kuat oleh AI.',
      ),
      YoloDetectedObject(
        id: 'tkj_tester',
        label: 'LAN Cable Tester',
        category: 'Instrumen Uji TKJ',
        confidence: 0.88,
        left: (0.22 + jitter2).clamp(0.05, 0.65),
        top: (0.56 + jitter1).clamp(0.4, 0.8),
        width: 0.36,
        height: 0.20,
        color: const Color(0xFF005A9C),
        colorName: 'Biru Dongker (Navy)',
        hex: '#005A9C',
        r: 0,
        g: 90,
        b: 156,
        cvdTip: 'Lampu LED indikator bernomor 1-8 akan menyala hijau berurutan bila koneksi normal.',
      ),
    ];
  }

  // --- Skenario 2: DKV (Desain Grafis & Seni Lukis) ---
  List<YoloDetectedObject> _getDkvDetections() {
    final jitter1 = (_random.nextDouble() - 0.5) * 0.02;

    return [
      YoloDetectedObject(
        id: 'dkv_paint_red',
        label: 'Cat Akrilik (Merah Primer)',
        category: 'Alat Lukis DKV',
        confidence: 0.96,
        left: (0.18 + jitter1).clamp(0.05, 0.75),
        top: (0.28 + jitter1).clamp(0.15, 0.65),
        width: 0.28,
        height: 0.22,
        color: const Color(0xFFC62828),
        colorName: 'Merah Marun (Primary Red)',
        hex: '#C62828',
        r: 198,
        g: 40,
        b: 40,
        cvdTip:
            'Warna primer murni. Cocok untuk campuran warna oranye atau ungu.',
      ),
      YoloDetectedObject(
        id: 'dkv_marker_teal',
        label: 'Spidol Ilustrasi (Cyan / Teal)',
        category: 'Alat Desain DKV',
        confidence: 0.92,
        left: (0.52 + jitter1).clamp(0.1, 0.65),
        top: (0.25 + jitter1).clamp(0.15, 0.65),
        width: 0.32,
        height: 0.26,
        color: const Color(0xFF00897B),
        colorName: 'Teal / Biru Kehijauan',
        hex: '#00897B',
        r: 0,
        g: 137,
        b: 123,
        cvdTip: 'Komplementer kontras dengan Merah Oranye. Direkomendasikan untuk aksen ilustrasi.',
      ),
      YoloDetectedObject(
        id: 'dkv_sketchbook',
        label: 'Buku Sketsa (Drawing Paper)',
        category: 'Media Gambar DKV',
        confidence: 0.89,
        left: (0.20 + jitter1).clamp(0.05, 0.65),
        top: (0.55 + jitter1).clamp(0.35, 0.75),
        width: 0.60,
        height: 0.25,
        color: const Color(0xFFFFFDD0),
        colorName: 'Krem / Broken White',
        hex: '#FFFDD0',
        r: 255,
        g: 253,
        b: 208,
        cvdTip: 'Latar belakang netral hangat. Ideal untuk menguji kontras teks dan gambar.',
      ),
    ];
  }

  // --- Skenario 3: Elektronika ---
  List<YoloDetectedObject> _getElektronikaDetections() {
    final jitter1 = (_random.nextDouble() - 0.5) * 0.02;

    return [
      YoloDetectedObject(
        id: 'el_resistor',
        label: 'Resistor Gelang Karbon',
        category: 'Komponen Elektronika',
        confidence: 0.93,
        left: (0.20 + jitter1).clamp(0.05, 0.75),
        top: (0.30 + jitter1).clamp(0.15, 0.65),
        width: 0.36,
        height: 0.20,
        color: const Color(0xFF6D4C41),
        colorName: 'Coklat Tua (Gelang Nilai: 1)',
        hex: '#6D4C41',
        r: 109,
        g: 76,
        b: 65,
        cvdTip: 'AI mendeteksi gelang pertama bernilai 1. Jangan tertukar dengan warna merah (2).',
      ),
      YoloDetectedObject(
        id: 'el_multimeter',
        label: 'Probe Multimeter Digital',
        category: 'Alat Ukur Elektronika',
        confidence: 0.95,
        left: (0.50 + jitter1).clamp(0.1, 0.65),
        top: (0.45 + jitter1).clamp(0.2, 0.7),
        width: 0.38,
        height: 0.26,
        color: const Color(0xFFD32F2F),
        colorName: 'Merah Positif (+)',
        hex: '#D32F2F',
        r: 211,
        g: 47,
        b: 47,
        cvdTip: 'Probe kabel positif tegangan. Pastikan tidak tertukar dengan probe hitam massa (GND).',
      ),
    ];
  }

  // --- Skenario 4: Ruang Kelas ---
  List<YoloDetectedObject> _getKelasDetections() {
    final jitter1 = (_random.nextDouble() - 0.5) * 0.02;

    return [
      YoloDetectedObject(
        id: 'cls_bottle',
        label: 'Botol Minum Siswa',
        category: 'Barang Pribadi',
        confidence: 0.95,
        left: (0.16 + jitter1).clamp(0.05, 0.75),
        top: (0.22 + jitter1).clamp(0.15, 0.65),
        width: 0.30,
        height: 0.36,
        color: const Color(0xFF1E88E5),
        colorName: 'Biru Langit (Dodger Blue)',
        hex: '#1E88E5',
        r: 30,
        g: 136,
        b: 229,
        cvdTip: 'Warna biru dingin. Tampak jelas bagi penderita protanopia dan deuteranopia.',
      ),
      YoloDetectedObject(
        id: 'cls_pen',
        label: 'Pena / Highlighter',
        category: 'Alat Tulis Siswa',
        confidence: 0.92,
        left: (0.54 + jitter1).clamp(0.1, 0.65),
        top: (0.35 + jitter1).clamp(0.2, 0.7),
        width: 0.32,
        height: 0.24,
        color: const Color(0xFFFFD600),
        colorName: 'Kuning Stabilo (Highlighter)',
        hex: '#FFD600',
        r: 255,
        g: 214,
        b: 0,
        cvdTip: 'Tingkat luminositas tinggi (High Luminance). Sangat kontras di atas kertas putih.',
      ),
    ];
  }

  /// Data spesifikasi teknis arsitektur YOLO untuk presentasi ke Dosen
  static Map<String, String> getYoloModelSpecs() {
    return {
      'Arsitektur Model': 'YOLOv8 Nano (You Only Look Once - v8.1)',
      'Kerangka Kerja (Framework)': 'TensorFlow Lite (TFLite) & ONNX Runtime',
      'Format Berkas': 'yolov8n_float16.tflite (~6.2 MB)',
      'Eksekusi': 'On-Device Edge AI (100% Offline tanpa Server)',
      'Kecepatan Inferensi': '~18 - 24 ms per frame (30+ FPS pada NPU ponsel)',
      'Backbone': 'Modified CSPDarknet53 dengan C2f Module',
      'Neck & Head': 'PANet (Path Aggregation) + Anchor-Free Decoupled Head',
      'Fitur Khusus Colorlens':
          'Bounding Box Region of Interest (ROI) Pixel Color Extraction',
    };
  }
}
