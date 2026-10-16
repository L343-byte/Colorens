import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:colorlens/models/user_model.dart';
import 'package:colorlens/models/test_result_model.dart';

/// Layanan penyimpanan lokal mandiri untuk profil & hasil tes.
/// Berjalan offline tanpa memerlukan koneksi Firebase atau internet.
class FirestoreService {
  static const String _usersStorageKey = 'colorlens_user_profiles';
  static const String _resultsStorageKey = 'colorlens_test_results';

  /// Membuat profil pengguna baru di penyimpanan lokal.
  Future<void> createUserProfile(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_usersStorageKey) ?? '{}';
    final Map<String, dynamic> profiles = jsonDecode(jsonStr);

    profiles[user.id] = user.toMap();
    await prefs.setString(_usersStorageKey, jsonEncode(profiles));
  }

  /// Mengambil data profil pengguna berdasarkan ID.
  Future<UserModel?> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_usersStorageKey) ?? '{}';
    final Map<String, dynamic> profiles = jsonDecode(jsonStr);

    if (profiles.containsKey(userId)) {
      final map = Map<String, dynamic>.from(profiles[userId]);
      return UserModel.fromMap(map);
    }
    return null;
  }

  /// Memperbarui data profil pengguna.
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_usersStorageKey) ?? '{}';
    final Map<String, dynamic> profiles = jsonDecode(jsonStr);

    if (profiles.containsKey(userId)) {
      final existing = Map<String, dynamic>.from(profiles[userId]);
      existing.addAll(data);
      profiles[userId] = existing;
      await prefs.setString(_usersStorageKey, jsonEncode(profiles));
    }
  }

  /// Menyimpan hasil tes ke dalam penyimpanan lokal.
  Future<void> saveTestResult(TestResultModel result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_resultsStorageKey) ?? '[]';
    final List<dynamic> results = jsonDecode(jsonStr);

    // Tambahkan hasil tes baru
    results.insert(0, result.toMap());
    await prefs.setString(_resultsStorageKey, jsonEncode(results));
  }

  /// Mengambil daftar hasil tes berdasarkan ID pengguna (maksimal 20 terbaru).
  Future<List<TestResultModel>> getTestResults(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_resultsStorageKey) ?? '[]';
    final List<dynamic> results = jsonDecode(jsonStr);

    final filtered = results
        .where((r) => r['userId'] == userId || userId == 'guest')
        .take(20)
        .map((r) => TestResultModel.fromMap(Map<String, dynamic>.from(r)))
        .toList();

    return filtered;
  }

  /// Menghapus data profil dan riwayat tes pengguna.
  Future<void> deleteUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus profil
    final usersJson = prefs.getString(_usersStorageKey) ?? '{}';
    final Map<String, dynamic> profiles = jsonDecode(usersJson);
    profiles.remove(userId);
    await prefs.setString(_usersStorageKey, jsonEncode(profiles));

    // Hapus hasil tes
    final resultsJson = prefs.getString(_resultsStorageKey) ?? '[]';
    final List<dynamic> results = jsonDecode(resultsJson);
    results.removeWhere((r) => r['userId'] == userId);
    await prefs.setString(_resultsStorageKey, jsonEncode(results));
  }
}
