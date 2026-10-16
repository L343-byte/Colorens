/// Model representing the result of a color blindness test.
class TestResultModel {
  final String id;
  final String userId;
  final String testType;
  final int score;
  final int totalQuestions;
  final String diagnosis;
  final String? cvdType;
  final String severity;
  final List<Map<String, dynamic>> answers;
  final DateTime timestamp;

  /// Creates a [TestResultModel].
  const TestResultModel({
    required this.id,
    required this.userId,
    required this.testType,
    required this.score,
    required this.totalQuestions,
    required this.diagnosis,
    this.cvdType,
    required this.severity,
    required this.answers,
    required this.timestamp,
  });

  /// Calculates the percentage score.
  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions * 100) : 0.0;

  /// Creates a [TestResultModel] from a map.
  factory TestResultModel.fromMap(Map<String, dynamic> map) {
    return TestResultModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      testType: map['testType'] as String,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      diagnosis: map['diagnosis'] as String,
      cvdType: map['cvdType'] as String?,
      severity: map['severity'] as String,
      answers: List<Map<String, dynamic>>.from(map['answers'] as List),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Converts the [TestResultModel] to a map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'testType': testType,
      'score': score,
      'totalQuestions': totalQuestions,
      'diagnosis': diagnosis,
      'cvdType': cvdType,
      'severity': severity,
      'answers': answers,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
