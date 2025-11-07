class UserState {
  final String userId;
  final Map<String, double> emotionalState;
  final List<String> recentResponses;
  final DateTime lastUpdated;

  UserState({
    required this.userId,
    required this.emotionalState,
    required this.recentResponses,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'emotionalState': emotionalState,
    'recentResponses': recentResponses,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory UserState.fromJson(Map<String, dynamic> json) => UserState(
    userId: json['userId'] as String,
    emotionalState: Map<String, double>.from(json['emotionalState'] as Map),
    recentResponses: List<String>.from(json['recentResponses'] as List),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );
}

