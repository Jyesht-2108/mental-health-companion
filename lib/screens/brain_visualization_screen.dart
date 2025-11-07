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
          // Show empty state only if there's no activity data at all
          if (provider.currentActivity == null && provider.regionActivity.isEmpty) {
            return _buildEmptyState();
          }

          // Start animation if there's activity
          if (provider.regionActivity.isNotEmpty && !provider.isAnimating) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.startAnimation();
            });
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
    final brainWidth = size.width * 0.75;
    final brainHeight = size.height * 0.75;

    // Draw realistic brain shape (more detailed than oval)
    final brainPath = _createBrainShape(center, brainWidth, brainHeight);

    // Draw 3D effect with gradient
    final brainGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.purple[200]!,
        Colors.blue[200]!,
        Colors.purple[300]!,
      ],
    );
    
    final basePaint = Paint()
      ..shader = brainGradient.createShader(
        Rect.fromCenter(center: center, width: brainWidth, height: brainHeight),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(brainPath, basePaint);

    // Draw brain outline with shadow effect
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(brainPath, shadowPaint);

    final outlinePaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(brainPath, outlinePaint);

    // Draw brain texture (sulci/gyri lines)
    _drawBrainTexture(canvas, brainPath, center, brainWidth, brainHeight);

    // Draw brain regions with activity
    if (regionActivity.isNotEmpty) {
      final regionPositions = {
        'prefrontal_cortex': Offset(center.dx, center.dy - brainHeight * 0.25),
        'amygdala': Offset(center.dx - brainWidth * 0.2, center.dy + brainHeight * 0.05),
        'hippocampus': Offset(center.dx + brainWidth * 0.2, center.dy + brainHeight * 0.05),
        'anterior_cingulate': Offset(center.dx, center.dy - brainHeight * 0.08),
        'insula': Offset(center.dx - brainWidth * 0.12, center.dy + brainHeight * 0.15),
      };

      regionActivity.forEach((region, intensity) {
        final position = regionPositions[region] ?? center;
        const baseRadius = 25.0;
        final radius = baseRadius + (intensity * 40);
        final color = _getIntensityColor(intensity);

        // Draw pulsing effect if animating
        final pulseRadius = isAnimating
            ? radius + (math.sin(animationValue * math.pi * 2) * 8).abs()
            : radius;

        // Draw multiple glow layers for better visibility
        for (int i = 3; i > 0; i--) {
          final glowPaint = Paint()
            ..color = color.withValues(alpha: intensity * 0.2 / i)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * i);
          canvas.drawCircle(position, pulseRadius + (i * 8), glowPaint);
        }

        // Draw region circle with gradient for 3D effect
        final regionGradient = RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.6),
            color.withValues(alpha: 0.3),
          ],
        );
        
        final regionPaint = Paint()
          ..shader = regionGradient.createShader(
            Rect.fromCircle(center: position, radius: pulseRadius),
          )
          ..style = PaintingStyle.fill;
        canvas.drawCircle(position, pulseRadius, regionPaint);

        // Draw border with highlight
        final borderPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(position, pulseRadius, borderPaint);

        // Draw highlight for 3D effect
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(position.dx - pulseRadius * 0.3, position.dy - pulseRadius * 0.3),
          pulseRadius * 0.3,
          highlightPaint,
        );

        // Draw intensity indicator lines (more visible)
        if (intensity > 0.2) {
          final lineCount = (intensity * 12).round();
          final linePaint = Paint()
            ..color = color
            ..strokeWidth = 2.0
            ..style = PaintingStyle.stroke;
          
          for (int i = 0; i < lineCount; i++) {
            final angle = (i * math.pi * 2) / lineCount;
            final startRadius = pulseRadius + 8;
            final endRadius = startRadius + (intensity * 20);
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

        // Draw region label
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getRegionLabel(region),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(position.dx - textPainter.width / 2, position.dy + pulseRadius + 5),
        );
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

  Path _createBrainShape(Offset center, double width, double height) {
    final path = Path();
    final left = center.dx - width / 2;
    final top = center.dy - height / 2;
    final right = center.dx + width / 2;
    final bottom = center.dy + height / 2;

    // Create a more realistic brain shape (two hemispheres)
    path.moveTo(center.dx, top);
    
    // Left hemisphere
    path.cubicTo(
      left + width * 0.1, top + height * 0.1,
      left + width * 0.05, center.dy - height * 0.1,
      left + width * 0.15, center.dy,
    );
    path.cubicTo(
      left + width * 0.1, center.dy + height * 0.2,
      left + width * 0.2, bottom - height * 0.1,
      center.dx - width * 0.05, bottom,
    );
    
    // Bottom curve
    path.cubicTo(
      center.dx - width * 0.02, bottom + height * 0.05,
      center.dx + width * 0.02, bottom + height * 0.05,
      center.dx + width * 0.05, bottom,
    );
    
    // Right hemisphere
    path.cubicTo(
      right - width * 0.2, bottom - height * 0.1,
      right - width * 0.1, center.dy + height * 0.2,
      right - width * 0.15, center.dy,
    );
    path.cubicTo(
      right - width * 0.05, center.dy - height * 0.1,
      right - width * 0.1, top + height * 0.1,
      center.dx, top,
    );
    
    path.close();
    return path;
  }

  void _drawBrainTexture(Canvas canvas, Path brainPath, Offset center, double width, double height) {
    final texturePaint = Paint()
      ..color = Colors.grey[700]!.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw sulci (grooves) lines
    for (int i = 0; i < 8; i++) {
      final y = center.dy - height * 0.3 + (i * height * 0.6 / 8);
      final startX = center.dx - width * 0.3;
      final endX = center.dx + width * 0.3;
      
      final path = Path();
      path.moveTo(startX, y);
      
      // Wavy line for texture
      for (double x = startX; x < endX; x += 10) {
        final wave = math.sin((x - startX) / 20) * 3;
        path.lineTo(x, y + wave);
      }
      
      canvas.drawPath(path, texturePaint);
    }
  }

  String _getRegionLabel(String region) {
    switch (region) {
      case 'prefrontal_cortex':
        return 'PFC';
      case 'amygdala':
        return 'AMY';
      case 'hippocampus':
        return 'HIP';
      case 'anterior_cingulate':
        return 'ACC';
      case 'insula':
        return 'INS';
      default:
        return region.toUpperCase();
    }
  }

  Offset _getRegionPosition(String region, Offset center, double width, double height) {
    switch (region) {
      case 'prefrontal_cortex':
        return Offset(center.dx, center.dy - height * 0.25);
      case 'amygdala':
        return Offset(center.dx - width * 0.2, center.dy + height * 0.05);
      case 'hippocampus':
        return Offset(center.dx + width * 0.2, center.dy + height * 0.05);
      case 'anterior_cingulate':
        return Offset(center.dx, center.dy - height * 0.08);
      case 'insula':
        return Offset(center.dx - width * 0.12, center.dy + height * 0.15);
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

