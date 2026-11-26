import 'package:flutter/foundation.dart';
import 'lyric_syllable.dart';

/// Represents a single synchronized lyric line with optional syllable timings
/// and multilingual secondary tracks (translations and romanization).
@immutable
class LyricLine {
  /// The full display text for this line.
  final String text;

  /// Absolute start timestamp of the line from track start.
  final Duration start;

  /// Absolute end timestamp of the line from track start.
  final Duration end;

  /// Optional syllable or word-level timings for karaoke wipes.
  final List<LyricSyllable> syllables;

  /// Optional secondary translated text line (e.g., English translation).
  final String? translation;

  /// Optional phonetic or romanized text line (e.g., Romaji, Pinyin).
  final String? romanization;

  const LyricLine({
    required this.text,
    required this.start,
    required this.end,
    this.syllables = const <LyricSyllable>[],
    this.translation,
    this.romanization,
  });

  /// Total duration of this line.
  Duration get duration => end - start;

  /// True if fine-grained syllable/word-by-word timing is present.
  bool get hasSyllables => syllables.isNotEmpty;

  /// True if this line contains a secondary translated subtitle.
  bool get hasTranslation =>
      translation != null && translation!.trim().isNotEmpty;

  /// True if this line contains a phonetic / romanized track.
  bool get hasRomanization =>
      romanization != null && romanization!.trim().isNotEmpty;

  /// Overall line progress from `0.0` to `1.0`.
  double getProgress(Duration currentPosition) {
    if (currentPosition < start) return 0.0;
    if (currentPosition >= end) return 1.0;
    final totalMicro = duration.inMicroseconds;
    if (totalMicro <= 0) return 1.0;
    final elapsedMicro = (currentPosition - start).inMicroseconds;
    return (elapsedMicro / totalMicro).clamp(0.0, 1.0);
  }

  /// Finds the currently active syllable index, or `-1` if none active.
  int findSyllableIndexAt(Duration currentPosition) {
    if (syllables.isEmpty ||
        currentPosition < start ||
        currentPosition >= end) {
      return -1;
    }
    for (int i = 0; i < syllables.length; i++) {
      if (syllables[i].isCurrent(currentPosition)) {
        return i;
      }
    }
    // If between syllables but within line, find the last completed syllable
    for (int i = syllables.length - 1; i >= 0; i--) {
      if (currentPosition >= syllables[i].end) {
        return i;
      }
    }
    return 0;
  }

  /// Returns the currently active syllable or word, if any.
  LyricSyllable? getActiveSyllable(Duration currentPosition) {
    final idx = findSyllableIndexAt(currentPosition);
    return idx >= 0 && idx < syllables.length ? syllables[idx] : null;
  }

  /// Whether playback is currently on this line.
  bool isCurrent(Duration currentPosition) =>
      currentPosition >= start && currentPosition < end;

  /// Whether playback has finished this line.
  bool isCompleted(Duration currentPosition) => currentPosition >= end;

  /// Whether playback has not yet reached this line.
  bool isUpcoming(Duration currentPosition) => currentPosition < start;

  LyricLine copyWith({
    String? text,
    Duration? start,
    Duration? end,
    List<LyricSyllable>? syllables,
    String? translation,
    String? romanization,
  }) {
    return LyricLine(
      text: text ?? this.text,
      start: start ?? this.start,
      end: end ?? this.end,
      syllables: syllables ?? this.syllables,
      translation: translation ?? this.translation,
      romanization: romanization ?? this.romanization,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'start': start.inMilliseconds,
        'end': end.inMilliseconds,
        if (syllables.isNotEmpty)
          'syllables': syllables.map((s) => s.toJson()).toList(),
        if (translation != null) 'translation': translation,
        if (romanization != null) 'romanization': romanization,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    final rawSyllables = json['syllables'] as List<dynamic>?;
    return LyricLine(
      text: json['text'] as String? ?? '',
      start: Duration(milliseconds: json['start'] as int? ?? 0),
      end: Duration(
        milliseconds:
            json['end'] as int? ?? (json['start'] as int? ?? 0) + 3000,
      ),
      syllables: rawSyllables != null
          ? rawSyllables
              .map((e) => LyricSyllable.fromJson(e as Map<String, dynamic>))
              .toList()
          : const <LyricSyllable>[],
      translation: json['translation'] as String?,
      romanization: json['romanization'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricLine &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          start == other.start &&
          end == other.end &&
          listEquals(syllables, other.syllables) &&
          translation == other.translation &&
          romanization == other.romanization;

  @override
  int get hashCode => Object.hash(
        text,
        start,
        end,
        Object.hashAll(syllables),
        translation,
        romanization,
      );

  @override
  String toString() =>
      'LyricLine("$text", start: ${start.inMilliseconds}ms, end: ${end.inMilliseconds}ms, syllables: ${syllables.length})';
}
