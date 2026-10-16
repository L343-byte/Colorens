/// Validators for form fields.
class Validators {
  /// Validates an email address or username.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username atau Email tidak boleh kosong';
    }
    if (value.contains('@')) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Format email tidak valid';
      }
    } else if (value.trim().length < 3) {
      return 'Username minimal 3 karakter';
    }
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  /// Validates a name.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }

  /// Validates password confirmation.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Password tidak cocok';
    }
    return null;
  }
}
