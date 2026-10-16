import 'package:flutter/foundation.dart';
import 'package:colorlens/models/test_result_model.dart';
import 'package:colorlens/models/ishihara_plate_model.dart';
import 'package:colorlens/models/hrr_plate_model.dart';
import 'package:colorlens/data/ishihara_data.dart';
import 'package:colorlens/data/hrr_data.dart';
import 'package:colorlens/services/test_scoring_service.dart';
import 'package:colorlens/services/firestore_service.dart';

class TestProvider extends ChangeNotifier {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _answers = [];
  bool _isTestComplete = false;
  TestResultModel? _result;
  List<TestResultModel> _history = [];
  final FirestoreService _firestoreService = FirestoreService();

  List<IshiharaPlate> _activeIshiharaPlates = [];
  List<HRRPlate> _activeHRRPlates = [];

  int get currentIndex => _currentIndex;
  List<Map<String, dynamic>> get answers => _answers;
  bool get isTestComplete => _isTestComplete;
  TestResultModel? get result => _result;
  List<TestResultModel> get history => _history;
  List<IshiharaPlate> get activeIshiharaPlates => _activeIshiharaPlates;
  List<HRRPlate> get activeHRRPlates => _activeHRRPlates;

  void startTest() {
    _currentIndex = 0;
    _answers = [];
    _isTestComplete = false;
    _result = null;
    _activeIshiharaPlates = IshiharaTestData.getShuffledPlates();
    _activeHRRPlates = HRRTestData.getShuffledPlates();
    notifyListeners();
  }

  void startIshiharaTest() {
    _currentIndex = 0;
    _answers = [];
    _isTestComplete = false;
    _result = null;
    _activeIshiharaPlates = IshiharaTestData.getShuffledPlates();
    notifyListeners();
  }

  void startHRRTest() {
    _currentIndex = 0;
    _answers = [];
    _isTestComplete = false;
    _result = null;
    _activeHRRPlates = HRRTestData.getShuffledPlates();
    notifyListeners();
  }

  void submitAnswer({
    required int plateId,
    required dynamic userAnswer,
    required dynamic correctAnswer,
    required bool isCorrect,
    required String cvdType,
  }) {
    _answers.add({
      'plateId': plateId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'cvdType': cvdType,
    });
    notifyListeners();
  }

  void nextQuestion() {
    _currentIndex++;
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  TestResultModel finishIshiharaTest(String userId) {
    _result = TestScoringService.scoreIshihara(userId, _answers);
    _isTestComplete = true;
    notifyListeners();
    return _result!;
  }

  TestResultModel finishHRRTest(String userId) {
    _result = TestScoringService.scoreHRR(userId, _answers);
    _isTestComplete = true;
    notifyListeners();
    return _result!;
  }

  Future<void> saveResult(TestResultModel result) async {
    await _firestoreService.saveTestResult(result);
  }

  Future<void> loadHistory(String userId) async {
    _history = await _firestoreService.getTestResults(userId);
    notifyListeners();
  }

  void reset() {
    _currentIndex = 0;
    _answers = [];
    _isTestComplete = false;
    _result = null;
    _history = [];
    _activeIshiharaPlates = [];
    _activeHRRPlates = [];
    notifyListeners();
  }
}
