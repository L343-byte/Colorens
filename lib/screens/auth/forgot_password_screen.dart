import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colorlens/config/theme.dart';
import 'package:colorlens/utils/validators.dart';
import 'package:colorlens/widgets/common/custom_button.dart';
import 'package:colorlens/widgets/common/custom_text_field.dart';
import 'package:colorlens/providers/auth_provider.dart';

/// Screen for requesting a password reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(_emailController.text.trim());

      if (!mounted) return;

      if (authProvider.errorMessage == null) {
        setState(() {
          _isEmailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: _isEmailSent
              ? _buildSuccessView()
              : _buildFormView(authProvider),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 80, color: AppTheme.primaryNavy),
          const SizedBox(height: 24),
          const Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan email Anda dan kami akan mengirimkan link untuk mereset password.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Masukkan email terdaftar',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Kirim Link Reset',
            onPressed: _handleResetPassword,
            isLoading: authProvider.isLoading,
          ),
          if (authProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                authProvider.errorMessage!,
                style: const TextStyle(color: AppTheme.errorRed, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 80,
          color: AppTheme.tealSuccess,
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Terkirim!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Cek inbox email Anda untuk link reset password.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Kembali ke Login',
          onPressed: () {
            Provider.of<AuthProvider>(context, listen: false).clearError();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
