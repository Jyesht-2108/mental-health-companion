class BrainActivity {
  final double stressLevel;
  final double anxietyLevel;
  final double moodScore;
  final double energyLevel;
  final Map<String, double> emotionScores;
  final DateTime timestamp;

  BrainActivity({
    required this.stressLevel,
    required this.anxietyLevel,
    required this.moodScore,
    required this.energyLevel,
    required this.emotionScores,
    required this.timestamp,
  });

  factory BrainActivity.fromEmotionData(Map<String, dynamic> data) {
    return BrainActivity(
      stressLevel: (data['stress'] as num?)?.toDouble() ?? 0.5,
      anxietyLevel: (data['anxiety'] as num?)?.toDouble() ?? 0.5,
      moodScore: (data['mood'] as num?)?.toDouble() ?? 0.5,
      energyLevel: (data['energy'] as num?)?.toDouble() ?? 0.5,
      emotionScores: Map<String, double>.from(data['emotions'] as Map? ?? {}),
      timestamp: DateTime.now(),
    );
  }
}

class NeuralSignal {
  final String region;
  final double intensity;
  final DateTime timestamp;

  NeuralSignal({
    required this.region,
    required this.intensity,
    required this.timestamp,
  });
}

