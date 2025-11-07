import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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
    try {
      // Request microphone permission
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // For Android 11+, we don't need storage permission for app-specific directories
      // Only request if needed for external storage
      if (await Permission.storage.isDenied) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          debugPrint('Storage permission denied, but continuing...');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      // Request permissions if not already granted
      if (!_hasPermission) {
        await initialize();
        if (!_hasPermission) {
          debugPrint('Permission not granted, cannot start recording');
          return;
        }
      }

      // Double-check recorder permission
      if (!await _recorder.hasPermission()) {
        debugPrint('Recorder permission check failed');
        _hasPermission = false;
        await initialize();
        if (!_hasPermission) {
          return;
        }
      }

      // Get app documents directory for saving audio
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = path.join(directory.path, fileName);

      _isRecording = true;
      _transcribedText = '';
      _audioPath = null;
      notifyListeners();

      // Start recording with proper path
      await _recorder.start(
        const RecordConfig(),
        path: filePath,
      );
      
      _audioPath = filePath;
      notifyListeners();
      debugPrint('Recording started: $filePath');
    } catch (e, stackTrace) {
      debugPrint('Error starting recording: $e');
      debugPrint('Stack trace: $stackTrace');
      _isRecording = false;
      _audioPath = null;
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

