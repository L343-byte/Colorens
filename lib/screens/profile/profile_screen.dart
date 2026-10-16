import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';
import 'package:colorlens/providers/auth_provider.dart';
import 'package:colorlens/providers/test_provider.dart';

/// Screen displaying user profile and account actions.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm, {
    bool isDestructive = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                isDestructive ? 'Ya, Hapus' : 'Ya',
                style: TextStyle(
                  color: isDestructive
                      ? AppTheme.errorRed
                      : AppTheme.primaryNavy,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Anda belum login'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                ),
                child: const Text(
                  'Login untuk menyimpan data',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final testProvider = Provider.of<TestProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryNavy,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (user.school != null || user.major != null)
              Chip(
                label: Text(
                  'SMK ${user.school ?? ''} • Jurusan ${user.major ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
              ),

            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.userSettings),
              icon: const Icon(
                Icons.manage_accounts,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Pengaturan Akun & Password',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Informasi Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.userSettings),
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.primaryNavy,
                  ),
                  label: const Text(
                    'Ubah',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ListTile(
              title: const Text(
                'Nama',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                user.name,
                style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text(
                'Email',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                user.email,
                style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text(
                'Sekolah',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                user.school ?? 'Belum diisi',
                style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text(
                'Jurusan',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                user.major ?? 'Belum diisi',
                style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Tes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppTheme.primaryNavy),
              title: const Text('Total Tes Dilakukan'),
              trailing: Text(
                '${testProvider.history.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorRed),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showConfirmDialog(
                  context,
                  'Konfirmasi Keluar',
                  'Apakah Anda yakin ingin keluar dari akun ini?',
                  () async {
                    await authProvider.signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: AppTheme.errorRed,
              ),
              title: const Text(
                'Hapus Akun',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showConfirmDialog(context, 'Peringatan Hapus Akun', 'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus permanen. Lanjutkan?', () async {
                  // await authProvider.deleteAccount();
                  await authProvider.signOut();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }, isDestructive: true);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
