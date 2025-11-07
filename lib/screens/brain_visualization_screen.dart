import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:mental_health_companion/providers/brain_visualization_provider.dart';

class BrainVisualizationScreen extends StatefulWidget {
  const BrainVisualizationScreen({super.key});

  @override
  State<BrainVisualizationScreen> createState() => _BrainVisualizationScreenState();
}

class _BrainVisualizationScreenState extends State<BrainVisualizationScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
              Colors.purple[50]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: BrainPainter(
                provider.regionActivity, 
                provider.isAnimating,
                _animationController.value,
              ),
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (provider.isAnimating)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  'Neural Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getOverallActivityColor(provider),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
              ),
            );
          },
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

// Custom painter for brain visualization
class BrainPainter extends CustomPainter {
  final Map<String, double> regionActivity;
  final bool isAnimating;
  final double animationValue;

  BrainPainter(this.regionActivity, this.isAnimating, [this.animationValue = 0.0]);

  Color _getIntensityColor(double intensity) {
    if (intensity > 0.7) return Colors.red;
    if (intensity > 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final brainWidth = size.width * 0.7;
    final brainHeight = size.height * 0.7;

    // Draw brain outline (simplified brain shape)
    final brainPath = Path();
    brainPath.addOval(Rect.fromCenter(
      center: center,
      width: brainWidth,
      height: brainHeight,
    ));

    // Draw base brain color
    final basePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;
    canvas.drawPath(brainPath, basePaint);

    // Draw brain outline
    final outlinePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(brainPath, outlinePaint);

    // Draw brain regions with activity
    if (regionActivity.isNotEmpty) {
      final regionPositions = {
        'prefrontal_cortex': Offset(center.dx, center.dy - brainHeight * 0.2),
        'amygdala': Offset(center.dx - brainWidth * 0.15, center.dy),
        'hippocampus': Offset(center.dx + brainWidth * 0.15, center.dy),
        'anterior_cingulate': Offset(center.dx, center.dy - brainHeight * 0.05),
        'insula': Offset(center.dx - brainWidth * 0.1, center.dy + brainHeight * 0.1),
      };

      regionActivity.forEach((region, intensity) {
        final position = regionPositions[region] ?? center;
        final radius = 20 + (intensity * 30);
        final color = _getIntensityColor(intensity);

        // Draw pulsing effect if animating
        final pulseRadius = isAnimating
            ? radius + (math.sin(animationValue * math.pi * 2) * 5).abs()
            : radius;

        // Draw glow effect
        final glowPaint = Paint()
          ..color = color.withValues(alpha: intensity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
        canvas.drawCircle(position, pulseRadius + 10, glowPaint);

        // Draw region circle
        final regionPaint = Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(position, pulseRadius, regionPaint);

        // Draw border
        final borderPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(position, pulseRadius, borderPaint);

        // Draw intensity indicator lines
        if (intensity > 0.3) {
          final linePaint = Paint()
            ..color = color
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke;
          
          for (int i = 0; i < 8; i++) {
            final angle = (i * math.pi * 2) / 8;
            final startRadius = pulseRadius + 5;
            final endRadius = startRadius + (intensity * 15);
            final startX = position.dx + math.cos(angle) * startRadius;
            final startY = position.dy + math.sin(angle) * startRadius;
            final endX = position.dx + math.cos(angle) * endRadius;
            final endY = position.dy + math.sin(angle) * endRadius;
            
            canvas.drawLine(
              Offset(startX, startY),
              Offset(endX, endY),
              linePaint,
            );
          }
        }
      });
    }

    // Draw neural connections between active regions
    if (regionActivity.length > 1 && regionActivity.values.any((v) => v > 0.3)) {
      final activeRegions = regionActivity.entries
          .where((e) => e.value > 0.3)
          .toList();
      
      for (int i = 0; i < activeRegions.length - 1; i++) {
        for (int j = i + 1; j < activeRegions.length; j++) {
          final region1 = activeRegions[i];
          final region2 = activeRegions[j];
          
          final pos1 = _getRegionPosition(region1.key, center, brainWidth, brainHeight);
          final pos2 = _getRegionPosition(region2.key, center, brainWidth, brainHeight);
          
          final connectionPaint = Paint()
            ..color = Colors.blue.withValues(alpha: 0.2)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(pos1, pos2, connectionPaint);
        }
      }
    }
  }

  Offset _getRegionPosition(String region, Offset center, double width, double height) {
    switch (region) {
      case 'prefrontal_cortex':
        return Offset(center.dx, center.dy - height * 0.2);
      case 'amygdala':
        return Offset(center.dx - width * 0.15, center.dy);
      case 'hippocampus':
        return Offset(center.dx + width * 0.15, center.dy);
      case 'anterior_cingulate':
        return Offset(center.dx, center.dy - height * 0.05);
      case 'insula':
        return Offset(center.dx - width * 0.1, center.dy + height * 0.1);
      default:
        return center;
    }
  }

  @override
  bool shouldRepaint(BrainPainter oldDelegate) {
    return oldDelegate.regionActivity != regionActivity ||
        oldDelegate.isAnimating != isAnimating ||
        oldDelegate.animationValue != animationValue;
  }
}

