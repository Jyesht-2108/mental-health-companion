import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mental_health_companion/providers/brain_visualization_provider.dart';

class BrainVisualizationScreen extends StatefulWidget {
  const BrainVisualizationScreen({super.key});

  @override
  State<BrainVisualizationScreen> createState() => _BrainVisualizationScreenState();
}

class _BrainVisualizationScreenState extends State<BrainVisualizationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Activity'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BrainVisualizationProvider>().startAnimation();
            },
          ),
        ],
      ),
      body: Consumer<BrainVisualizationProvider>(
        builder: (context, provider, child) {
          if (provider.currentActivity == null) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBrainModel(provider),
                const SizedBox(height: 24),
                _buildActivityMetrics(provider),
                const SizedBox(height: 24),
                _buildRegionActivity(provider),
                const SizedBox(height: 24),
                _buildNeuralSignals(provider),
              ],
            ),
          );
        },
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
            Icon(Icons.psychology, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No brain activity data yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete daily questions to see your neural activity visualized',
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

  Widget _buildBrainModel(BrainVisualizationProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[100]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Placeholder for 3D brain model
            // In production, this would use flutter_gl or similar for 3D rendering
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    size: 120,
                    color: _getOverallActivityColor(provider),
                  ),
                  if (provider.isAnimating)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            // Overlay activity indicators
            ...provider.regionActivity.entries.map((entry) {
              return _buildRegionIndicator(entry.key, entry.value);
            }),
          ],
        ),
      ),
    );
  }

  Color _getOverallActivityColor(BrainVisualizationProvider provider) {
    if (provider.currentActivity == null) return Colors.grey;
    
    final avgActivity = provider.regionActivity.values.isEmpty
        ? 0.5
        : provider.regionActivity.values.reduce((a, b) => a + b) /
            provider.regionActivity.values.length;
    
    if (avgActivity > 0.7) return Colors.red;
    if (avgActivity > 0.4) return Colors.orange;
    return Colors.green;
  }

  Widget _buildRegionIndicator(String region, double intensity) {
    // Simplified region indicators
    // In production, these would be positioned on the 3D model
    return Positioned(
      left: 50 + (region.hashCode % 200).toDouble(),
      top: 50 + ((region.hashCode ~/ 10) % 200).toDouble(),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getIntensityColor(intensity).withValues(alpha: 0.7),
          boxShadow: [
            BoxShadow(
              color: _getIntensityColor(intensity),
              blurRadius: intensity * 10,
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity > 0.7) return Colors.red;
    if (intensity > 0.4) return Colors.orange;
    return Colors.green;
  }

  Widget _buildActivityMetrics(BrainVisualizationProvider provider) {
    final activity = provider.currentActivity!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Stress Level', activity.stressLevel),
            const SizedBox(height: 12),
            _buildMetricRow('Anxiety Level', activity.anxietyLevel),
            const SizedBox(height: 12),
            _buildMetricRow('Mood Score', activity.moodScore),
            const SizedBox(height: 12),
            _buildMetricRow('Energy Level', activity.energyLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${(value * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getIntensityColor(value),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionActivity(BrainVisualizationProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Brain Region Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...provider.regionActivity.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildRegionRow(entry.key, entry.value),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionRow(String region, double intensity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatRegionName(region),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(intensity * 100).toInt()}%',
                style: TextStyle(
                  color: _getIntensityColor(intensity),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: intensity,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getIntensityColor(intensity),
          ),
        ),
      ],
    );
  }

  String _formatRegionName(String region) {
    return region
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildNeuralSignals(BrainVisualizationProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Neural Signals',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...provider.neuralSignals.take(5).map((signal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getIntensityColor(signal.intensity),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatRegionName(signal.region),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${(signal.intensity * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

