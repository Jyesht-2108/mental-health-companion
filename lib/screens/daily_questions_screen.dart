import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_companion/providers/voice_provider.dart';
import 'package:mental_health_companion/providers/app_state_provider.dart';
import 'package:mental_health_companion/providers/brain_visualization_provider.dart';
import 'package:mental_health_companion/config/app_config.dart';

class DailyQuestionsScreen extends StatefulWidget {
  const DailyQuestionsScreen({super.key});

  @override
  State<DailyQuestionsScreen> createState() => _DailyQuestionsScreenState();
}

class _DailyQuestionsScreenState extends State<DailyQuestionsScreen> {
  int _currentQuestionIndex = 0;
  final List<String> _questions = [
    'How are you feeling today?',
    'What\'s been on your mind lately?',
    'What are you grateful for today?',
    'How would you describe your energy level?',
    'Is there anything causing you stress or anxiety?',
  ];
  final List<Map<String, dynamic>> _responses = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    context.read<VoiceProvider>().initialize();
  }

  void _loadQuestions() {
    final appState = context.read<AppStateProvider>();
    if (appState.dailyQuestions.isNotEmpty) {
      _questions.clear();
      _questions.addAll(appState.dailyQuestions);
    } else {
      // Generate random questions
      final allQuestions = [
        'How are you feeling today?',
        'What\'s been on your mind lately?',
        'What are you grateful for today?',
        'How would you describe your energy level?',
        'Is there anything causing you stress or anxiety?',
        'What made you smile today?',
        'How did you sleep last night?',
        'What would you like to accomplish today?',
      ];
      _questions.clear();
      _questions.addAll(
        allQuestions.take(AppConfig.dailyQuestionsCount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Questions'),
        elevation: 0,
      ),
      body: Consumer<VoiceProvider>(
        builder: (context, voiceProvider, child) {
          if (_currentQuestionIndex >= _questions.length) {
            return _buildCompletionScreen();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 32),
                _buildQuestionCard(),
                const SizedBox(height: 24),
                _buildRecordingSection(voiceProvider),
                const SizedBox(height: 24),
                if (voiceProvider.transcribedText.isNotEmpty)
                  _buildTranscriptionCard(voiceProvider),
                const SizedBox(height: 24),
                _buildActionButtons(voiceProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Text(
          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.mic, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              _questions[_currentQuestionIndex],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection(VoiceProvider voiceProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (voiceProvider.isRecording)
              _buildRecordingIndicator()
            else
              IconButton(
                icon: const Icon(Icons.mic, size: 64),
                color: Colors.red,
                onPressed: () async {
                  try {
                    await voiceProvider.startRecording();
                    if (!voiceProvider.isRecording && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please grant microphone permission to record audio'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to start recording. Please check permissions in Settings.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              ),
            const SizedBox(height: 16),
            if (voiceProvider.isRecording)
              ElevatedButton.icon(
                onPressed: voiceProvider.stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              )
            else
              Text(
                'Tap the microphone to start recording',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return const SizedBox(
      height: 80,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTranscriptionCard(VoiceProvider voiceProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_fields, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Your Response',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              voiceProvider.transcribedText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(VoiceProvider voiceProvider) {
    return Column(
      children: [
        if (voiceProvider.transcribedText.isNotEmpty)
          ElevatedButton(
            onPressed: () => _submitResponse(voiceProvider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Submit Answer'),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _skipQuestion(voiceProvider),
          child: const Text('Skip Question'),
        ),
      ],
    );
  }

  Future<void> _submitResponse(VoiceProvider voiceProvider) async {
    if (voiceProvider.transcribedText.isEmpty) return;

    final response = {
      'question': _questions[_currentQuestionIndex],
      'text': voiceProvider.transcribedText,
      'audioPath': voiceProvider.audioPath,
      'emotion': voiceProvider.emotionAnalysis,
    };

    _responses.add(response);

    // Update brain visualization
    if (voiceProvider.emotionAnalysis != null) {
      context.read<BrainVisualizationProvider>()
          .updateActivityFromEmotion(voiceProvider.emotionAnalysis);
    }

    // Save to database
    await context.read<AppStateProvider>().updateUserState(
      context.read<AppStateProvider>().currentUserState ??
          (throw Exception('User state not initialized')),
    );

    voiceProvider.clearTranscription();

    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _skipQuestion(VoiceProvider voiceProvider) {
    voiceProvider.clearTranscription();
    setState(() {
      _currentQuestionIndex++;
    });
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Great job!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve completed today\'s questions. Check out your brain activity visualization!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.home),
              label: const Text('Return Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

