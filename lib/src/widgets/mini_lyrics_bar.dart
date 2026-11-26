import 'package:flutter/material.dart';
import '../controllers/lyrics_controller.dart';
import '../theme/lyrics_theme.dart';
import 'syllable_line_view.dart';

/// Compact single or dual-line lyrics ticker designed for bottom mini-players and car displays.
class MiniLyricsBar extends StatelessWidget {
  final LyricsController controller;
  final LyricsTheme? theme;
  final bool showTranslation;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MiniLyricsBar({
    super.key,
    required this.controller,
    this.theme,
    this.showTranslation = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final activeTheme = theme ??
        LyricsTheme(
          activeLineStyle: const LyricLineStyle(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            translationStyle: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
            padding: EdgeInsets.zero,
          ),
          inactiveLineStyle: const LyricLineStyle(
            textStyle: TextStyle(
              color: Color(0x80FFFFFF),
              fontSize: 15,
            ),
            textAlign: TextAlign.left,
            padding: EdgeInsets.zero,
          ),
        );

    return ValueListenableBuilder<LyricsState>(
      valueListenable: controller,
      builder: (context, state, child) {
        final line = controller.currentLine;

        Widget content;
        if (line == null) {
          content = Text(
            controller.document.title != null
                ? '♪ ${controller.document.title}'
                : '♪ Music',
            style: activeTheme.inactiveLineStyle.textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        } else {
          content = AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.4),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: SyllableLineView(
              key: ValueKey(state.lineIndex),
              line: line,
              isActive: true,
              currentPosition: state.position,
              lineStyle: activeTheme.activeLineStyle,
              karaokeStyle: activeTheme.karaokeStyle,
              showTranslation: showTranslation,
              showRomanization: false,
            ),
          );
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lyrics_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: content),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
