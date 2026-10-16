import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/providers/camera_provider.dart';
import 'package:colorlens/utils/color_utils.dart';

/// Displays detected color information at the bottom of the camera view.
/// Adapts dynamically for Universal, TKJ, and DKV modes.
class ColorIndicatorWidget extends StatelessWidget {
  final String colorName;
  final String hexCode;
  final Color color;
  final int r;
  final int g;
  final int b;
  final String? category;
  final LanCableMatch? lanCable;
  final Color? complementaryColor;
  final Map<String, int>? cmyk;
  final String? temperature;
  final ScannerFilterMode filterMode;
  final bool isFrozen;
  final VoidCallback? onToggleFreeze;

  const ColorIndicatorWidget({
    super.key,
    required this.colorName,
    required this.hexCode,
    required this.color,
    required this.r,
    required this.g,
    required this.b,
    this.category,
    this.lanCable,
    this.complementaryColor,
    this.cmyk,
    this.temperature,
    this.filterMode = ScannerFilterMode.universal,
    this.isFrozen = false,
    this.onToggleFreeze,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Header: Color Preview Swatch, Name, HEX, & Freeze Status
            Row(
              children: [
                // Color swatch
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    if (isFrozen)
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Name and Hex
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              colorName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFrozen)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.amber.shade700,
                                ),
                              ),
                              child: Text(
                                'KUNCI (FROZEN)',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            hexCode,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                              fontFamily: 'monospace',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              size: 16,
                              color: AppTheme.primaryNavy,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            constraints: const BoxConstraints(),
                            tooltip: 'Salin Kode HEX',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: hexCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kode $hexCode berhasil disalin ke clipboard!',
                                  ),
                                  duration: const Duration(milliseconds: 1200),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          if (category != null &&
                              filterMode == ScannerFilterMode.universal)
                            Expanded(
                              child: Text(
                                '• $category',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryNavy,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dynamic Content based on Active Mode
            if (filterMode == ScannerFilterMode.tkj) ...[
              _buildTkjCard(context),
            ] else if (filterMode == ScannerFilterMode.dkv) ...[
              _buildDkvCard(context),
            ] else ...[
              _buildUniversalCard(),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== MODE UMUM / UNIVERSAL ====================
  Widget _buildUniversalCard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildRgbChip(
                'R: $r',
                Colors.red.shade50,
                Colors.red.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRgbChip(
                'G: $g',
                Colors.green.shade50,
                Colors.green.shade800,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildRgbChip(
                'B: $b',
                Colors.blue.shade50,
                Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== MODE TKJ (KABEL UTP LAN) ====================
  Widget _buildTkjCard(BuildContext context) {
    if (lanCable == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_ethernet,
                size: 20,
                color: AppTheme.primaryNavy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kabel UTP: ${lanCable!.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'T568B: Pin ${lanCable!.t568bPin}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Standar T568A: Pin ${lanCable!.t568aPin} | Fungsi: ${lanCable!.functionDesc}',
            style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade700),
          ),

          if (lanCable!.isCvdRisk) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lanCable!.cvdWarning,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== MODE DKV (DESAIN & HARMONI) ====================
  Widget _buildDkvCard(BuildContext context) {
    final comp = complementaryColor ?? Colors.grey;
    final compR = (comp.r * 255.0).round().clamp(0, 255);
    final compG = (comp.g * 255.0).round().clamp(0, 255);
    final compB = (comp.b * 255.0).round().clamp(0, 255);
    final compHex = ColorUtils.rgbToHex(compR, compG, compB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CMYK and Temp Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cmyk != null
                      ? 'CMYK: ${cmyk!['c']}C ${cmyk!['m']}M ${cmyk!['y']}Y ${cmyk!['k']}K'
                      : 'CMYK: --',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (temperature?.contains('Hangat') ?? false)
                    ? Colors.orange.shade50
                    : Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (temperature?.contains('Hangat') ?? false)
                      ? Colors.orange.shade200
                      : Colors.lightBlue.shade200,
                ),
              ),
              child: Text(
                temperature ?? 'Netral',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: (temperature?.contains('Hangat') ?? false)
                      ? Colors.orange.shade900
                      : Colors.blue.shade900,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Complementary Color Swatch
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: comp,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Warna Komplementer (Kontras Harmoni 180°)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '$compHex (Sesuai untuk tombol/aksen visual)',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: AppTheme.primaryNavy,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Salin Warna Komplementer',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: compHex));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kode Komplementer $compHex berhasil disalin!',
                      ),
                      duration: const Duration(milliseconds: 1200),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRgbChip(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
