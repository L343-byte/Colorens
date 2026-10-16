import 'package:camera/camera.dart';

/// Layanan untuk mengelola kamera perangkat.
class CameraService {
  CameraController? _controller;

  /// Mengembalikan instance CameraController yang aktif.
  CameraController? get controller => _controller;

  /// Mengecek apakah kamera sudah diinisialisasi.
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Menginisialisasi kamera untuk penggunaan real-time.
  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia');
      }

      // Menggunakan kamera belakang (biasanya kamera pertama)
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Resolusi medium disarankan untuk performa pemrosesan gambar
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      rethrow;
    }
  }

  /// Apakah lampu kilat/senter sedang aktif.
  bool _isTorchOn = false;
  bool get isTorchOn => _isTorchOn;

  /// Mengaktifkan atau mematikan lampu senter/flash.
  Future<void> toggleTorch() async {
    if (!isInitialized || _controller == null) return;
    try {
      _isTorchOn = !_isTorchOn;
      await _controller!.setFlashMode(
        _isTorchOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {
      // Perangkat mungkin tidak memiliki flash atau running di simulator
    }
  }

  /// Memulai aliran gambar untuk diproses.
  void startImageStream(Function(CameraImage) onImage) {
    if (isInitialized && !(_controller!.value.isStreamingImages)) {
      _controller?.startImageStream(onImage);
    }
  }

  /// Menghentikan aliran gambar.
  void stopImageStream() {
    if (isInitialized && (_controller?.value.isStreamingImages ?? false)) {
      _controller?.stopImageStream();
    }
  }

  /// Menjeda kamera sementara untuk hemat daya.
  Future<void> pausePreview() async {
    if (isInitialized) {
      stopImageStream();
      try {
        await _controller?.pausePreview();
      } catch (_) {}
    }
  }

  /// Melanjutkan kembali preview kamera.
  Future<void> resumePreview(Function(CameraImage) onImage) async {
    if (isInitialized) {
      try {
        await _controller?.resumePreview();
      } catch (_) {}
      startImageStream(onImage);
    }
  }

  /// Membersihkan sumber daya kamera.
  void dispose() {
    _isTorchOn = false;
    _controller?.dispose();
    _controller = null;
  }
}
