import 'package:flutter/foundation.dart';
import 'package:mental_health_companion/models/user_state.dart';
import 'package:mental_health_companion/services/database_service.dart';

class AppStateProvider extends ChangeNotifier {
  UserState? _currentUserState;
  DateTime? _lastQuestionDate;
  List<String> _dailyQuestions = [];
  bool _isLoading = false;

  UserState? get currentUserState => _currentUserState;
  DateTime? get lastQuestionDate => _lastQuestionDate;
  List<String> get dailyQuestions => _dailyQuestions;
  bool get isLoading => _isLoading;

  Future<void> loadUserState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUserState = await DatabaseService.instance.getUserState();
      _lastQuestionDate = await DatabaseService.instance.getLastQuestionDate();
      _dailyQuestions = await DatabaseService.instance.getDailyQuestions();
    } catch (e) {
      debugPrint('Error loading user state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserState(UserState state) async {
    _currentUserState = state;
    await DatabaseService.instance.saveUserState(state);
    notifyListeners();
  }

  Future<void> setDailyQuestions(List<String> questions) async {
    _dailyQuestions = questions;
    await DatabaseService.instance.saveDailyQuestions(questions);
    _lastQuestionDate = DateTime.now();
    await DatabaseService.instance.saveLastQuestionDate(_lastQuestionDate!);
    notifyListeners();
  }

  bool shouldShowDailyQuestions() {
    if (_lastQuestionDate == null) return true;
    final now = DateTime.now();
    return now.difference(_lastQuestionDate!).inDays >= 1;
  }
}

