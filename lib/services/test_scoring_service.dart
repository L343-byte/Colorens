import 'package:colorlens/models/test_result_model.dart';

/// Layanan untuk menghitung skor dan mendiagnosis hasil tes buta warna.
class TestScoringService {
  /// Menilai hasil tes Ishihara.
  static TestResultModel scoreIshihara(
    String userId,
    List<Map<String, dynamic>> answers,
  ) {
    int score = 0;
    int protanCount = 0;
    int deutanCount = 0;
    int tritanCount = 0;

    for (var answer in answers) {
      if (answer['isCorrect'] == true) {
        score++;
      } else {
        // Hitung kecenderungan tipe CVD jika salah
        final String cvdType = answer['cvdType'] ?? '';
        if (cvdType.toLowerCase().contains('protan')) {
          protanCount++;
        } else if (cvdType.toLowerCase().contains('deutan')) {
          deutanCount++;
        } else if (cvdType.toLowerCase().contains('tritan')) {
          tritanCount++;
        }
      }
    }

    final int totalQuestions = answers.length;
    String diagnosis = '';
    String severity = '';

    if (score >= 9) {
      // 9-10
      diagnosis = 'Normal';
      severity = 'normal';
    } else if (score >= 7) {
      // 7-8
      diagnosis = 'Defisiensi Ringan';
      severity = 'mild';
    } else if (score >= 4) {
      // 4-6
      diagnosis = 'Defisiensi Sedang';
      severity = 'moderate';
    } else {
      // 0-3
      diagnosis = 'Defisiensi Berat';
      severity = 'severe';
    }

    String? finalCvdType;
    if (severity != 'normal') {
      if (protanCount >= deutanCount &&
          protanCount >= tritanCount &&
          protanCount > 0) {
        finalCvdType = 'protan';
      } else if (deutanCount >= protanCount &&
          deutanCount >= tritanCount &&
          deutanCount > 0) {
        finalCvdType = 'deutan';
      } else if (tritanCount >= protanCount &&
          tritanCount >= deutanCount &&
          tritanCount > 0) {
        finalCvdType = 'tritan';
      }
    }

    return TestResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      testType: 'Ishihara',
      score: score,
      totalQuestions: totalQuestions,
      diagnosis: diagnosis,
      cvdType: finalCvdType,
      severity: severity,
      answers: answers,
      timestamp: DateTime.now(),
    );
  }

  /// Menilai hasil tes HRR.
  static TestResultModel scoreHRR(
    String userId,
    List<Map<String, dynamic>> answers,
  ) {
    int score = 0;
    int protanCount = 0;
    int deutanCount = 0;
    int tritanCount = 0;

    for (var answer in answers) {
      if (answer['isCorrect'] == true) {
        score++;
      } else {
        final String cvdType = answer['cvdType'] ?? '';
        if (cvdType.toLowerCase().contains('protan')) {
          protanCount++;
        } else if (cvdType.toLowerCase().contains('deutan')) {
          deutanCount++;
        } else if (cvdType.toLowerCase().contains('tritan')) {
          tritanCount++;
        }
      }
    }

    final int totalQuestions = answers.length;
    String diagnosis = '';
    String severity = '';

    if (score >= 7) {
      // 7-8
      diagnosis = 'Normal';
      severity = 'normal';
    } else if (score >= 5) {
      // 5-6
      diagnosis = 'Defisiensi Ringan';
      severity = 'mild';
    } else if (score >= 3) {
      // 3-4
      diagnosis = 'Defisiensi Sedang';
      severity = 'moderate';
    } else {
      // 0-2
      diagnosis = 'Defisiensi Berat';
      severity = 'severe';
    }

    String? finalCvdType;
    if (severity != 'normal') {
      if (protanCount >= deutanCount &&
          protanCount >= tritanCount &&
          protanCount > 0) {
        finalCvdType = 'protan';
      } else if (deutanCount >= protanCount &&
          deutanCount >= tritanCount &&
          deutanCount > 0) {
        finalCvdType = 'deutan';
      } else if (tritanCount >= protanCount &&
          tritanCount >= deutanCount &&
          tritanCount > 0) {
        finalCvdType = 'tritan';
      }
    }

    return TestResultModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      testType: 'HRR',
      score: score,
      totalQuestions: totalQuestions,
      diagnosis: diagnosis,
      cvdType: finalCvdType,
      severity: severity,
      answers: answers,
      timestamp: DateTime.now(),
    );
  }
}
