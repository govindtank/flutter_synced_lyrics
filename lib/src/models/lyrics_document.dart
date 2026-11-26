import 'package:flutter/foundation.dart';
import 'lyric_line.dart';

/// A complete synchronized lyrics document representing a song's lyrics,
/// metadata, and timing tracks.
@immutable
class LyricsDocument {
  /// All timed lines, strictly sorted by [LyricLine.start].
  final List<LyricLine> lines;

  /// Track title parsed from document metadata.
  final String? title;

  /// Artist name parsed from document metadata.
  final String? artist;

  /// Album name parsed from document metadata.
  final String? album;

  /// Lyric author / creator / transcriber name.
  final String? author;

  /// Total track duration if declared in document.
  final Duration? totalDuration;

  /// Global timing offset to adjust synchronization drift.
  final Duration offset;

  const LyricsDocument({
    required this.lines,
    this.title,
    this.artist,
    this.album,
    this.author,
    this.totalDuration,
    this.offset = Duration.zero,
  });

  /// An empty document instance.
  static const empty = LyricsDocument(lines: <LyricLine>[]);

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;
  int get lineCount => lines.length;

  /// Finds the line index corresponding to [position] taking [offset] into account.
  ///
  /// Returns:
  /// - `-1` if [position] is before the first line.
  /// - The index of the line currently active.
  /// - If [position] falls in a silent gap between lines:
  ///     - Stays on previous line until 70% into the gap, then shifts to next line.
  int findLineIndexAt(Duration position) {
    if (lines.isEmpty) return -1;
    final adjusted = position + offset;
    if (adjusted < lines.first.start) return -1;

    int low = 0;
    int high = lines.length - 1;

    while (low <= high) {
      final mid = (low + high) >> 1;
      final line = lines[mid];

      if (adjusted >= line.start && adjusted < line.end) {
        return mid;
      } else if (adjusted < line.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // Between lines (low is the index of the upcoming line, high = low - 1)
    if (high >= 0 && low < lines.length) {
      final prevLine = lines[high];
      final nextLine = lines[low];
      final gap = nextLine.start - prevLine.end;
      if (gap > Duration.zero) {
        final elapsedInGap = adjusted - prevLine.end;
        // Lead-in: switch focus to next line when within 1.2s or 60% of gap
        if (adjusted >= nextLine.start - const Duration(milliseconds: 1200) ||
            elapsedInGap > gap * 0.6) {
          return low;
        }
      }
      return high;
    }

    return (low >= lines.length) ? lines.length - 1 : 0;
  }

  /// Whether the given [position] is in an instrumental break longer than [minGap].
  bool isInstrumentalBreakAt(
    Duration position, {
    Duration minGap = const Duration(seconds: 4),
  }) {
    if (lines.length < 2) return false;
    final adjusted = position + offset;

    // Check before first line
    if (adjusted < lines.first.start &&
        (lines.first.start - adjusted) >= minGap) {
      return true;
    }

    for (int i = 0; i < lines.length - 1; i++) {
      final currentEnd = lines[i].end;
      final nextStart = lines[i + 1].start;
      if (adjusted >= currentEnd && adjusted < nextStart) {
        return (nextStart - currentEnd) >= minGap;
      }
    }
    return false;
  }

  /// Returns the remaining countdown duration until the next lyric line begins,
  /// or null if not currently in an instrumental break.
  Duration? getRemainingBreakTime(
    Duration position, {
    Duration minGap = const Duration(seconds: 4),
  }) {
    if (lines.isEmpty) return null;
    final adjusted = position + offset;

    if (adjusted < lines.first.start) {
      final gap = lines.first.start - adjusted;
      return gap >= minGap ? gap : null;
    }

    for (int i = 0; i < lines.length - 1; i++) {
      final currentEnd = lines[i].end;
      final nextStart = lines[i + 1].start;
      if (adjusted >= currentEnd && adjusted < nextStart) {
        final gap = nextStart - currentEnd;
        if (gap >= minGap) {
          return nextStart - adjusted;
        }
      }
    }
    return null;
  }

  LyricsDocument copyWith({
    List<LyricLine>? lines,
    String? title,
    String? artist,
    String? album,
    String? author,
    Duration? totalDuration,
    Duration? offset,
  }) {
    return LyricsDocument(
      lines: lines ?? this.lines,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      author: author ?? this.author,
      totalDuration: totalDuration ?? this.totalDuration,
      offset: offset ?? this.offset,
    );
  }

  Map<String, dynamic> toJson() => {
        'lines': lines.map((l) => l.toJson()).toList(),
        if (title != null) 'title': title,
        if (artist != null) 'artist': artist,
        if (album != null) 'album': album,
        if (author != null) 'author': author,
        if (totalDuration != null)
          'totalDuration': totalDuration!.inMilliseconds,
        'offset': offset.inMilliseconds,
      };

  factory LyricsDocument.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? const [];
    return LyricsDocument(
      lines: rawLines
          .map((e) => LyricLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String?,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      author: json['author'] as String?,
      totalDuration: json['totalDuration'] != null
          ? Duration(milliseconds: json['totalDuration'] as int)
          : null,
      offset: Duration(milliseconds: json['offset'] as int? ?? 0),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricsDocument &&
          runtimeType == other.runtimeType &&
          listEquals(lines, other.lines) &&
          title == other.title &&
          artist == other.artist &&
          album == other.album &&
          author == other.author &&
          totalDuration == other.totalDuration &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(lines),
        title,
        artist,
        album,
        author,
        totalDuration,
        offset,
      );

  @override
  String toString() =>
      'LyricsDocument(title: "$title", artist: "$artist", lines: ${lines.length}, offset: ${offset.inMilliseconds}ms)';
}
