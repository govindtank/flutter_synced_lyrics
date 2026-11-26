import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Configuration options for lyrics synchronization, scrolling dynamics, and user interaction.
@immutable
class LyricsConfig {
  /// Whether the viewport automatically scrolls to keep the active line in view.
  final bool autoScroll;

  /// Viewport alignment anchor for the active line (`0.0` top, `0.5` center, `1.0` bottom).
  /// Defaults to `0.42` for the optimal Apple Music / Spotify eye-level reading position.
  final double activeLineAnchor;

  /// Duration of the smooth scroll animation when transitioning to the next line.
  final Duration scrollDuration;

  /// Animation curve used for line scrolling transitions.
  final Curve scrollCurve;

  /// Time of user inactivity before manually scrolled lyrics snap back to the currently playing line.
  /// Set to `null` to require the user to explicitly tap the floating "Snap back" button.
  final Duration? idleTimeoutBeforeResume;

  /// Global latency calibration offset added to audio timestamps (e.g., for Bluetooth headphone latency).
  final Duration latencyOffset;

  /// Minimum gap between verses to trigger an instrumental break indicator / visualizer countdown.
  final Duration instrumentalBreakThreshold;

  /// Whether to trigger subtle haptic clicks when switching lines.
  final bool enableHaptics;

  const LyricsConfig({
    this.autoScroll = true,
    this.activeLineAnchor = 0.42,
    this.scrollDuration = const Duration(milliseconds: 550),
    this.scrollCurve = Curves.easeOutCubic,
    this.idleTimeoutBeforeResume = const Duration(milliseconds: 3500),
    this.latencyOffset = Duration.zero,
    this.instrumentalBreakThreshold = const Duration(seconds: 4),
    this.enableHaptics = false,
  });

  LyricsConfig copyWith({
    bool? autoScroll,
    double? activeLineAnchor,
    Duration? scrollDuration,
    Curve? scrollCurve,
    Duration? idleTimeoutBeforeResume,
    Duration? latencyOffset,
    Duration? instrumentalBreakThreshold,
    bool? enableHaptics,
  }) {
    return LyricsConfig(
      autoScroll: autoScroll ?? this.autoScroll,
      activeLineAnchor: activeLineAnchor ?? this.activeLineAnchor,
      scrollDuration: scrollDuration ?? this.scrollDuration,
      scrollCurve: scrollCurve ?? this.scrollCurve,
      idleTimeoutBeforeResume:
          idleTimeoutBeforeResume ?? this.idleTimeoutBeforeResume,
      latencyOffset: latencyOffset ?? this.latencyOffset,
      instrumentalBreakThreshold:
          instrumentalBreakThreshold ?? this.instrumentalBreakThreshold,
      enableHaptics: enableHaptics ?? this.enableHaptics,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsConfig &&
          runtimeType == other.runtimeType &&
          autoScroll == other.autoScroll &&
          activeLineAnchor == other.activeLineAnchor &&
          scrollDuration == other.scrollDuration &&
          scrollCurve == other.scrollCurve &&
          idleTimeoutBeforeResume == other.idleTimeoutBeforeResume &&
          latencyOffset == other.latencyOffset &&
          instrumentalBreakThreshold == other.instrumentalBreakThreshold &&
          enableHaptics == other.enableHaptics;

  @override
  int get hashCode => Object.hash(
        autoScroll,
        activeLineAnchor,
        scrollDuration,
        scrollCurve,
        idleTimeoutBeforeResume,
        latencyOffset,
        instrumentalBreakThreshold,
        enableHaptics,
      );
}
