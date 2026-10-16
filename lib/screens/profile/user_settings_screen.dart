import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/providers/auth_provider.dart';
import 'package:colorlens/utils/validators.dart';
import 'package:colorlens/utils/snackbar_utils.dart';
import 'package:colorlens/widgets/common/custom_button.dart';
import 'package:colorlens/widgets/common/custom_text_field.dart';

/// Layar Pengaturan Pengguna (User Settings)
/// Memungkinkan siswa mengubah Username / Nama Lengkap, data sekolah,
/// dan memperbarui kata sandi (password).
class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profile Form Controllers
  final _profileFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _majorController;

  // Password Form Controllers
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isProfileLoading = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _schoolController = TextEditingController(text: user?.school ?? '');
    _majorController = TextEditingController(text: user?.major ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    setState(() => _isProfileLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      school: _schoolController.text.trim().isNotEmpty
          ? _schoolController.text.trim()
          : null,
      major: _majorController.text.trim().isNotEmpty
          ? _majorController.text.trim()
          : null,
    );

    if (!mounted) return;
    setState(() => _isProfileLoading = false);

    if (success) {
      SnackbarUtils.showSuccess(context, 'Profil berhasil diperbarui!');
    } else {
      SnackbarUtils.showError(
        context,
        authProvider.errorMessage ?? 'Gagal memperbarui profil',
      );
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isPasswordLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isPasswordLoading = false);

    if (success) {
      SnackbarUtils.showSuccess(context, 'Kata sandi berhasil diubah!');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      SnackbarUtils.showError(
        context,
        authProvider.errorMessage ?? 'Gagal mengubah kata sandi',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Pengguna'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profil & Nama'),
            Tab(icon: Icon(Icons.lock_outline), text: 'Ubah Password'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Edit Profile / Username
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: AppTheme.primaryNavy,
                          child: Text(
                            user != null && user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.accentGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Pengguna',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Username / Nama Lengkap',
                    hint: 'Masukkan nama lengkap atau username',
                    prefixIcon: Icons.badge_outlined,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _schoolController,
                    label: 'Asal Sekolah (Opsional)',
                    hint: 'Contoh: SMKN 1 Seni Visual',
                    prefixIcon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _majorController,
                    label: 'Jurusan SMK (Opsional)',
                    hint: 'Contoh: DKV / TKJ / Seni Lukis',
                    prefixIcon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Simpan Perubahan Profil',
                    icon: Icons.save_outlined,
                    isLoading: _isProfileLoading,
                    onPressed: _handleUpdateProfile,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.primaryNavy,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nama pengguna akan ditampilkan di sertifikat hasil tes dan halaman beranda Anda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textDark,
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

          // Tab 2: Change Password
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Keamanan & Sandi Akun',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gunakan kata sandi yang kuat dengan minimal 8 karakter untuk melindungi data tes Anda.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _currentPasswordController,
                    label: 'Kata Sandi Saat Ini',
                    hint: 'Masukkan kata sandi lama',
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Kata sandi saat ini wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'Kata Sandi Baru',
                    hint: 'Minimal 8 karakter',
                    isPassword: true,
                    prefixIcon: Icons.lock_reset_outlined,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Konfirmasi Kata Sandi Baru',
                    hint: 'Ketik ulang kata sandi baru',
                    isPassword: true,
                    prefixIcon: Icons.check_circle_outline,
                    validator: (val) => Validators.validateConfirmPassword(
                      val,
                      _newPasswordController.text,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Perbarui Kata Sandi',
                    icon: Icons.key_outlined,
                    isLoading: _isPasswordLoading,
                    onPressed: _handleChangePassword,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
