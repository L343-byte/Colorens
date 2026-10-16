import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';

import 'package:colorlens/providers/auth_provider.dart';
import 'package:colorlens/providers/test_provider.dart';
import 'package:colorlens/providers/camera_provider.dart';
import 'package:colorlens/screens/test/test_catalog_screen.dart';
import 'package:colorlens/screens/camera/camera_scanner_screen.dart';
import 'package:colorlens/screens/profile/profile_screen.dart';

/// Main dashboard with bottom navigation.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user != null) {
        Provider.of<TestProvider>(
          context,
          listen: false,
        ).loadHistory(authProvider.user!.id);
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 2 && index != 2) {
      // Keluar dari tab kamera: jeda kamera untuk menghemat baterai & mencegah lag
      final cameraProvider = Provider.of<CameraProvider>(
        context,
        listen: false,
      );
      cameraProvider.pauseCamera();
    } else if (_selectedIndex != 2 && index == 2) {
      // Masuk ke tab kamera: aktifkan kamera kembali
      final cameraProvider = Provider.of<CameraProvider>(
        context,
        listen: false,
      );
      cameraProvider.resumeCamera();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeContent(onTabSelected: _onItemTapped),
          const TestCatalogScreen(),
          const CameraScannerScreen(), // Must ensure this exists in the project
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryNavy,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Tes'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Kamera',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final Function(int) onTabSelected;

  const _HomeContent({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final testProvider = Provider.of<TestProvider>(context);
    final userName = authProvider.user?.name ?? 'Tamu';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Colorlens',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Halo, $userName! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const CircleAvatar(
                  backgroundColor: AppTheme.accentGold,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Siap melakukan tes visual hari ini?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Featured Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryNavy, Color(0xFF003D6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.colorize, color: AppTheme.accentGold),
                      SizedBox(width: 8),
                      Text(
                        'Tes Buta Warna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deteksi gangguan penglihatan warna dengan tes Ishihara & HRR',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => onTabSelected(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mulai Tes →',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Menu Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildQuickMenuCard(
                  icon: Icons.assignment,
                  color: AppTheme.tealSuccess,
                  label: 'Katalog Tes',
                  onTap: () => onTabSelected(1),
                ),
                _buildQuickMenuCard(
                  icon: Icons.camera_alt,
                  color: AppTheme.accentGold,
                  label: 'Kamera AR',
                  onTap: () => onTabSelected(2),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Hasil Terakhir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (testProvider.history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada hasil tes',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...testProvider.history.take(3).map((result) {
                // Determine color based on diagnosis severity (mock logic)
                Color statusColor = AppTheme.tealSuccess;
                if (result.diagnosis.toLowerCase().contains('mild') ||
                    result.diagnosis.toLowerCase().contains('ringan')) {
                  statusColor = AppTheme.warningYellow;
                } else if (result.diagnosis.toLowerCase().contains(
                      'moderate',
                    ) ||
                    result.diagnosis.toLowerCase().contains('sedang')) {
                  statusColor = Colors.orange;
                } else if (result.diagnosis.toLowerCase().contains('severe') ||
                    result.diagnosis.toLowerCase().contains('parah')) {
                  statusColor = AppTheme.errorRed;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.2),
                      child: Icon(Icons.science, color: statusColor, size: 20),
                    ),
                    title: Text(
                      result.testType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${result.timestamp.day}/${result.timestamp.month}/${result.timestamp.year}',
                    ),
                    trailing: Text(
                      result.diagnosis,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenuCard({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
