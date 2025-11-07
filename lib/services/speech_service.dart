import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mental_health_companion/config/api_config.dart';

class SpeechService {
  // Use OpenAI Whisper for transcription
  Future<String> transcribeAudio(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found');
      }

      // Option 1: OpenAI Whisper API
      if (ApiConfig.openAiApiKey.isNotEmpty && 
          ApiConfig.openAiApiKey != 'YOUR_OPENAI_API_KEY') {
        return await _transcribeWithWhisper(file);
      }

      // Option 2: Google Cloud Speech-to-Text (fallback)
      return await _transcribeWithGoogle(file);
    } catch (e) {
      throw Exception('Transcription failed: $e');
    }
  }

  Future<String> _transcribeWithWhisper(File audioFile) async {
    final url = Uri.parse('${ApiConfig.openAiBaseUrl}/audio/transcriptions');
    
    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer ${ApiConfig.openAiApiKey}';
    request.fields['model'] = 'whisper-1';
    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['text'] as String;
    }

    throw Exception('Whisper transcription failed: ${response.statusCode}');
  }

  Future<String> _transcribeWithGoogle(File audioFile) async {
    // Google Cloud Speech-to-Text implementation
    final url = Uri.parse(
      '${ApiConfig.googleSpeechApiUrl}/speech:recognize?key=${ApiConfig.googleSpeechApiKey}',
    );

    final audioBytes = await audioFile.readAsBytes();
    final audioBase64 = base64Encode(audioBytes);

    final requestBody = {
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
        'enableAutomaticPunctuation': true,
      },
      'audio': {
        'content': audioBase64,
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['alternatives'][0]['transcript'] as String;
      }
    }

    throw Exception('Google transcription failed: ${response.statusCode}');
  }
}

