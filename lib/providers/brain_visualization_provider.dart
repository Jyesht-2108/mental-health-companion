import 'package:flutter/foundation.dart';
import 'package:mental_health_companion/models/brain_activity.dart';

class BrainVisualizationProvider extends ChangeNotifier {
  BrainActivity? _currentActivity;
  Map<String, double> _regionActivity = {};
  List<NeuralSignal> _neuralSignals = [];
  bool _isAnimating = false;

  BrainActivity? get currentActivity => _currentActivity;
  Map<String, double> get regionActivity => _regionActivity;
  List<NeuralSignal> get neuralSignals => _neuralSignals;
  bool get isAnimating => _isAnimating;

  void updateActivityFromEmotion(Map<String, dynamic>? emotionData) {
    if (emotionData == null) return;

    _currentActivity = BrainActivity.fromEmotionData(emotionData);
    _updateRegionActivity();
    _generateNeuralSignals();
    notifyListeners();
  }

  void _updateRegionActivity() {
    if (_currentActivity == null) return;

    // Map emotions to brain regions
    final stress = _currentActivity!.stressLevel;
    final mood = _currentActivity!.moodScore;
    final anxiety = _currentActivity!.anxietyLevel;

    _regionActivity = {
      'prefrontal_cortex': (1.0 - stress).clamp(0.0, 1.0), // Higher stress = lower activity
      'amygdala': anxiety.clamp(0.0, 1.0), // Higher anxiety = higher activity
      'hippocampus': mood.clamp(0.0, 1.0), // Mood affects memory regions
      'anterior_cingulate': (stress * 0.7 + anxiety * 0.3).clamp(0.0, 1.0),
      'insula': ((stress + anxiety) / 2.0).clamp(0.0, 1.0),
    };
  }

  void _generateNeuralSignals() {
    _neuralSignals = [];
    
    for (var entry in _regionActivity.entries) {
      _neuralSignals.add(NeuralSignal(
        region: entry.key,
        intensity: entry.value,
        timestamp: DateTime.now(),
      ));
    }
  }

  void startAnimation() {
    _isAnimating = true;
    notifyListeners();
  }

  void stopAnimation() {
    _isAnimating = false;
    notifyListeners();
  }

  void updateActivity(BrainActivity activity) {
    _currentActivity = activity;
    _updateRegionActivity();
    _generateNeuralSignals();
    notifyListeners();
  }
}

