import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/lyrics_document.dart';
import '../models/lyric_line.dart';
import '../models/lyric_syllable.dart';
import '../parsers/lyrics_parser.dart';
import 'lyrics_config.dart';

/// State snapshot of the active lyrics playback.
@immutable
class LyricsState {
  final Duration position;
  final int lineIndex;
  final int syllableIndex;
  final double lineProgress;
  final bool isUserScrolling;
  final bool isInstrumentalBreak;
  final Duration? remainingBreakTime;

  const LyricsState({
    required this.position,
    required this.lineIndex,
    required this.syllableIndex,
    required this.lineProgress,
    required this.isUserScrolling,
    required this.isInstrumentalBreak,
    this.remainingBreakTime,
  });

  static const initial = LyricsState(
    position: Duration.zero,
    lineIndex: -1,
    syllableIndex: -1,
    lineProgress: 0.0,
    isUserScrolling: false,
    isInstrumentalBreak: false,
  );
}

/// Core synchronization engine binding audio playback streams to the lyrics renderer.
class LyricsController extends ValueNotifier<LyricsState> {
  LyricsDocument _document;
  LyricsConfig _config;
  bool _isPlaying = false;
  Timer? _resumeScrollTimer;

  /// Optional callback invoked when the user taps a lyric line or syllable to seek.
  void Function(Duration seekPosition)? onSeekRequest;

  LyricsController({
    LyricsDocument? document,
    LyricsConfig? config,
    this.onSeekRequest,
  })  : _document = document ?? LyricsDocument.empty,
        _config = config ?? const LyricsConfig(),
        super(LyricsState.initial) {
    _recalculateState(value.position);
  }

  /// Creates a controller by automatically detecting and parsing a raw lyrics string (LRC, TTML, JSON).
  factory LyricsController.fromSource(
    String source, {
    LyricsConfig? config,
    void Function(Duration seekPosition)? onSeekRequest,
  }) {
    return LyricsController(
      document: LyricsParser.parse(source),
      config: config,
      onSeekRequest: onSeekRequest,
    );
  }

  /// Creates a controller from a standard or syllable LRC string.
  factory LyricsController.fromLrc(
    String lrcSource, {
    LyricsConfig? config,
    void Function(Duration seekPosition)? onSeekRequest,
  }) {
    return LyricsController(
      document: LyricsParser.fromLrc(lrcSource),
      config: config,
      onSeekRequest: onSeekRequest,
    );
  }

  /// Creates a controller from a TTML XML string.
  factory LyricsController.fromTtml(
    String ttmlSource, {
    LyricsConfig? config,
    void Function(Duration seekPosition)? onSeekRequest,
  }) {
    return LyricsController(
      document: LyricsParser.fromTtml(ttmlSource),
      config: config,
      onSeekRequest: onSeekRequest,
    );
  }

  LyricsDocument get document => _document;
  LyricsConfig get config => _config;
  bool get isPlaying => _isPlaying;

  Duration get position => value.position;
  int get currentLineIndex => value.lineIndex;
  int get currentSyllableIndex => value.syllableIndex;
  double get currentLineProgress => value.lineProgress;
  bool get isUserScrolling => value.isUserScrolling;
  bool get isInstrumentalBreak => value.isInstrumentalBreak;
  Duration? get remainingBreakTime => value.remainingBreakTime;

  LyricLine? get currentLine =>
      (value.lineIndex >= 0 && value.lineIndex < _document.lines.length)
          ? _document.lines[value.lineIndex]
          : null;

  LyricSyllable? get currentSyllable {
    final line = currentLine;
    if (line == null ||
        value.syllableIndex < 0 ||
        value.syllableIndex >= line.syllables.length) {
      return null;
    }
    return line.syllables[value.syllableIndex];
  }

  /// Updates current playback progress from audio player stream.
  void setProgress(Duration currentPos) {
    final adjusted = currentPos + _config.latencyOffset;
    _recalculateState(adjusted);
  }

  /// Alias for [setProgress].
  set progress(Duration pos) => setProgress(pos);

  /// Sets playing status.
  void setPlaying(bool playing) {
    if (_isPlaying != playing) {
      _isPlaying = playing;
      notifyListeners();
    }
  }

  /// Replaces the active lyrics document (e.g., track change).
  void setDocument(LyricsDocument document) {
    _document = document;
    _recalculateState(value.position);
  }

  /// Reconfigures synchronization parameters.
  void setConfig(LyricsConfig config) {
    _config = config;
    _recalculateState(value.position);
  }

  /// Adjusts timing calibration offset in real-time.
  void setLatencyOffset(Duration offset) {
    _config = _config.copyWith(latencyOffset: offset);
    _recalculateState(value.position);
  }

  /// Requests seeking audio playback to a specific timestamp or line start.
  void seek(Duration targetPosition) {
    onSeekRequest?.call(targetPosition);
    setProgress(targetPosition);
    resumeAutoScroll();
  }

  /// Seeks to the start of a specific line by index.
  void seekToLine(int lineIndex) {
    if (lineIndex >= 0 && lineIndex < _document.lines.length) {
      seek(_document.lines[lineIndex].start);
    }
  }

  /// Call when the user touches/drags the lyrics list manually.
  void onUserScrollStarted() {
    _resumeScrollTimer?.cancel();
    if (!value.isUserScrolling) {
      value = LyricsState(
        position: value.position,
        lineIndex: value.lineIndex,
        syllableIndex: value.syllableIndex,
        lineProgress: value.lineProgress,
        isUserScrolling: true,
        isInstrumentalBreak: value.isInstrumentalBreak,
        remainingBreakTime: value.remainingBreakTime,
      );
    }
  }

  /// Call when the user finishes touching/dragging the lyrics list.
  void onUserScrollEnded() {
    if (_config.idleTimeoutBeforeResume != null) {
      _resumeScrollTimer?.cancel();
      _resumeScrollTimer = Timer(_config.idleTimeoutBeforeResume!, () {
        resumeAutoScroll();
      });
    }
  }

  /// Resumes auto-scrolling and snaps immediately to the active line.
  void resumeAutoScroll() {
    _resumeScrollTimer?.cancel();
    if (value.isUserScrolling) {
      value = LyricsState(
        position: value.position,
        lineIndex: value.lineIndex,
        syllableIndex: value.syllableIndex,
        lineProgress: value.lineProgress,
        isUserScrolling: false,
        isInstrumentalBreak: value.isInstrumentalBreak,
        remainingBreakTime: value.remainingBreakTime,
      );
    }
  }

  void _recalculateState(Duration pos) {
    if (_document.isEmpty) {
      value = LyricsState(
        position: pos,
        lineIndex: -1,
        syllableIndex: -1,
        lineProgress: 0.0,
        isUserScrolling: value.isUserScrolling,
        isInstrumentalBreak: false,
      );
      return;
    }

    final lineIdx = _document.findLineIndexAt(pos);
    int syllableIdx = -1;
    double progress = 0.0;

    if (lineIdx >= 0 && lineIdx < _document.lines.length) {
      final line = _document.lines[lineIdx];
      progress = line.getProgress(pos);
      syllableIdx = line.findSyllableIndexAt(pos);
    }

    final isBreak = _document.isInstrumentalBreakAt(
      pos,
      minGap: _config.instrumentalBreakThreshold,
    );
    final remainingBreak = isBreak
        ? _document.getRemainingBreakTime(
            pos,
            minGap: _config.instrumentalBreakThreshold,
          )
        : null;

    final previousLineIdx = value.lineIndex;

    value = LyricsState(
      position: pos,
      lineIndex: lineIdx,
      syllableIndex: syllableIdx,
      lineProgress: progress,
      isUserScrolling: value.isUserScrolling,
      isInstrumentalBreak: isBreak,
      remainingBreakTime: remainingBreak,
    );

    // Subtle haptic click on line transition if enabled
    if (_config.enableHaptics &&
        lineIdx != previousLineIdx &&
        lineIdx >= 0 &&
        _isPlaying) {
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _resumeScrollTimer?.cancel();
    super.dispose();
  }
}
