import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mental_health_companion/config/api_config.dart';
import 'package:mental_health_companion/models/companion_message.dart';

class CompanionService {
  final FlutterTts _tts = FlutterTts();

  CompanionService() {
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<String> generateResponse(
    String userMessage, {
    Map<String, dynamic>? emotionContext,
    List<CompanionMessage> conversationHistory = const [],
  }) async {
    // Use OpenAI GPT for conversational responses
    if (ApiConfig.openAiApiKey.isNotEmpty && 
        ApiConfig.openAiApiKey != 'YOUR_OPENAI_API_KEY') {
      return await _generateWithGPT(userMessage, emotionContext, conversationHistory);
    }

    // Fallback to simple responses
    return _generateSimpleResponse(userMessage, emotionContext);
  }

  Future<String> _generateWithGPT(
    String userMessage,
    Map<String, dynamic>? emotionContext,
    List<CompanionMessage> conversationHistory,
  ) async {
    final url = Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions');
    
    // Build conversation history
    final messages = <Map<String, String>>[];
    
    // System prompt with emotion context
    String systemPrompt = '''You are a compassionate, empathetic mental health companion. 
You listen carefully, provide emotional support, and offer gentle guidance. 
You speak in a warm, understanding, and conversational tone. Keep responses concise (2-3 sentences).''';
    
    if (emotionContext != null) {
      systemPrompt += '\n\nCurrent emotional state detected:';
      if (emotionContext['stress'] != null) {
        systemPrompt += '\n- Stress level: ${(emotionContext['stress'] as num) * 100}%';
      }
      if (emotionContext['anxiety'] != null) {
        systemPrompt += '\n- Anxiety level: ${(emotionContext['anxiety'] as num) * 100}%';
      }
      if (emotionContext['mood'] != null) {
        systemPrompt += '\n- Mood: ${(emotionContext['mood'] as num) * 100}%';
      }
    }
    
    messages.add({'role': 'system', 'content': systemPrompt});
    
    // Add conversation history (last 5 messages)
    final recentHistory = conversationHistory.length > 5 
        ? conversationHistory.sublist(conversationHistory.length - 5)
        : conversationHistory;
    
    for (var msg in recentHistory) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    
    // Add current message
    messages.add({'role': 'user', 'content': userMessage});
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    }

    throw Exception('GPT API error: ${response.statusCode}');
  }

  String _generateSimpleResponse(String userMessage, Map<String, dynamic>? emotionContext) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (emotionContext != null) {
      final stress = emotionContext['stress'] as num? ?? 0.5;
      final mood = emotionContext['mood'] as num? ?? 0.5;
      
      if (stress > 0.7) {
        return "I can sense you're feeling quite stressed. That's completely understandable. Would you like to try some breathing exercises together?";
      } else if (mood < 0.4) {
        return "I hear you, and I'm here for you. Sometimes just talking about what's on your mind can help. What's been weighing on you?";
      }
    }
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return "Hello! How are you feeling today? I'm here to listen.";
    } else if (lowerMessage.contains('sad') || lowerMessage.contains('down')) {
      return "I'm sorry you're feeling this way. Your feelings are valid. Would you like to talk about what's making you feel sad?";
    } else if (lowerMessage.contains('anxious') || lowerMessage.contains('worried')) {
      return "Anxiety can be really challenging. Let's take a moment to breathe together. What's on your mind?";
    } else {
      return 'Thank you for sharing that with me. How does that make you feel?';
    }
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}

