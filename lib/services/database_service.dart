import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mental_health_companion/models/user_state.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mental_health.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_responses (
        id TEXT PRIMARY KEY,
        question TEXT,
        response_text TEXT,
        audio_path TEXT,
        emotion_data TEXT,
        timestamp INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_state (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        state_data TEXT,
        updated_at INTEGER
      )
    ''');
  }

  Future<void> init() async {
    await database;
  }

  Future<void> saveUserResponse({
    required String question,
    required String responseText,
    String? audioPath,
    Map<String, dynamic>? emotionData,
  }) async {
    final db = await database;
    await db.insert('user_responses', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'question': question,
      'response_text': responseText,
      'audio_path': audioPath ?? '',
      'emotion_data': emotionData != null ? emotionData.toString() : '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<UserState?> getUserState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString('user_state');
    
    if (stateJson == null) {
      return UserState(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        emotionalState: {},
        recentResponses: [],
        lastUpdated: DateTime.now(),
      );
    }
    
    // Parse and return user state
    // Simplified for now
    return UserState(
      userId: prefs.getString('user_id') ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      emotionalState: {},
      recentResponses: [],
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> saveUserState(UserState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_state', state.toJson().toString());
    await prefs.setString('user_id', state.userId);
  }

  Future<DateTime?> getLastQuestionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('last_question_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  Future<void> saveLastQuestionDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_question_date', date.toIso8601String());
  }

  Future<List<String>> getDailyQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final questionsJson = prefs.getString('daily_questions');
    if (questionsJson == null) return [];
    
    // Parse JSON list
    try {
      return List<String>.from(questionsJson.split(','));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDailyQuestions(List<String> questions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('daily_questions', questions.join(','));
  }
}

