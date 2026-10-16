import 'package:flutter/foundation.dart';
import 'package:colorlens/services/auth_service.dart';
import 'package:colorlens/services/firestore_service.dart';
import 'package:colorlens/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Muat sesi pengguna saat inisialisasi
    loadUserProfile();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(email, password);
      _user = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String? school,
    String? major,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _authService.registerWithEmail(
        name: name,
        email: email,
        password: password,
        school: school,
        major: major,
      );

      await _firestoreService.createUserProfile(newUser);
      _user = newUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat registrasi. Silakan coba lagi.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> resetPassword(String email, {String? newPassword}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email, newPassword: newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage =
          'Gagal mereset password. Silakan periksa kembali email Anda.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_user != null) {
      await _firestoreService.deleteUserData(_user!.id);
      await _authService.deleteAccount();
      _user = null;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    String? school,
    String? major,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        school: school,
        major: major,
      );
      await _firestoreService.updateUserProfile(updatedUser.id, {
        'name': updatedUser.name,
        'school': updatedUser.school,
        'major': updatedUser.major,
      });
      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Gagal mengubah password: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> loadUserProfile() async {
    _user = await _authService.checkCurrentUser();
    if (_user != null) {
      final profile = await _firestoreService.getUserProfile(_user!.id);
      if (profile != null) {
        _user = profile;
      }
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
