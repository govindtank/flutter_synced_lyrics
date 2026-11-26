import 'package:flutter/foundation.dart';

/// Represents a single word or syllable within a synchronized lyric line.
@immutable
class LyricSyllable {
  /// The textual content of the syllable or word (including trailing spaces).
  final String text;

  /// Absolute start timestamp of this syllable from the beginning of the track.
  final Duration start;

  /// Absolute end timestamp of this syllable from the beginning of the track.
  final Duration end;

  const LyricSyllable({
    required this.text,
    required this.start,
    required this.end,
  });

  /// Total duration of this syllable.
  Duration get duration => end - start;

  /// Returns highlight progress between `0.0` (unstarted) and `1.0` (completed).
  double getProgress(Duration currentPosition) {
    if (currentPosition < start) return 0.0;
    if (currentPosition >= end) return 1.0;
    final totalMicro = duration.inMicroseconds;
    if (totalMicro <= 0) return 1.0;
    final elapsedMicro = (currentPosition - start).inMicroseconds;
    return (elapsedMicro / totalMicro).clamp(0.0, 1.0);
  }

  /// Whether playback has passed the end of this syllable.
  bool isCompleted(Duration currentPosition) => currentPosition >= end;

  /// Whether playback is currently within this syllable's start and end window.
  bool isCurrent(Duration currentPosition) =>
      currentPosition >= start && currentPosition < end;

  /// Whether playback has not yet reached this syllable.
  bool isUpcoming(Duration currentPosition) => currentPosition < start;

  LyricSyllable copyWith({
    String? text,
    Duration? start,
    Duration? end,
  }) {
    return LyricSyllable(
      text: text ?? this.text,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'start': start.inMilliseconds,
        'end': end.inMilliseconds,
      };

  factory LyricSyllable.fromJson(Map<String, dynamic> json) {
    return LyricSyllable(
      text: json['text'] as String? ?? '',
      start: Duration(milliseconds: json['start'] as int? ?? 0),
      end: Duration(
        milliseconds: json['end'] as int? ?? (json['start'] as int? ?? 0) + 300,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricSyllable &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(text, start, end);

  @override
  String toString() =>
      'LyricSyllable("$text", start: ${start.inMilliseconds}ms, end: ${end.inMilliseconds}ms)';
}
