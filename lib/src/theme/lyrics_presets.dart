import 'package:flutter/widgets.dart';
import 'lyrics_theme.dart';

/// Ready-to-use trending visual style presets for [LyricsView].
class LyricsPreset {
  const LyricsPreset._();

  static const Color _white = Color(0xFFFFFFFF);

  /// Apple Music style:
  /// - Syllable-by-syllable smooth gradient wipe
  /// - Active line scaled to 1.10x with zero blur
  /// - Inactive lines dimmed to 35% opacity and frosted with a 1.2px gaussian blur
  /// - Left-aligned with comfortable vertical rhythm
  static LyricsTheme appleMusic({
    Color activeColor = _white,
    Color inactiveColor = const Color(0x59FFFFFF),
    Color highlightColor = _white,
    double activeScale = 1.10,
    bool blurInactive = true,
    double baseFontSize = 26.0,
    LyricFlowMode flowMode = LyricFlowMode.word,
  }) {
    return LyricsTheme(
      lineSpacing: 18.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: activeColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        translationStyle: TextStyle(
          color: activeColor.withValues(alpha: 0.85),
          fontSize: baseFontSize * 0.65,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        romanizationStyle: TextStyle(
          color: activeColor.withValues(alpha: 0.7),
          fontSize: baseFontSize * 0.55,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.2,
          height: 1.3,
        ),
        scale: activeScale,
        opacity: 1.0,
        blurSigma: 0.0,
        textAlign: TextAlign.left,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: inactiveColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        translationStyle: TextStyle(
          color: inactiveColor.withValues(alpha: 0.4),
          fontSize: baseFontSize * 0.65,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        romanizationStyle: TextStyle(
          color: inactiveColor.withValues(alpha: 0.35),
          fontSize: baseFontSize * 0.55,
          fontStyle: FontStyle.italic,
          height: 1.3,
        ),
        scale: 1.0,
        opacity: 0.38,
        blurSigma: blurInactive ? 1.2 : 0.0,
        textAlign: TextAlign.left,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: highlightColor,
        inactiveColor: inactiveColor,
        activeGradient: const LinearGradient(
          colors: [_white, Color(0xFFF0F0FF)],
        ),
        enableGlow: false,
        flowMode: flowMode,
      ),
      instrumentalStyle: const InstrumentalBreakStyle(
        accentColor: _white,
        dotSize: 6.0,
        dotCount: 3,
        showCountdown: true,
      ),
    );
  }

  /// Spotify style:
  /// - High-contrast bold typography
  /// - Active line snaps cleanly to center
  /// - Inactive lines dimmed to 30% opacity without heavy blur
  static LyricsTheme spotify({
    Color activeColor = _white,
    Color inactiveColor = const Color(0x4DFFFFFF),
    TextAlign textAlign = TextAlign.left,
    double baseFontSize = 24.0,
    LyricFlowMode flowMode = LyricFlowMode.word,
  }) {
    return LyricsTheme(
      lineSpacing: 14.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: activeColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        translationStyle: TextStyle(
          color: activeColor.withValues(alpha: 0.8),
          fontSize: baseFontSize * 0.65,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        scale: 1.04,
        opacity: 1.0,
        blurSigma: 0.0,
        textAlign: textAlign,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: inactiveColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          height: 1.3,
        ),
        translationStyle: TextStyle(
          color: inactiveColor.withValues(alpha: 0.4),
          fontSize: baseFontSize * 0.65,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        scale: 1.0,
        opacity: 0.32,
        blurSigma: 0.0,
        textAlign: textAlign,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        flowMode: flowMode,
      ),
      instrumentalStyle: const InstrumentalBreakStyle(
        accentColor: Color(0xFF1ED760),
        dotSize: 6.0,
        dotCount: 3,
        showCountdown: true,
      ),
    );
  }

  /// Bollywood Royal style:
  /// - Rich saffron and warm amber gold highlights with Devanagari typography
  /// - Subtly blurred inactive lines with royal gold bloom
  /// - Character-by-character fluid flowing (ideal for Hindi & Devanagari songs)
  static LyricsTheme bollywoodRoyal({
    Color gold = const Color(0xFFFFD700),
    Color saffron = const Color(0xFFFF9933),
    Color inactiveColor = const Color(0x4DFFFFFF),
    double baseFontSize = 26.0,
    LyricFlowMode flowMode = LyricFlowMode.characterSmooth,
  }) {
    return LyricsTheme(
      lineSpacing: 18.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: gold,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          shadows: [
            Shadow(
              color: gold.withValues(alpha: 0.65),
              blurRadius: 14,
            ),
          ],
          height: 1.35,
        ),
        translationStyle: TextStyle(
          color: saffron,
          fontSize: baseFontSize * 0.68,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        romanizationStyle: TextStyle(
          color: _white.withValues(alpha: 0.85),
          fontSize: baseFontSize * 0.58,
          fontStyle: FontStyle.italic,
          letterSpacing: 0.3,
          height: 1.3,
        ),
        scale: 1.10,
        opacity: 1.0,
        blurSigma: 0.0,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: inactiveColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.35,
        ),
        translationStyle: TextStyle(
          color: saffron.withValues(alpha: 0.4),
          fontSize: baseFontSize * 0.68,
          height: 1.4,
        ),
        romanizationStyle: TextStyle(
          color: inactiveColor.withValues(alpha: 0.4),
          fontSize: baseFontSize * 0.58,
          fontStyle: FontStyle.italic,
          height: 1.3,
        ),
        scale: 1.0,
        opacity: 0.36,
        blurSigma: 1.0,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: gold,
        inactiveColor: inactiveColor,
        enableGlow: true,
        glowColor: gold.withValues(alpha: 0.75),
        glowRadius: 12.0,
        flowMode: flowMode,
      ),
      instrumentalStyle: const InstrumentalBreakStyle(
        accentColor: Color(0xFFFF9933),
        dotSize: 7.0,
        dotCount: 4,
        showCountdown: true,
      ),
    );
  }

  /// Musixmatch style:
  /// - High-energy neon yellow / green fill
  /// - Glowing syllable head and animated lead-in dots
  static LyricsTheme musixmatch({
    Color neonColor = const Color(0xFFFFE600),
    Color inactiveColor = const Color(0x4DFFFFFF),
    double baseFontSize = 26.0,
    LyricFlowMode flowMode = LyricFlowMode.word,
  }) {
    return LyricsTheme(
      lineSpacing: 16.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: neonColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
          shadows: [
            Shadow(
              color: neonColor.withValues(alpha: 0.6),
              blurRadius: 12,
            ),
          ],
          height: 1.3,
        ),
        scale: 1.08,
        opacity: 1.0,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: inactiveColor,
          fontSize: baseFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        scale: 1.0,
        opacity: 0.35,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: neonColor,
        inactiveColor: inactiveColor,
        enableGlow: true,
        glowColor: neonColor.withValues(alpha: 0.7),
        glowRadius: 14.0,
        flowMode: flowMode,
      ),
      instrumentalStyle: InstrumentalBreakStyle(
        accentColor: neonColor,
        dotSize: 8.0,
        dotCount: 3,
        showCountdown: true,
      ),
    );
  }

  /// Cyberpunk HUD style:
  /// - Monospace typography with glowing cyan & magenta neon accents
  /// - Scanline and terminal vibe
  static LyricsTheme cyberpunk({
    Color cyan = const Color(0xFF00F0FF),
    Color magenta = const Color(0xFFFF0055),
    Color inactive = const Color(0xFF0D404A),
    double baseFontSize = 22.0,
    LyricFlowMode flowMode = LyricFlowMode.characterSmooth,
  }) {
    return LyricsTheme(
      lineSpacing: 14.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: cyan,
          fontFamily: 'monospace',
          fontSize: baseFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: cyan.withValues(alpha: 0.8),
              blurRadius: 10,
            ),
          ],
          height: 1.35,
        ),
        translationStyle: TextStyle(
          color: magenta,
          fontFamily: 'monospace',
          fontSize: baseFontSize * 0.7,
          letterSpacing: 0.8,
        ),
        scale: 1.05,
        opacity: 1.0,
        textAlign: TextAlign.left,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: inactive,
          fontFamily: 'monospace',
          fontSize: baseFontSize,
          letterSpacing: 1.0,
          height: 1.35,
        ),
        translationStyle: TextStyle(
          color: magenta.withValues(alpha: 0.3),
          fontFamily: 'monospace',
          fontSize: baseFontSize * 0.7,
        ),
        scale: 1.0,
        opacity: 0.45,
        textAlign: TextAlign.left,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: cyan,
        inactiveColor: inactive,
        enableGlow: true,
        glowColor: cyan.withValues(alpha: 0.9),
        glowRadius: 12.0,
        flowMode: flowMode,
      ),
      instrumentalStyle: InstrumentalBreakStyle(
        accentColor: magenta,
        dotSize: 6.0,
        dotCount: 4,
        showCountdown: true,
      ),
    );
  }

  /// Minimalist Hi-Fi Vinyl style:
  /// - Clean editorial serif typography with subtle organic transitions
  /// - Refined elegance, distraction-free
  static LyricsTheme minimalistVinyl({
    Color textColor = const Color(0xFFF5F5F7),
    Color dimmedColor = const Color(0x59F5F5F7),
    double baseFontSize = 24.0,
    LyricFlowMode flowMode = LyricFlowMode.word,
  }) {
    return LyricsTheme(
      lineSpacing: 20.0,
      activeLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: textColor,
          fontFamily: 'serif',
          fontSize: baseFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          fontStyle: FontStyle.italic,
          height: 1.45,
        ),
        scale: 1.06,
        opacity: 1.0,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
      ),
      inactiveLineStyle: LyricLineStyle(
        textStyle: TextStyle(
          color: dimmedColor,
          fontFamily: 'serif',
          fontSize: baseFontSize,
          letterSpacing: 0.2,
          fontStyle: FontStyle.italic,
          height: 1.45,
        ),
        scale: 1.0,
        opacity: 0.35,
        textAlign: TextAlign.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 28),
      ),
      karaokeStyle: KaraokeHighlightStyle(
        activeColor: textColor,
        inactiveColor: dimmedColor,
        flowMode: flowMode,
      ),
      instrumentalStyle: InstrumentalBreakStyle(
        accentColor: textColor.withValues(alpha: 0.7),
        dotSize: 5.0,
        dotCount: 3,
        showCountdown: false,
      ),
    );
  }
}
