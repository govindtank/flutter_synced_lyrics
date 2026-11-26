import 'package:flutter/widgets.dart';
import '../theme/lyrics_theme.dart';

/// Animated visualizer dots and remaining time countdown shown during guitar solos and verse breaks.
class InstrumentalIndicator extends StatefulWidget {
  final Duration remainingBreak;
  final InstrumentalBreakStyle style;

  const InstrumentalIndicator({
    super.key,
    required this.remainingBreak,
    required this.style,
  });

  @override
  State<InstrumentalIndicator> createState() => _InstrumentalIndicatorState();
}

class _InstrumentalIndicatorState extends State<InstrumentalIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingSecs = (widget.remainingBreak.inMilliseconds / 1000).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing rhythmic dots
          AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.style.dotCount, (i) {
                  final phase = (i / widget.style.dotCount);
                  final value = (_anim.value + phase) % 1.0;
                  final scale = 0.6 + 0.6 * (1.0 - (value - 0.5).abs() * 2);
                  final opacity = 0.3 + 0.7 * (1.0 - (value - 0.5).abs() * 2);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: widget.style.dotSize * scale,
                    height: widget.style.dotSize * scale,
                    decoration: BoxDecoration(
                      color:
                          widget.style.accentColor.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.style.accentColor.withValues(
                            alpha: opacity * 0.5,
                          ),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
          if (widget.style.showCountdown && remainingSecs > 0) ...[
            const SizedBox(width: 14),
            Text(
              '${remainingSecs}s',
              style: widget.style.countdownTextStyle ??
                  TextStyle(
                    color: widget.style.accentColor.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
