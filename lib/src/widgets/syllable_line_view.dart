import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/lyric_line.dart';
import '../models/lyric_syllable.dart';
import '../theme/lyrics_theme.dart';

/// Renders a single lyric line with syllable-by-syllable smooth progress wiping,
/// optional translation/romanization subtitles, and tap-to-seek interaction.
class SyllableLineView extends StatelessWidget {
  final LyricLine line;
  final bool isActive;
  final Duration currentPosition;
  final LyricLineStyle lineStyle;
  final KaraokeHighlightStyle karaokeStyle;
  final bool showTranslation;
  final bool showRomanization;
  final VoidCallback? onTap;

  const SyllableLineView({
    super.key,
    required this.line,
    required this.isActive,
    required this.currentPosition,
    required this.lineStyle,
    required this.karaokeStyle,
    this.showTranslation = true,
    this.showRomanization = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isActive && line.hasSyllables) {
      content = _buildSyllableRow();
    } else {
      content = _buildStandardLine();
    }

    // Apply inactive blur effect if specified
    if (!isActive && lineStyle.blurSigma > 0.0) {
      content = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: lineStyle.blurSigma,
          sigmaY: lineStyle.blurSigma,
        ),
        child: content,
      );
    }

    // Secondary translation and romanization tracks
    final hasTrans = showTranslation && line.hasTranslation;
    final hasRom = showRomanization && line.hasRomanization;

    if (hasTrans || hasRom) {
      content = Column(
        crossAxisAlignment: _crossAxisAlignmentFor(lineStyle.textAlign),
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRom) ...[
            Text(
              line.romanization!,
              style: lineStyle.romanizationStyle ??
                  lineStyle.textStyle.copyWith(
                    fontSize: lineStyle.textStyle.fontSize! * 0.6,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: lineStyle.textAlign,
            ),
            const SizedBox(height: 3),
          ],
          content,
          if (hasTrans) ...[
            const SizedBox(height: 5),
            Text(
              line.translation!,
              style: lineStyle.translationStyle ??
                  lineStyle.textStyle.copyWith(
                    fontSize: lineStyle.textStyle.fontSize! * 0.7,
                    color: lineStyle.textStyle.color?.withValues(alpha: 0.75),
                  ),
              textAlign: lineStyle.textAlign,
            ),
          ],
        ],
      );
    }

    final animated = AnimatedScale(
      scale: isActive ? lineStyle.scale : 1.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: _alignmentFor(lineStyle.textAlign),
      child: AnimatedOpacity(
        opacity: isActive ? lineStyle.opacity : lineStyle.opacity,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: Padding(
          padding: lineStyle.padding,
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: animated,
      );
    }

    return animated;
  }

  Widget _buildStandardLine() {
    return Text(
      line.text,
      style: lineStyle.textStyle,
      textAlign: lineStyle.textAlign,
    );
  }

  Widget _buildSyllableRow() {
    return Wrap(
      alignment: _wrapAlignmentFor(lineStyle.textAlign),
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final syllable in line.syllables)
          _SingleSyllableWidget(
            syllable: syllable,
            currentPosition: currentPosition,
            baseStyle: lineStyle.textStyle,
            highlightStyle: karaokeStyle,
          ),
      ],
    );
  }

  static CrossAxisAlignment _crossAxisAlignmentFor(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }

  static Alignment _alignmentFor(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  static WrapAlignment _wrapAlignmentFor(TextAlign align) {
    switch (align) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      default:
        return WrapAlignment.start;
    }
  }
}

class _SingleSyllableWidget extends StatelessWidget {
  final LyricSyllable syllable;
  final Duration currentPosition;
  final TextStyle baseStyle;
  final KaraokeHighlightStyle highlightStyle;

  const _SingleSyllableWidget({
    required this.syllable,
    required this.currentPosition,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    final progress = syllable.getProgress(currentPosition);

    final unhighlightedStyle = baseStyle.copyWith(
      color: highlightStyle.inactiveColor,
    );

    final highlightedStyle = baseStyle.copyWith(
      color: highlightStyle.activeColor,
      shadows: highlightStyle.enableGlow
          ? [
              Shadow(
                color: highlightStyle.glowColor,
                blurRadius: highlightStyle.glowRadius,
              ),
            ]
          : baseStyle.shadows,
    );

    // If fully upcoming
    if (progress <= 0.0) {
      return Text(syllable.text, style: unhighlightedStyle);
    }

    // If fully completed
    if (progress >= 1.0) {
      return Text(syllable.text, style: highlightedStyle);
    }

    // Actively wiping: dual-layer clip
    return Stack(
      children: [
        Text(syllable.text, style: unhighlightedStyle),
        ClipRect(
          clipper: _HorizontalProgressClipper(progress),
          child: Text(syllable.text, style: highlightedStyle),
        ),
      ],
    );
  }
}

class _HorizontalProgressClipper extends CustomClipper<Rect> {
  final double progress;

  const _HorizontalProgressClipper(this.progress);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(_HorizontalProgressClipper oldClipper) =>
      oldClipper.progress != progress;
}
