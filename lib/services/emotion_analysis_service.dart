import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mental_health_companion/config/api_config.dart';

class EmotionAnalysisService {
  // Analyze emotion from text and audio
  Future<Map<String, dynamic>> analyzeEmotion(String text, String audioPath) async {
    try {
      // Analyze text sentiment
      final textAnalysis = await _analyzeTextEmotion(text);
      
      // Analyze audio features (if backend available)
      final audioAnalysis = await _analyzeAudioEmotion(audioPath);
      
      // Combine results
      return _combineEmotionResults(textAnalysis, audioAnalysis);
    } catch (e) {
      // Fallback to basic text analysis
      return await _analyzeTextEmotion(text);
    }
  }

  Future<Map<String, dynamic>> _analyzeTextEmotion(String text) async {
    // Use OpenAI GPT for emotion analysis
    if (ApiConfig.openAiApiKey.isNotEmpty && 
        ApiConfig.openAiApiKey != 'YOUR_OPENAI_API_KEY') {
      return await _analyzeWithGPT(text);
    }

    // Fallback to simple keyword-based analysis
    return _simpleEmotionAnalysis(text);
  }

  Future<Map<String, dynamic>> _analyzeWithGPT(String text) async {
    final url = Uri.parse('${ApiConfig.openAiBaseUrl}/chat/completions');
    
    final prompt = '''
Analyze the emotional and mental state from this text. Return a JSON object with:
- stress: 0.0-1.0
- anxiety: 0.0-1.0
- mood: 0.0-1.0 (1.0 = very positive)
- energy: 0.0-1.0
- emotions: object with keys like "happy", "sad", "angry", "fearful", "calm" with 0.0-1.0 values

Text: "$text"
''';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiConfig.openAiApiKey}',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert in emotional and mental health analysis. Always return valid JSON only.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(content);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      }
    }

    return _simpleEmotionAnalysis(text);
  }

  Map<String, dynamic> _simpleEmotionAnalysis(String text) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword-based emotion detection
    final stressKeywords = ['stress', 'stressed', 'overwhelmed', 'pressure', 'worried'];
    final anxietyKeywords = ['anxious', 'anxiety', 'nervous', 'worried', 'fear'];
    final positiveKeywords = ['happy', 'good', 'great', 'wonderful', 'excited', 'joy'];
    final negativeKeywords = ['sad', 'bad', 'terrible', 'awful', 'depressed', 'down'];
    
    double stress = 0.0;
    double anxiety = 0.0;
    double mood = 0.5;
    double energy = 0.5;
    
    for (var keyword in stressKeywords) {
      if (lowerText.contains(keyword)) stress += 0.2;
    }
    
    for (var keyword in anxietyKeywords) {
      if (lowerText.contains(keyword)) anxiety += 0.2;
    }
    
    for (var keyword in positiveKeywords) {
      if (lowerText.contains(keyword)) {
        mood += 0.15;
        energy += 0.1;
      }
    }
    
    for (var keyword in negativeKeywords) {
      if (lowerText.contains(keyword)) {
        mood -= 0.15;
        energy -= 0.1;
      }
    }
    
    return {
      'stress': stress.clamp(0.0, 1.0),
      'anxiety': anxiety.clamp(0.0, 1.0),
      'mood': mood.clamp(0.0, 1.0),
      'energy': energy.clamp(0.0, 1.0),
      'emotions': {
        'happy': positiveKeywords.any((k) => lowerText.contains(k)) ? 0.7 : 0.3,
        'sad': negativeKeywords.any((k) => lowerText.contains(k)) ? 0.7 : 0.3,
        'anxious': anxiety,
        'calm': (1.0 - stress - anxiety).clamp(0.0, 1.0),
      },
    };
  }

  Future<Map<String, dynamic>> _analyzeAudioEmotion(String audioPath) async {
    // This would typically be done on a backend with audio processing libraries
    // For now, return empty map - can be enhanced with backend API call
    if (ApiConfig.backendUrl.isNotEmpty && 
        ApiConfig.backendUrl != 'YOUR_BACKEND_URL') {
      try {
        final file = File(audioPath);
        final audioBytes = await file.readAsBytes();
        final audioBase64 = base64Encode(audioBytes);
        
        final response = await http.post(
          Uri.parse('${ApiConfig.backendUrl}/analyze-audio'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'audio': audioBase64}),
        );
        
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {
        // Fallback to empty
      }
    }
    
    return {};
  }

  Map<String, dynamic> _combineEmotionResults(
    Map<String, dynamic> textAnalysis,
    Map<String, dynamic> audioAnalysis,
  ) {
    if (audioAnalysis.isEmpty) return textAnalysis;
    
    // Weighted combination: 70% text, 30% audio
    return {
      'stress': ((textAnalysis['stress'] as num? ?? 0.5) * 0.7 + 
                 (audioAnalysis['stress'] as num? ?? 0.5) * 0.3),
      'anxiety': ((textAnalysis['anxiety'] as num? ?? 0.5) * 0.7 + 
                  (audioAnalysis['anxiety'] as num? ?? 0.5) * 0.3),
      'mood': ((textAnalysis['mood'] as num? ?? 0.5) * 0.7 + 
               (audioAnalysis['mood'] as num? ?? 0.5) * 0.3),
      'energy': ((textAnalysis['energy'] as num? ?? 0.5) * 0.7 + 
                 (audioAnalysis['energy'] as num? ?? 0.5) * 0.3),
      'emotions': textAnalysis['emotions'] ?? {},
    };
  }
}

