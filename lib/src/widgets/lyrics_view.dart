import 'package:flutter/widgets.dart';
import '../controllers/lyrics_controller.dart';
import '../models/lyric_line.dart';
import '../theme/lyrics_presets.dart';
import '../theme/lyrics_theme.dart';
import 'instrumental_indicator.dart';
import 'syllable_line_view.dart';

/// Flagship full-featured synchronized lyrics viewport with Apple Music / Spotify styling,
/// syllable and character gradient wipes, intelligent auto-scrolling, and interactive seek controls.
class LyricsView extends StatefulWidget {
  final LyricsController controller;
  final LyricsTheme? theme;
  final LyricFlowMode? flowMode;
  final bool showTranslation;
  final bool showRomanization;
  final Widget? header;
  final Widget? footer;
  final Widget Function(BuildContext context)? emptyBuilder;
  final void Function(LyricLine line, Duration timestamp)? onLineTap;

  const LyricsView({
    super.key,
    required this.controller,
    this.theme,
    this.flowMode,
    this.showTranslation = true,
    this.showRomanization = true,
    this.header,
    this.footer,
    this.emptyBuilder,
    this.onLineTap,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _lineKeys = [];
  int _lastScrolledLine = -1;
  bool _isAnimatingToLine = false;

  @override
  void initState() {
    super.initState();
    _updateKeys();
    widget.controller.addListener(_onControllerStateChanged);
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerStateChanged);
      widget.controller.addListener(_onControllerStateChanged);
      _updateKeys();
    } else if (oldWidget.controller.document.lines.length !=
        widget.controller.document.lines.length) {
      _updateKeys();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerStateChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateKeys() {
    final count = widget.controller.document.lines.length;
    _lineKeys.clear();
    for (int i = 0; i < count; i++) {
      _lineKeys.add(GlobalKey());
    }
    _lastScrolledLine = -1;
  }

  void _onControllerStateChanged() {
    final state = widget.controller.value;
    if (!mounted) return;

    if (state.lineIndex != _lastScrolledLine &&
        state.lineIndex >= 0 &&
        !state.isUserScrolling &&
        widget.controller.config.autoScroll) {
      _lastScrolledLine = state.lineIndex;
      _scrollToLine(state.lineIndex);
    }
  }

  void _scrollToLine(int lineIndex) {
    if (_isAnimatingToLine || !_scrollController.hasClients) return;
    if (lineIndex < 0 || lineIndex >= _lineKeys.length) return;

    final key = _lineKeys[lineIndex];
    final context = key.currentContext;

    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      final viewport = _scrollController.position.context.notificationContext
          ?.findRenderObject() as RenderBox?;

      if (box != null && viewport != null) {
        final boxOffset = box.localToGlobal(Offset.zero, ancestor: viewport);
        final viewportHeight = viewport.size.height;
        final target = _scrollController.offset +
            boxOffset.dy -
            (viewportHeight * widget.controller.config.activeLineAnchor);

        final clamped = target.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _isAnimatingToLine = true;
        _scrollController
            .animateTo(
          clamped,
          duration: widget.controller.config.scrollDuration,
          curve: widget.controller.config.scrollCurve,
        )
            .whenComplete(() {
          _isAnimatingToLine = false;
        });
        return;
      }
    }

    // Fallback: estimate height if render objects not yet ready
    const estimatedHeight = 64.0;
    final estimatedTarget = (lineIndex * estimatedHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      estimatedTarget,
      duration: widget.controller.config.scrollDuration,
      curve: widget.controller.config.scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    var activeTheme = widget.theme ?? LyricsPreset.appleMusic();
    if (widget.flowMode != null) {
      activeTheme = activeTheme.copyWith(
        karaokeStyle: activeTheme.karaokeStyle.copyWith(
          flowMode: widget.flowMode,
        ),
      );
    }

    return ValueListenableBuilder<LyricsState>(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        final doc = widget.controller.document;

        if (doc.isEmpty) {
          if (widget.emptyBuilder != null) {
            return widget.emptyBuilder!(context);
          }
          return const Center(
            child: Text(
              'No lyrics available',
              style: TextStyle(color: Color(0x8AFFFFFF), fontSize: 16),
            ),
          );
        }

        return Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  if (notification.dragDetails != null) {
                    widget.controller.onUserScrollStarted();
                  }
                } else if (notification is ScrollEndNotification) {
                  widget.controller.onUserScrollEnded();
                }
                return false;
              },
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.35,
                  bottom: MediaQuery.of(context).size.height * 0.45,
                ),
                itemCount: doc.lines.length,
                itemBuilder: (context, index) {
                  final line = doc.lines[index];
                  final isActive = index == state.lineIndex;

                  // Check if this line is preceded by an instrumental break
                  final isCurrentBreak = state.isInstrumentalBreak &&
                      isActive &&
                      state.remainingBreakTime != null;

                  return Column(
                    key: index < _lineKeys.length ? _lineKeys[index] : null,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCurrentBreak)
                        InstrumentalIndicator(
                          remainingBreak: state.remainingBreakTime!,
                          style: activeTheme.instrumentalStyle,
                        ),
                      SyllableLineView(
                        line: line,
                        isActive: isActive,
                        currentPosition: state.position,
                        lineStyle: isActive
                            ? activeTheme.activeLineStyle
                            : activeTheme.inactiveLineStyle,
                        karaokeStyle: activeTheme.karaokeStyle,
                        showTranslation: widget.showTranslation,
                        showRomanization: widget.showRomanization,
                        onTap: () {
                          widget.controller.seek(line.start);
                          widget.onLineTap?.call(line, line.start);
                        },
                      ),
                      SizedBox(height: activeTheme.lineSpacing),
                    ],
                  );
                },
              ),
            ),

            // Floating "Snap Back" chip when user manually scrolled away
            if (state.isUserScrolling && state.lineIndex >= 0)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSlide(
                    offset: state.isUserScrolling
                        ? Offset.zero
                        : const Offset(0, 1),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.controller.resumeAutoScroll();
                        _scrollToLine(state.lineIndex);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1E1E24).withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                const Color(0xFFFFFFFF).withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomPaint(
                              size: const Size(12, 12),
                              painter: _DownChevronPainter(),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Return to current line',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DownChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownChevronPainter oldDelegate) => false;
}
