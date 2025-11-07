class TherapyActivity {
  final String id;
  final String title;
  final String description;
  final String category;
  final int duration; // in minutes
  final String difficulty; // easy, medium, hard

  TherapyActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
  });
}

