import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colorlens/models/user_model.dart';

/// Exception khusus untuk autentikasi.
class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);

  @override
  String toString() => message;
}

/// Layanan autentikasi cerdas (Hybrid: Firebase Auth + Offline Local Fallback).
class AuthService {
  static const String _usersKey = 'colorlens_registered_users';
  static const String _sessionKey = 'colorlens_current_session';

  FirebaseAuth? get _firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  /// Inisialisasi auth & periksa sesi pengguna yang tersimpan
  Future<UserModel?> checkCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await _seedDefaultUser(prefs);

    // 1. Cek sesi Firebase Auth jika aktif
    try {
      final fbUser = _firebaseAuth?.currentUser;
      if (fbUser != null) {
        final sessionJson = prefs.getString(_sessionKey);
        if (sessionJson != null) {
          try {
            _currentUser = UserModel.fromMap(jsonDecode(sessionJson));
            return _currentUser;
          } catch (_) {}
        }
        _currentUser = UserModel(
          id: fbUser.uid,
          name:
              fbUser.displayName ?? (fbUser.email?.split('@').first ?? 'Siswa'),
          email: fbUser.email ?? '',
          createdAt: DateTime.now(),
        );
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Firebase auth check skipped: $e');
    }

    // 2. Cek sesi lokal SharedPreferences
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(sessionJson);
        _currentUser = UserModel.fromMap(map);
        return _currentUser;
      } catch (_) {
        await prefs.remove(_sessionKey);
      }
    }
    return null;
  }

  /// Membuat akun demo awal untuk kemudahan pengujian offline
  Future<void> _seedDefaultUser(SharedPreferences prefs) async {
    final existingUsersJson = prefs.getString(_usersKey);
    if (existingUsersJson == null) {
      final defaultUsers = [
        {
          'id': 'demo_student_01',
          'name': 'Siswa SMK Kreatif',
          'email': 'siswa@smk.id',
          'password': 'password123',
          'school': 'SMKN 1 Seni & Visual',
          'major': 'DKV',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];
      await prefs.setString(_usersKey, jsonEncode(defaultUsers));
    }
  }

  /// Melakukan login dengan email dan password (Firebase / Local).
  Future<UserModel> signInWithEmail(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await _seedDefaultUser(prefs);

    final normalizedEmail = email.trim().toLowerCase();

    // 1. Coba login ke Firebase Auth terlebih dahulu
    if (_firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser != null) {
          final user = UserModel(
            id: fbUser.uid,
            name:
                fbUser.displayName ??
                (fbUser.email?.split('@').first ?? 'Siswa'),
            email: fbUser.email ?? email,
            createdAt: DateTime.now(),
          );
          _currentUser = user;
          await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
          return user;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          throw AuthException(
            'wrong-credentials',
            'Username atau Password salah.',
          );
        } else if (e.code == 'invalid-email') {
          throw AuthException('invalid-email', 'Format email tidak valid');
        }
        debugPrint('Firebase sign in error: ${e.code}, mencoba akun lokal...');
      } catch (e) {
        debugPrint('Firebase tidak terhubung, fallback ke lokal: $e');
      }
    }

    // 2. Fallback: Verifikasi akun lokal SharedPreferences
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final userMap = users.firstWhere(
      (u) =>
          (u['email'] as String).trim().toLowerCase() == normalizedEmail ||
          ((u['name'] as String?)?.trim().toLowerCase() ?? '') ==
              normalizedEmail,
      orElse: () => null,
    );

    if (userMap == null || userMap['password'] != password) {
      throw AuthException('wrong-credentials', 'Username atau Password salah.');
    }

    final user = UserModel.fromMap(Map<String, dynamic>.from(userMap));
    _currentUser = user;
    await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
    return user;
  }

  /// Mendaftarkan pengguna baru (Firebase + Local).
  Future<UserModel> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? school,
    String? major,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _seedDefaultUser(prefs);

    final normalizedEmail = email.trim().toLowerCase();
    String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Coba daftarkan ke Firebase Auth jika aktif
    if (_firebaseAuth != null) {
      try {
        final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        if (credential.user != null) {
          userId = credential.user!.uid;
          await credential.user!.updateDisplayName(name.trim());
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw AuthException('email-already-in-use', 'Email sudah digunakan');
        } else if (e.code == 'weak-password') {
          throw AuthException('weak-password', 'Password terlalu lemah');
        }
        debugPrint('Firebase register skip: ${e.code}');
      } catch (e) {
        debugPrint('Firebase register tidak aktif: $e');
      }
    }

    // 2. Simpan juga secara lokal
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final alreadyExistsLocally = users.any(
      (u) => (u['email'] as String).trim().toLowerCase() == normalizedEmail,
    );

    if (alreadyExistsLocally && _firebaseAuth == null) {
      throw AuthException('email-already-in-use', 'Email sudah digunakan');
    }

    final newUser = UserModel(
      id: userId,
      name: name.trim(),
      email: normalizedEmail,
      school: school?.trim(),
      major: major?.trim(),
      createdAt: DateTime.now(),
    );

    final userRecord = newUser.toMap();
    userRecord['password'] = password;

    if (!alreadyExistsLocally) {
      users.add(userRecord);
      await prefs.setString(_usersKey, jsonEncode(users));
    }

    _currentUser = newUser;
    await prefs.setString(_sessionKey, jsonEncode(newUser.toMap()));
    return newUser;
  }

  /// Mengirim instruksi reset password (Email Firebase + Local update).
  Future<void> resetPassword(String email, {String? newPassword}) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = email.trim().toLowerCase();

    // 1. Kirim email reset password asli via Firebase jika aktif
    if (_firebaseAuth != null) {
      try {
        await _firebaseAuth!.sendPasswordResetEmail(email: normalizedEmail);
        debugPrint('Firebase password reset email sent to $normalizedEmail');
      } catch (e) {
        debugPrint('Firebase reset email skip/error: $e');
      }
    }

    // 2. Update juga password di database lokal
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final index = users.indexWhere(
      (u) => (u['email'] as String).trim().toLowerCase() == normalizedEmail,
    );

    if (index != -1) {
      users[index]['password'] = newPassword ?? 'password123';
      await prefs.setString(_usersKey, jsonEncode(users));
    } else if (_firebaseAuth == null) {
      throw AuthException('user-not-found', 'Email tidak terdaftar');
    }
  }

  /// Melakukan logout.
  Future<void> signOut() async {
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    _currentUser = null;
  }

  /// Memperbarui informasi profil pengguna (nama/username, sekolah, jurusan).
  Future<UserModel> updateProfile({
    required String name,
    String? school,
    String? major,
  }) async {
    if (_currentUser == null) {
      throw AuthException('unauthenticated', 'Anda belum masuk.');
    }

    final updatedUser = _currentUser!.copyWith(
      name: name.trim(),
      school: school?.trim(),
      major: major?.trim(),
    );

    // 1. Update Firebase display name jika aktif
    try {
      final fbUser = _firebaseAuth?.currentUser;
      if (fbUser != null) {
        await fbUser.updateDisplayName(name.trim());
      }
    } catch (e) {
      debugPrint('Firebase updateDisplayName skip: $e');
    }

    // 2. Update SharedPreferences database lokal
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final index = users.indexWhere(
      (u) => u['id'] == _currentUser!.id || u['email'] == _currentUser!.email,
    );
    if (index != -1) {
      final userMap = Map<String, dynamic>.from(users[index]);
      userMap['name'] = name.trim();
      userMap['school'] = school?.trim();
      userMap['major'] = major?.trim();
      users[index] = userMap;
      await prefs.setString(_usersKey, jsonEncode(users));
    }

    // 3. Update session
    _currentUser = updatedUser;
    await prefs.setString(_sessionKey, jsonEncode(updatedUser.toMap()));
    return updatedUser;
  }

  /// Mengubah password pengguna dengan memverifikasi password lama.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw AuthException('unauthenticated', 'Anda belum masuk.');
    }

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    final index = users.indexWhere(
      (u) => u['id'] == _currentUser!.id || u['email'] == _currentUser!.email,
    );
    if (index == -1) {
      throw AuthException('user-not-found', 'Data pengguna tidak ditemukan.');
    }

    final userMap = users[index];
    final storedPassword = userMap['password'] as String?;

    // Verifikasi password saat ini
    if (storedPassword != null && storedPassword != currentPassword) {
      throw AuthException('wrong-password', 'Password saat ini salah.');
    }

    // Update password di Firebase jika aktif
    try {
      final fbUser = _firebaseAuth?.currentUser;
      if (fbUser != null) {
        await fbUser.updatePassword(newPassword);
      }
    } catch (e) {
      debugPrint('Firebase updatePassword skip/error: $e');
    }

    // Simpan password baru di database lokal
    userMap['password'] = newPassword;
    users[index] = userMap;
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Menghapus akun pengguna.
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth?.currentUser?.delete();
    } catch (_) {}

    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);

    users.removeWhere((u) => u['id'] == _currentUser!.id);
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.remove(_sessionKey);
    _currentUser = null;
  }
}
