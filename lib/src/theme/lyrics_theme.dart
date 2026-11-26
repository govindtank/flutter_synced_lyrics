import 'package:flutter/material.dart';

/// Styling attributes for an individual lyric line (active vs inactive states).
@immutable
class LyricLineStyle {
  /// Base text style for the primary lyrics.
  final TextStyle textStyle;

  /// Text style for the secondary translated subtitle line.
  final TextStyle? translationStyle;

  /// Text style for phonetic / romanized reading line.
  final TextStyle? romanizationStyle;

  /// Scale multiplier applied to the active line (e.g., 1.12 for Apple Music zoom).
  final double scale;

  /// Opacity multiplier (0.0 to 1.0).
  final double opacity;

  /// Gaussian blur sigma applied to text (e.g., 1.5 for Apple Music frosted blur).
  final double blurSigma;

  /// Text alignment within the viewport.
  final TextAlign textAlign;

  /// Padding around each lyric line block.
  final EdgeInsetsGeometry padding;

  const LyricLineStyle({
    required this.textStyle,
    this.translationStyle,
    this.romanizationStyle,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.blurSigma = 0.0,
    this.textAlign = TextAlign.left,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
  });

  LyricLineStyle copyWith({
    TextStyle? textStyle,
    TextStyle? translationStyle,
    TextStyle? romanizationStyle,
    double? scale,
    double? opacity,
    double? blurSigma,
    TextAlign? textAlign,
    EdgeInsetsGeometry? padding,
  }) {
    return LyricLineStyle(
      textStyle: textStyle ?? this.textStyle,
      translationStyle: translationStyle ?? this.translationStyle,
      romanizationStyle: romanizationStyle ?? this.romanizationStyle,
      scale: scale ?? this.scale,
      opacity: opacity ?? this.opacity,
      blurSigma: blurSigma ?? this.blurSigma,
      textAlign: textAlign ?? this.textAlign,
      padding: padding ?? this.padding,
    );
  }
}

/// Highlight shader and wipe properties for syllable-level karaoke rendering.
@immutable
class KaraokeHighlightStyle {
  /// The color of the sung / completed syllable text.
  final Color activeColor;

  /// The base un-highlighted color of upcoming syllables on the active line.
  final Color inactiveColor;

  /// Optional linear or sweep gradient used for the syllable wipe head.
  final Gradient? activeGradient;

  /// Whether active syllables emit a neon glow bloom.
  final bool enableGlow;

  /// Glow shadow color if [enableGlow] is true.
  final Color glowColor;

  /// Spread blur radius for the glow shadow.
  final double glowRadius;

  const KaraokeHighlightStyle({
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x66FFFFFF),
    this.activeGradient,
    this.enableGlow = false,
    this.glowColor = const Color(0x80FFFFFF),
    this.glowRadius = 8.0,
  });

  KaraokeHighlightStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Gradient? activeGradient,
    bool? enableGlow,
    Color? glowColor,
    double? glowRadius,
  }) {
    return KaraokeHighlightStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      activeGradient: activeGradient ?? this.activeGradient,
      enableGlow: enableGlow ?? this.enableGlow,
      glowColor: glowColor ?? this.glowColor,
      glowRadius: glowRadius ?? this.glowRadius,
    );
  }
}

/// Styling configuration for instrumental breaks and guitar solo pauses.
@immutable
class InstrumentalBreakStyle {
  /// Dot or wave visualizer accent color.
  final Color accentColor;

  /// Diameter of the pulsing indicator dots.
  final double dotSize;

  /// Number of animated lead-in / rhythm dots.
  final int dotCount;

  /// Whether to display remaining seconds countdown alongside the visualizer.
  final bool showCountdown;

  /// Text style for the countdown timer.
  final TextStyle? countdownTextStyle;

  const InstrumentalBreakStyle({
    this.accentColor = const Color(0xFF00E676),
    this.dotSize = 7.0,
    this.dotCount = 3,
    this.showCountdown = true,
    this.countdownTextStyle,
  });

  InstrumentalBreakStyle copyWith({
    Color? accentColor,
    double? dotSize,
    int? dotCount,
    bool? showCountdown,
    TextStyle? countdownTextStyle,
  }) {
    return InstrumentalBreakStyle(
      accentColor: accentColor ?? this.accentColor,
      dotSize: dotSize ?? this.dotSize,
      dotCount: dotCount ?? this.dotCount,
      showCountdown: showCountdown ?? this.showCountdown,
      countdownTextStyle: countdownTextStyle ?? this.countdownTextStyle,
    );
  }
}

/// Comprehensive visual theme for [LyricsView] and related lyrics widgets.
@immutable
class LyricsTheme {
  /// Appearance of the currently playing lyric line.
  final LyricLineStyle activeLineStyle;

  /// Appearance of upcoming and previously sung lines.
  final LyricLineStyle inactiveLineStyle;

  /// Fine-grained karaoke syllable highlight settings.
  final KaraokeHighlightStyle karaokeStyle;

  /// Visualizer and countdown styling during instrumental breaks.
  final InstrumentalBreakStyle instrumentalStyle;

  /// Spacing between consecutive lyric lines.
  final double lineSpacing;

  const LyricsTheme({
    required this.activeLineStyle,
    required this.inactiveLineStyle,
    this.karaokeStyle = const KaraokeHighlightStyle(),
    this.instrumentalStyle = const InstrumentalBreakStyle(),
    this.lineSpacing = 16.0,
  });

  LyricsTheme copyWith({
    LyricLineStyle? activeLineStyle,
    LyricLineStyle? inactiveLineStyle,
    KaraokeHighlightStyle? karaokeStyle,
    InstrumentalBreakStyle? instrumentalStyle,
    double? lineSpacing,
  }) {
    return LyricsTheme(
      activeLineStyle: activeLineStyle ?? this.activeLineStyle,
      inactiveLineStyle: inactiveLineStyle ?? this.inactiveLineStyle,
      karaokeStyle: karaokeStyle ?? this.karaokeStyle,
      instrumentalStyle: instrumentalStyle ?? this.instrumentalStyle,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }
}
