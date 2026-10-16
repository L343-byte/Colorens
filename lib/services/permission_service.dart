import 'package:permission_handler/permission_handler.dart' as handler;

/// Layanan untuk mengelola izin aplikasi, terutama izin kamera.
class PermissionService {
  /// Meminta izin kamera dari pengguna.
  /// Mengembalikan true jika diberikan, false jika ditolak.
  static Future<bool> requestCameraPermission() async {
    final status = await handler.Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      return false;
    }

    return false;
  }

  /// Memeriksa status izin kamera saat ini.
  static Future<bool> hasCameraPermission() async {
    return await handler.Permission.camera.isGranted;
  }

  /// Membuka pengaturan aplikasi untuk memberikan izin secara manual.
  static Future<void> openAppSettings() async {
    await handler.openAppSettings();
  }
}
