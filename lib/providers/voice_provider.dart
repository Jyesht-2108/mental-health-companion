import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mental_health_companion/services/speech_service.dart';
import 'package:mental_health_companion/services/emotion_analysis_service.dart';

class VoiceProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _recorder = AudioRecorder();
  final SpeechService _speechService = SpeechService();
  final EmotionAnalysisService _emotionService = EmotionAnalysisService();

  bool _isListening = false;
  bool _isRecording = false;
  String _transcribedText = '';
  String? _audioPath;
  Map<String, dynamic>? _emotionAnalysis;
  bool _hasPermission = false;

  bool get isListening => _isListening;
  bool get isRecording => _isRecording;
  String get transcribedText => _transcribedText;
  String? get audioPath => _audioPath;
  Map<String, dynamic>? get emotionAnalysis => _emotionAnalysis;
  bool get hasPermission => _hasPermission;

  Future<void> initialize() async {
    _hasPermission = await _requestPermissions();
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    return micStatus.isGranted && storageStatus.isGranted;
  }

  Future<void> startRecording() async {
    if (!_hasPermission) {
      await initialize();
      if (!_hasPermission) return;
    }

    try {
      if (await _recorder.hasPermission()) {
        _isRecording = true;
        _transcribedText = '';
        final path = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          const RecordConfig(),
          path: path,
        );
        _audioPath = path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    try {
      _audioPath = await _recorder.stop();
      _isRecording = false;
      notifyListeners();

      if (_audioPath != null) {
        await transcribeAudio(_audioPath!);
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> transcribeAudio(String audioPath) async {
    try {
      _transcribedText = await _speechService.transcribeAudio(audioPath);
      notifyListeners();

      // Analyze emotion after transcription
      if (_transcribedText.isNotEmpty) {
        await analyzeEmotion(_transcribedText, audioPath);
      }
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
    }
  }

  Future<void> analyzeEmotion(String text, String audioPath) async {
    try {
      _emotionAnalysis = await _emotionService.analyzeEmotion(text, audioPath);
      notifyListeners();
    } catch (e) {
      debugPrint('Error analyzing emotion: $e');
    }
  }

  Future<void> startListening() async {
    if (!_hasPermission) {
      await initialize();
      if (!_hasPermission) return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );

    if (available) {
      _isListening = true;
      _transcribedText = '';
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          _transcribedText = result.recognizedWords;
          notifyListeners();
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  void clearTranscription() {
    _transcribedText = '';
    _emotionAnalysis = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recorder.dispose();
    _speech.cancel();
    super.dispose();
  }
}

