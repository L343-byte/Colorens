import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/providers/camera_provider.dart';
import 'package:colorlens/widgets/camera/color_indicator_widget.dart';
import 'package:colorlens/widgets/common/custom_button.dart';
import 'package:colorlens/services/permission_service.dart';

class CameraScannerScreen extends StatefulWidget {
  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize camera on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cameraProvider = context.read<CameraProvider>();
      if (!cameraProvider.isInitialized) {
        cameraProvider.initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraProvider = context.read<CameraProvider>();
    if (!cameraProvider.isInitialized || cameraProvider.controller == null) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraProvider.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cameraProvider.initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(
      builder: (context, cameraProvider, child) {
        // State 1: Permission Error
        if (cameraProvider.errorMessage != null &&
            !cameraProvider.isInitialized) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Izin Kamera Diperlukan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aplikasi memerlukan akses kamera untuk mendeteksi warna secara real-time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Berikan Izin & Coba Lagi',
                    onPressed: () => cameraProvider.initializeCamera(),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => PermissionService.openAppSettings(),
                    child: const Text('Buka Pengaturan Perangkat'),
                  ),
                ],
              ),
            ),
          );
        }

        // State 2: Camera Loading
        if (!cameraProvider.isInitialized ||
            cameraProvider.controller == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryNavy),
                SizedBox(height: 16),
                Text('Menyiapkan sensor kamera...'),
              ],
            ),
          );
        }

        // State 3: Camera Paused / Turned Off (Hemat Daya)
        if (!cameraProvider.isCameraActive) {
          return Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentGold, width: 2),
                    ),
                    child: const Icon(
                      Icons.videocam_off_outlined,
                      size: 56,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kamera Dinonaktifkan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Streaming kamera dimatikan untuk menghemat daya baterai dan suhu perangkat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.textDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.videocam),
                    label: const Text(
                      'Nyalakan Kamera Kembali',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => cameraProvider.toggleCameraActive(),
                  ),
                ],
              ),
            ),
          );
        }

        // State 4: Active Camera Scanner UI
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Camera Feed with Tap-To-Target Gesture
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final double relX = details.localPosition.dx / screenWidth;
                    final double relY = details.localPosition.dy / screenHeight;
                    cameraProvider.setTargetPosition(relX, relY);
                  },
                  child: CameraPreview(cameraProvider.controller!),
                ),

                // 2. Dynamic Reticle / Crosshair Target Overlay (Viewfinder Elegan)
                Positioned(
                  left: (cameraProvider.targetX * screenWidth) - 32,
                  top: (cameraProvider.targetY * screenHeight) - 32,
                  child: IgnorePointer(
                    child: _buildReticle(cameraProvider.isFrozen),
                  ),
                ),

                // 3. Top Floating Header Bar: Mode Pills & Controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Control buttons row (Power, Flash, Freeze, Target Reset)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Toggle Power (Nyalakan / Matikan)
                              IconButton(
                                icon: const Icon(
                                  Icons.power_settings_new,
                                  color: Colors.white,
                                ),
                                tooltip: 'Matikan Kamera',
                                onPressed: () =>
                                    cameraProvider.toggleCameraActive(),
                              ),

                              // Toggle Freeze / Lock
                              IconButton(
                                icon: Icon(
                                  cameraProvider.isFrozen
                                      ? Icons.lock
                                      : Icons.lock_open,
                                  color: cameraProvider.isFrozen
                                      ? AppTheme.accentGold
                                      : Colors.white,
                                ),
                                tooltip: cameraProvider.isFrozen
                                    ? 'Buka Kunci Warna'
                                    : 'Kunci Warna',
                                onPressed: () => cameraProvider.toggleFreeze(),
                              ),

                              // Toggle Flash / Torch
                              IconButton(
                                icon: Icon(
                                  cameraProvider.isTorchOn
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: cameraProvider.isTorchOn
                                      ? AppTheme.accentGold
                                      : Colors.white,
                                ),
                                tooltip: 'Flash',
                                onPressed: () => cameraProvider.toggleTorch(),
                              ),

                              // Reset Target to Center
                              IconButton(
                                icon: const Icon(
                                  Icons.filter_center_focus,
                                  color: Colors.white,
                                ),
                                tooltip: 'Arahkan ke Tengah',
                                onPressed: () =>
                                    cameraProvider.resetTargetPosition(),
                              ),

                              // Demo / Test Presets Modal (Contoh Warna)
                              IconButton(
                                icon: const Icon(
                                  Icons.palette_outlined,
                                  color: Colors.white,
                                ),
                                tooltip: 'Contoh Warna',
                                onPressed: () => _showColorSimulationDialog(
                                  context,
                                  cameraProvider,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mode Selector Pills: [Umum] [TKJ] [DKV]
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildModeChip(
                                label: '🌐 Umum',
                                isSelected:
                                    cameraProvider.filterMode ==
                                    ScannerFilterMode.universal,
                                onTap: () => cameraProvider.setFilterMode(
                                  ScannerFilterMode.universal,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildModeChip(
                                label: '🔌 Kabel LAN',
                                isSelected:
                                    cameraProvider.filterMode ==
                                    ScannerFilterMode.tkj,
                                onTap: () => cameraProvider.setFilterMode(
                                  ScannerFilterMode.tkj,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildModeChip(
                                label: '🎨 Desain DKV',
                                isSelected:
                                    cameraProvider.filterMode ==
                                    ScannerFilterMode.dkv,
                                onTap: () => cameraProvider.setFilterMode(
                                  ScannerFilterMode.dkv,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quick info banner for TKJ cheat sheet
                        if (cameraProvider.filterMode == ScannerFilterMode.tkj)
                          Container(
                            margin: const EdgeInsets.only(
                              top: 8,
                              left: 16,
                              right: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNavy.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.accentGold,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Kabel LAN: Membedakan kabel Hijau vs Coklat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _showT568bCheatSheet(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Urutan Kabel',
                                      style: TextStyle(
                                        color: AppTheme.textDark,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                      ],
                    ),
                  ),
                ),


                // 4. Bottom Info Overlay (Color Details)
                if (cameraProvider.detectedColorName != null)
                  ColorIndicatorWidget(
                    colorName: cameraProvider.detectedColorName!,
                    hexCode: cameraProvider.detectedHex ?? '',
                    color: cameraProvider.detectedColor ?? Colors.transparent,
                    r: cameraProvider.detectedR,
                    g: cameraProvider.detectedG,
                    b: cameraProvider.detectedB,
                    category: cameraProvider.detectedCategory,
                    lanCable: cameraProvider.lanCableMatch,
                    complementaryColor: cameraProvider.complementaryColor,
                    cmyk: cameraProvider.cmyk,
                    temperature: cameraProvider.colorTemperature,
                    filterMode: cameraProvider.filterMode,
                    isFrozen: cameraProvider.isFrozen,
                    onToggleFreeze: () => cameraProvider.toggleFreeze(),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReticle(bool isFrozen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _ViewfinderReticlePainter(
              isFrozen: isFrozen,
              accentColor: AppTheme.accentGold,
            ),
          ),
        ),
        if (isFrozen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 10, color: AppTheme.textDark),
                SizedBox(width: 3),
                Text(
                  'TERKUNCI',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold
              : Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textDark : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Sheet Panduan Urutan Crimping Kabel UTP T568B untuk Anak TKJ
  void _showT568bCheatSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final pinList = [
          ('Pin 1', 'Putih-Oranye', const Color(0xFFFFDFC4), 'TX+ (Transmit)'),
          ('Pin 2', 'Oranye Solid', const Color(0xFFEF6C00), 'TX- (Transmit)'),
          ('Pin 3', 'Putih-Hijau', const Color(0xFFC7F3D6), 'RX+ (Receive)'),
          ('Pin 4', 'Biru Solid', const Color(0xFF1976D2), 'Telephony / PoE'),
          ('Pin 5', 'Putih-Biru', const Color(0xFFC8E1FF), 'Telephony / PoE'),
          ('Pin 6', 'Hijau Solid', const Color(0xFF2E7D32), 'RX- (Receive) ⚠️'),
          ('Pin 7', 'Putih-Coklat', const Color(0xFFE4D5C7), 'Gigabit Ground'),
          (
            'Pin 8',
            'Coklat Solid',
            const Color(0xFF5D4037),
            'Gigabit Ground ⚠️',
          ),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Urutan Crimping Kabel UTP (T568B Standar)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dilihat dari kiri ke kanan dengan tembaga RJ45 menghadap ke atas / klip di bawah:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: pinList.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (context, index) {
                    final item = pinList[index];
                    return Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: item.$3,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Text(
                          item.$4,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dialog simulasi pengujian untuk demo langsung ke Dosen Penguji
  void _showColorSimulationDialog(
    BuildContext context,
    CameraProvider cameraProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final samples = [
          ('Kabel Hijau LAN (Pin 6)', 46, 125, 50),
          ('Kabel Coklat LAN (Pin 8)', 93, 64, 55),
          ('Kabel Oranye LAN (Pin 2)', 239, 108, 0),
          ('Kabel Putih-Hijau LAN (Pin 3)', 210, 245, 220),
          ('Biru Terang (DKV)', 33, 150, 243),
          ('Merah Cerah (DKV)', 220, 20, 60),
          ('Kuning Terang (DKV)', 255, 193, 7),
        ];

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Pilih Contoh Warna',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: samples.length,
              itemBuilder: (context, index) {
                final s = samples[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(s.$2, s.$3, s.$4, 1.0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  title: Text(
                    s.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    cameraProvider.simulateColorSample(s.$2, s.$3, s.$4);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}

/// Painter pembidik lensa (Viewfinder Reticle) elegan bergaya kamera mirrorless profesional
class _ViewfinderReticlePainter extends CustomPainter {
  final bool isFrozen;
  final Color accentColor;

  _ViewfinderReticlePainter({
    required this.isFrozen,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final primaryColor = isFrozen ? accentColor : Colors.white;

    // 1. Shadow outline agar terlihat jelas di latar terang maupun gelap
    final shadowBracket = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    // 2. Garis siku pembidik (Corner Brackets)
    final bracketPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 11.0;
    const double pad = 4.0;
    final double right = size.width - pad;
    final double bottom = size.height - pad;

    void drawCorner(Offset p1, Offset corner, Offset p2) {
      canvas.drawLine(p1, corner, shadowBracket);
      canvas.drawLine(corner, p2, shadowBracket);
      canvas.drawLine(p1, corner, bracketPaint);
      canvas.drawLine(corner, p2, bracketPaint);
    }

    // 4 Siku Pembidik Optik
    drawCorner(
      const Offset(pad, pad + cornerLen),
      const Offset(pad, pad),
      const Offset(pad + cornerLen, pad),
    );
    drawCorner(
      Offset(right - cornerLen, pad),
      Offset(right, pad),
      Offset(right, pad + cornerLen),
    );
    drawCorner(
      Offset(pad, bottom - cornerLen),
      Offset(pad, bottom),
      Offset(pad + cornerLen, bottom),
    );
    drawCorner(
      Offset(right - cornerLen, bottom),
      Offset(right, bottom),
      Offset(right, bottom - cornerLen),
    );

    // 3. Lingkaran aperture tengah yang tipis dan elegan
    final shadowRing = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 13, shadowRing);

    final ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: isFrozen ? 0.9 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, 13, ringPaint);

    // 4. Garis bidik presisi mikro (+)
    final crossPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(center.dx, center.dy - 8), Offset(center.dx, center.dy - 3), crossPaint);
    canvas.drawLine(Offset(center.dx, center.dy + 3), Offset(center.dx, center.dy + 8), crossPaint);
    canvas.drawLine(Offset(center.dx - 8, center.dy), Offset(center.dx - 3, center.dy), crossPaint);
    canvas.drawLine(Offset(center.dx + 3, center.dy), Offset(center.dx + 8, center.dy), crossPaint);

    // 5. Titik bidik tengah (Center dot)
    final dotPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.8, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderReticlePainter oldDelegate) {
    return oldDelegate.isFrozen != isFrozen;
  }
}

