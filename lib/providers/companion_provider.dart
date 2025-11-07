import 'package:flutter/foundation.dart';
import 'package:mental_health_companion/services/companion_service.dart';
import 'package:mental_health_companion/models/companion_message.dart';

class CompanionProvider extends ChangeNotifier {
  final CompanionService _companionService = CompanionService();
  
  final List<CompanionMessage> _messages = [];
  bool _isTyping = false;
  bool _isSpeaking = false;
  Map<String, dynamic>? _currentEmotionContext;

  List<CompanionMessage> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isSpeaking => _isSpeaking;
  Map<String, dynamic>? get currentEmotionContext => _currentEmotionContext;

  void updateEmotionContext(Map<String, dynamic>? emotionData) {
    _currentEmotionContext = emotionData;
  }

  Future<void> sendMessage(String userMessage, {Map<String, dynamic>? emotionData}) async {
    // Add user message
    _messages.add(CompanionMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Update emotion context
    if (emotionData != null) {
      updateEmotionContext(emotionData);
    }

    // Get companion response
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _companionService.generateResponse(
        userMessage,
        emotionContext: _currentEmotionContext,
        conversationHistory: _messages,
      );

      _messages.add(CompanionMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      // Speak the response
      await speakResponse(response);
    } catch (e) {
      debugPrint('Error generating companion response: $e');
      _messages.add(CompanionMessage(
        text: "I'm having trouble understanding right now. Could you try again?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> speakResponse(String text) async {
    _isSpeaking = true;
    notifyListeners();

    try {
      await _companionService.speak(text);
    } catch (e) {
      debugPrint('Error speaking response: $e');
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _currentEmotionContext = null;
    notifyListeners();
  }
}

