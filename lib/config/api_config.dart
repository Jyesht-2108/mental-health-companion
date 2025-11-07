import 'package:mental_health_companion/config/app_config.dart';

class ApiConfig {
  // Speech-to-Text APIs
  static String get googleSpeechApiKey => AppConfig.googleCloudApiKey;
  static String get googleSpeechApiUrl => AppConfig.googleSpeechApiUrl;
  static String get openAiApiKey => AppConfig.openAiApiKey;
  
  // Text-to-Speech: Uses flutter_tts (free, open-source, device-native TTS)
  
  // Conversational AI
  static String get openAiBaseUrl => AppConfig.openAiBaseUrl;
  
  // Backend
  static String get backendUrl => AppConfig.backendBaseUrl;
}

