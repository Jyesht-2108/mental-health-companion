import 'package:mental_health_companion/models/therapy_activity.dart';

class TherapySuggestionService {
  final List<TherapyActivity> _activities = [
    TherapyActivity(
      id: '1',
      title: 'Deep Breathing Exercise',
      description: 'Take 5 minutes to focus on your breath. Inhale for 4 counts, hold for 4, exhale for 4.',
      category: 'breathing',
      duration: 5,
      difficulty: 'easy',
    ),
    TherapyActivity(
      id: '2',
      title: 'Mindful Walking',
      description: 'Take a 10-minute walk, paying attention to each step and your surroundings.',
      category: 'mindfulness',
      duration: 10,
      difficulty: 'easy',
    ),
    TherapyActivity(
      id: '3',
      title: 'Gratitude Journaling',
      description: 'Write down three things you\'re grateful for today.',
      category: 'journaling',
      duration: 5,
      difficulty: 'easy',
    ),
    TherapyActivity(
      id: '4',
      title: 'Progressive Muscle Relaxation',
      description: 'Tense and relax each muscle group from head to toe.',
      category: 'relaxation',
      duration: 15,
      difficulty: 'medium',
    ),
    TherapyActivity(
      id: '5',
      title: 'Body Scan Meditation',
      description: 'Focus your attention on different parts of your body, noticing sensations without judgment.',
      category: 'meditation',
      duration: 10,
      difficulty: 'medium',
    ),
    TherapyActivity(
      id: '6',
      title: 'Cognitive Reframing',
      description: 'Identify negative thoughts and reframe them in a more balanced way.',
      category: 'cbt',
      duration: 10,
      difficulty: 'medium',
    ),
  ];

  List<TherapyActivity> getSuggestions({
    double? stressLevel,
    double? anxietyLevel,
    double? moodScore,
    double? energyLevel,
  }) {
    // Filter activities based on emotional state
    List<TherapyActivity> suggestions = [];

    if (stressLevel != null && stressLevel > 0.7) {
      // High stress - suggest breathing and relaxation
      suggestions.addAll(
        _activities.where((a) => 
          a.category == 'breathing' || 
          a.category == 'relaxation'
        ),
      );
    }

    if (anxietyLevel != null && anxietyLevel > 0.7) {
      // High anxiety - suggest mindfulness and meditation
      suggestions.addAll(
        _activities.where((a) => 
          a.category == 'mindfulness' || 
          a.category == 'meditation'
        ),
      );
    }

    if (moodScore != null && moodScore < 0.4) {
      // Low mood - suggest journaling and CBT
      suggestions.addAll(
        _activities.where((a) => 
          a.category == 'journaling' || 
          a.category == 'cbt'
        ),
      );
    }

    if (energyLevel != null && energyLevel < 0.4) {
      // Low energy - suggest light activities
      suggestions.addAll(
        _activities.where((a) => 
          a.difficulty == 'easy' && 
          a.duration <= 10
        ),
      );
    }

    // If no specific suggestions, return general easy activities
    if (suggestions.isEmpty) {
      suggestions = _activities
          .where((a) => a.difficulty == 'easy')
          .take(3)
          .toList();
    }

    // Remove duplicates and limit to 3
    return suggestions.toSet().take(3).toList();
  }

  List<TherapyActivity> getAllActivities() => _activities;
}

