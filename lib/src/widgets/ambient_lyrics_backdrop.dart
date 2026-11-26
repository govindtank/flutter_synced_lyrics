import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';

/// Dynamic ambient blurred canvas that renders reactive lighting and album art glows
/// behind lyrics (inspired by Apple Music and Spotify Canvas).
class AmbientLyricsBackdrop extends StatefulWidget {
  /// Optional album art or artwork image provider.
  final ImageProvider? image;

  /// Primary color theme if no image is supplied or for tinting.
  final Color primaryColor;

  /// Secondary color accent for dual-orb ambient lighting.
  final Color? secondaryColor;

  /// Gaussian blur intensity applied to the backdrop layer.
  final double blurSigma;

  /// Darkness overlay multiplier (0.0 to 1.0) to ensure high text contrast.
  final double darkness;

  /// Optional child placed directly over the backdrop (e.g., [LyricsView]).
  final Widget? child;

  const AmbientLyricsBackdrop({
    super.key,
    this.image,
    this.primaryColor = const Color(0xFF1E1B4B),
    this.secondaryColor,
    this.blurSigma = 50.0,
    this.darkness = 0.55,
    this.child,
  });

  @override
  State<AmbientLyricsBackdrop> createState() => _AmbientLyricsBackdropState();
}

class _AmbientLyricsBackdropState extends State<AmbientLyricsBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secColor = widget.secondaryColor ??
        Color.fromARGB(
          255,
          (widget.primaryColor.r * 255 * 0.4 + 40).clamp(0, 255).round(),
          (widget.primaryColor.g * 255 * 0.7 + 60).clamp(0, 255).round(),
          (widget.primaryColor.b * 255 * 1.2 + 80).clamp(0, 255).round(),
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark backdrop
        Container(color: const Color(0xFF0A0A0F)),

        // If image provided, render scaled blurred image
        if (widget.image != null)
          Positioned.fill(
            child: Image(
              image: widget.image!,
              fit: BoxFit.cover,
            ),
          ),

        // Animated organic floating gradient orbs
        AnimatedBuilder(
          animation: _motionController,
          builder: (context, child) {
            final t = _motionController.value * 2 * math.pi;
            final dx1 = math.sin(t) * 0.3;
            final dy1 = math.cos(t * 0.7) * 0.3;
            final dx2 = -math.cos(t * 0.8) * 0.3;
            final dy2 = math.sin(t * 0.6) * 0.3;

            return CustomPaint(
              painter: _AmbientOrbsPainter(
                primaryColor: widget.primaryColor,
                secondaryColor: secColor,
                offset1: Offset(dx1, dy1),
                offset2: Offset(dx2, dy2),
              ),
            );
          },
        ),

        // Deep Gaussian blur filter
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(
              sigmaX: widget.blurSigma,
              sigmaY: widget.blurSigma,
            ),
            child: Container(
              color: const Color(0xFF000000).withValues(alpha: widget.darkness),
            ),
          ),
        ),

        // Foreground content (LyricsView, controls, etc.)
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _AmbientOrbsPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Offset offset1;
  final Offset offset2;

  _AmbientOrbsPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.offset1,
    required this.offset2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c1 = Offset(
      size.width * (0.35 + offset1.dx),
      size.height * (0.30 + offset1.dy),
    );
    final paint1 = Paint()
      ..shader = ui.Gradient.radial(
        c1,
        size.width * 0.65,
        [
          primaryColor.withValues(alpha: 0.65),
          primaryColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawCircle(c1, size.width * 0.65, paint1);

    final c2 = Offset(
      size.width * (0.65 + offset2.dx),
      size.height * (0.70 + offset2.dy),
    );
    final paint2 = Paint()
      ..shader = ui.Gradient.radial(
        c2,
        size.width * 0.7,
        [
          secondaryColor.withValues(alpha: 0.55),
          secondaryColor.withValues(alpha: 0.0),
        ],
      );
    canvas.drawCircle(c2, size.width * 0.7, paint2);
  }

  @override
  bool shouldRepaint(_AmbientOrbsPainter oldDelegate) =>
      oldDelegate.offset1 != offset1 ||
      oldDelegate.offset2 != offset2 ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
