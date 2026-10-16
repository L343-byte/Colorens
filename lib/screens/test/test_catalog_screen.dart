import 'package:flutter/material.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';

/// Screen displaying the catalog of available visual tests.
class TestCatalogScreen extends StatelessWidget {
  const TestCatalogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Katalog Tes Visual',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih jenis tes yang ingin Anda lakukan',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              '🔬 Tes Standar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _TestCard(
              title: 'Tes Buta Warna (Ishihara)',
              description: 'Deteksi defisiensi penglihatan warna menggunakan metode plate Ishihara. 10 soal.',
              badgeText: '10 Soal',
              iconData: Icons.visibility,
              iconColor: AppTheme.tealSuccess,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.ishiharaTest),
            ),
            const SizedBox(height: 12),
            _TestCard(
              title: 'Tes HRR (Hardy-Rand-Rittler)',
              description: 'Tes lanjutan menggunakan bentuk geometris untuk diagnosis jenis buta warna yang lebih spesifik. 8 soal.',
              badgeText: '8 Soal',
              iconData: Icons.hexagon_outlined,
              iconColor: Colors.orange,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.hrrTest),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final IconData iconData;
  final Color iconColor;
  final VoidCallback onPressed;

  const _TestCard({
    Key? key,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.iconData,
    required this.iconColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Mulai Tes →',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
