import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:colorlens/services/camera_service.dart';
import 'package:colorlens/services/color_detection_service.dart';
import 'package:colorlens/services/permission_service.dart';
import 'package:colorlens/utils/color_utils.dart';
import 'package:colorlens/config/constants.dart';

import 'package:colorlens/models/yolo_detection_model.dart';
import 'package:colorlens/services/yolo_vision_service.dart';

/// Pilihan mode filter deteksi kamera
enum ScannerFilterMode {
  universal, // Mode Umum (Deteksi nama, HEX, RGB dasar)
  tkj, // Mode TKJ (Pencocokan kabel LAN UTP T568A/B & pencegahan buta warna)
  dkv, // Mode DKV (Ekstraksi kode HEX, CMYK cetak, harmoni komplementer)
}

class CameraProvider extends ChangeNotifier {
  final CameraService _cameraService = CameraService();

  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isCameraActive = true;
  bool _isFrozen = false;

  ScannerFilterMode _filterMode = ScannerFilterMode.universal;

  // Posisi target deteksi (0.0 - 1.0), default di titik tengah (0.5, 0.5)
  double _targetX = 0.5;
  double _targetY = 0.5;

  String? _detectedColorName;
  String? _detectedHex;
  Color? _detectedColor;
  String? _detectedCategory;
  int _detectedR = 0;
  int _detectedG = 0;
  int _detectedB = 0;

  // Analisis spesifik jurusan
  LanCableMatch? _lanCableMatch;
  Color? _complementaryColor;
  Map<String, int>? _cmyk;
  String? _colorTemperature;

  // Analisis AI YOLO Multi-Object Vision
  final YoloVisionService _yoloService = YoloVisionService();
  YoloDetectedObject? _selectedYoloObject;

  String? _errorMessage;
  DateTime? _lastProcessedTime;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  bool get isCameraActive => _isCameraActive;
  bool get isFrozen => _isFrozen;
  bool get isTorchOn => _cameraService.isTorchOn;
  ScannerFilterMode get filterMode => _filterMode;
  double get targetX => _targetX;
  double get targetY => _targetY;

  String? get detectedColorName => _detectedColorName;
  String? get detectedHex => _detectedHex;
  Color? get detectedColor => _detectedColor;
  String? get detectedCategory => _detectedCategory;
  int get detectedR => _detectedR;
  int get detectedG => _detectedG;
  int get detectedB => _detectedB;

  LanCableMatch? get lanCableMatch => _lanCableMatch;
  Color? get complementaryColor => _complementaryColor;
  Map<String, int>? get cmyk => _cmyk;
  String? get colorTemperature => _colorTemperature;

  // Getters AI YOLO
  YoloVisionService get yoloService => _yoloService;
  List<YoloDetectedObject> get yoloDetections => _yoloService.getDetections();
  YoloDetectedObject? get selectedYoloObject => _selectedYoloObject;

  String? get errorMessage => _errorMessage;
  CameraController? get controller => _cameraService.controller;

  /// Inisialisasi awal kamera hardware
  Future<void> initializeCamera() async {
    try {
      final hasPermission = await PermissionService.requestCameraPermission();
      if (!hasPermission) {
        _errorMessage = 'Izin kamera diperlukan';
        notifyListeners();
        return;
      }

      await _cameraService.initialize();
      _cameraService.startImageStream(_onImageAvailable);

      _isInitialized = true;
      _isCameraActive = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menginisialisasi kamera: $e';
      notifyListeners();
    }
  }

  /// Mengubah mode filter deteksi (Umum / TKJ / DKV / YOLO AI)
  void setFilterMode(ScannerFilterMode mode) {
    if (_filterMode == mode) return;
    _filterMode = mode;
    notifyListeners();
  }

  /// Memilih objek hasil deteksi YOLO untuk dikunci dan dilihat detail warnanya
  void selectYoloObject(YoloDetectedObject? obj) {
    _selectedYoloObject = obj;
    if (obj != null) {
      _detectedColorName = obj.colorName;
      _detectedHex = obj.hex;
      _detectedColor = obj.color;
      _detectedR = obj.r;
      _detectedG = obj.g;
      _detectedB = obj.b;
      _detectedCategory = obj.category;
      _targetX = obj.left + obj.width / 2;
      _targetY = obj.top + obj.height / 2;
    }
    notifyListeners();
  }

  /// Mengganti skenario demonstrasi objek AI YOLO
  void nextYoloScenario() {
    _yoloService.nextScenario();
    final detections = _yoloService.getDetections();
    if (detections.isNotEmpty) {
      selectYoloObject(detections.first);
    } else {
      _selectedYoloObject = null;
    }
    notifyListeners();
  }

  /// Menetapkan skenario demonstrasi objek AI YOLO
  void setYoloScenario(int index) {
    _yoloService.setScenario(index);
    final detections = _yoloService.getDetections();
    if (detections.isNotEmpty) {
      selectYoloObject(detections.first);
    } else {
      _selectedYoloObject = null;
    }
    notifyListeners();
  }

  /// Menyalakan / mematikan kamera (Standby switch untuk hemat daya)
  Future<void> toggleCameraActive() async {
    _isCameraActive = !_isCameraActive;
    if (!_isCameraActive) {
      await _cameraService.pausePreview();
    } else {
      await _cameraService.resumePreview(_onImageAvailable);
    }
    notifyListeners();
  }

  /// Menjeda kamera saat pengguna berpindah ke tab lain (Mencegah panas & lag)
  Future<void> pauseCamera() async {
    if (_isCameraActive && _isInitialized) {
      _isCameraActive = false;
      await _cameraService.pausePreview();
      notifyListeners();
    }
  }

  /// Melanjutkan kamera saat tab kamera aktif kembali
  Future<void> resumeCamera() async {
    if (!_isCameraActive && _isInitialized) {
      _isCameraActive = true;
      await _cameraService.resumePreview(_onImageAvailable);
      notifyListeners();
    }
  }

  /// Mengunci (freeze) atau mencairkan (unfreeze) hasil deteksi warna
  void toggleFreeze() {
    _isFrozen = !_isFrozen;
    notifyListeners();
  }

  /// Mengaktifkan / mematikan lampu kilat/senter
  Future<void> toggleTorch() async {
    await _cameraService.toggleTorch();
    notifyListeners();
  }

  /// Memindahkan titik bidik fokus deteksi (Tap-to-target)
  void setTargetPosition(double x, double y) {
    _targetX = x.clamp(0.05, 0.95);
    _targetY = y.clamp(0.05, 0.95);
    notifyListeners();
  }

  /// Mengembalikan titik bidik ke tengah layar
  void resetTargetPosition() {
    _targetX = 0.5;
    _targetY = 0.5;
    notifyListeners();
  }

  /// Simulasi sample warna (Sangat berguna untuk demonstrasi atau pengujian tanpa kamera fisik)
  void simulateColorSample(int r, int g, int b) {
    final analysis = ColorDetectionService.analyzeColorFromRgb(r, g, b);
    _updateFromAnalysis(analysis);
  }

  void _onImageAvailable(CameraImage image) {
    // Lewatkan pemrosesan jika kamera nonaktif atau frame dibekukan (freeze)
    if (!_isCameraActive || _isFrozen) return;

    final now = DateTime.now();
    if (_lastProcessedTime != null) {
      final difference = now.difference(_lastProcessedTime!).inMilliseconds;
      if (difference < AppConstants.cameraProcessingInterval) {
        return;
      }
    }

    if (_isProcessing) return;

    _isProcessing = true;
    _lastProcessedTime = now;

    try {
      final colorData = ColorDetectionService.detectColorFromImage(
        image,
        _targetX,
        _targetY,
      );
      _updateFromAnalysis(colorData);
    } catch (e) {
      debugPrint('Error detecting color: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _updateFromAnalysis(Map<String, dynamic> colorData) {
    _detectedR = colorData['r'] as int;
    _detectedG = colorData['g'] as int;
    _detectedB = colorData['b'] as int;
    _detectedColorName = colorData['name'] as String;
    _detectedHex = colorData['hex'] as String;
    _detectedCategory = colorData['category'] as String?;
    _detectedColor = Color.fromRGBO(_detectedR, _detectedG, _detectedB, 1.0);

    _lanCableMatch = colorData['lanCable'] as LanCableMatch?;
    _complementaryColor = colorData['complementary'] as Color?;
    _cmyk = colorData['cmyk'] as Map<String, int>?;
    _colorTemperature = colorData['temperature'] as String?;
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
