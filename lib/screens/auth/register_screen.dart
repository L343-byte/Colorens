import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/config/routes.dart';
import 'package:colorlens/utils/validators.dart';
import 'package:colorlens/widgets/common/custom_button.dart';
import 'package:colorlens/widgets/common/custom_text_field.dart';
import 'package:colorlens/providers/auth_provider.dart';

/// Screen for creating a new account.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _schoolController = TextEditingController();

  String? _selectedMajor;

  final List<String> _majors = [
    'DKV',
    'Seni Lukis',
    'TKJ',
    'Multimedia',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _schoolController.text.trim(),
        _selectedMajor,
      );

      if (!mounted) return;

      if (success && authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person_outlined,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Masukkan email Anda',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Buat password',
                      prefixIcon: Icons.lock_outlined,
                      isPassword: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password',
                      prefixIcon: Icons.lock_outlined,
                      isPassword: true,
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _schoolController,
                      label: 'Asal Sekolah (Opsional)',
                      hint: 'Masukkan nama sekolah',
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMajor,
                      decoration: InputDecoration(
                        labelText: 'Jurusan',
                        prefixIcon: const Icon(Icons.work_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: _majors.map((major) {
                        return DropdownMenuItem(
                          value: major,
                          child: Text(major),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMajor = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Daftar',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    ),
                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.errorRed.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppTheme.errorRed,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(
                                    color: AppTheme.errorRed,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah punya akun? '),
                        TextButton(
                          onPressed: () {
                            authProvider.clearError();
                            Navigator.pop(context);
                          },
                          child: const Text('Masuk'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
