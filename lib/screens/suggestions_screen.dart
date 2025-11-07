import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_companion/providers/brain_visualization_provider.dart';
import 'package:mental_health_companion/services/therapy_suggestion_service.dart';
import 'package:mental_health_companion/models/therapy_activity.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  final TherapySuggestionService _suggestionService = TherapySuggestionService();
  List<TherapyActivity> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    final brainProvider = context.read<BrainVisualizationProvider>();
    
    if (brainProvider.currentActivity != null) {
      final activity = brainProvider.currentActivity!;
      _suggestions = _suggestionService.getSuggestions(
        stressLevel: activity.stressLevel,
        anxietyLevel: activity.anxietyLevel,
        moodScore: activity.moodScore,
        energyLevel: activity.energyLevel,
      );
    } else {
      _suggestions = _suggestionService.getAllActivities().take(3).toList();
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapy Suggestions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuggestions,
          ),
        ],
      ),
      body: Consumer<BrainVisualizationProvider>(
        builder: (context, brainProvider, child) {
          if (_suggestions.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(brainProvider),
                const SizedBox(height: 24),
                ..._suggestions.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildActivityCard(activity),
                  );
                }),
                const SizedBox(height: 16),
                _buildAllActivitiesSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BrainVisualizationProvider provider) {
    if (provider.currentActivity == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.lightbulb_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              Text(
                'Personalized Suggestions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete daily questions to get personalized recommendations',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

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
                const Icon(Icons.psychology, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Based on Your Current State',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These activities are tailored to help you based on your recent responses.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No suggestions available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete daily questions to receive personalized therapy suggestions',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(TherapyActivity activity) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showActivityDetails(activity),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildDifficultyBadge(activity.difficulty),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activity.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${activity.duration} minutes',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    activity.category.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'easy':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAllActivitiesSection() {
    final allActivities = _suggestionService.getAllActivities();
    
    return ExpansionTile(
      title: const Text('All Activities'),
      leading: const Icon(Icons.list),
      children: allActivities
          .where((a) => !_suggestions.contains(a))
          .map((activity) => _buildActivityCard(activity))
          .toList(),
    );
  }

  void _showActivityDetails(TherapyActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('Duration: ${activity.duration} minutes'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16),
                const SizedBox(width: 4),
                Text('Category: ${activity.category}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.signal_cellular_alt, size: 16),
                const SizedBox(width: 4),
                Text('Difficulty: ${activity.difficulty}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Start activity
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting ${activity.title}...'),
                ),
              );
            },
            child: const Text('Start Activity'),
          ),
        ],
      ),
    );
  }
}

