import '../models/lyrics_document.dart';
import '../models/lyric_line.dart';
import '../models/lyric_syllable.dart';

/// High-performance parser for Standard and Enhanced Syllable LRC formats.
class LrcParser {
  const LrcParser();

  static final RegExp _metaRegex = RegExp(r'^\[([a-zA-Z]+):(.*)\]$');
  static final RegExp _timestampRegex = RegExp(
    r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
  );
  static final RegExp _syllableRegex = RegExp(
    r'<(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?>([^<]*)',
  );

  /// Parses a raw LRC string into a [LyricsDocument].
  static LyricsDocument parse(String source) {
    final lines = source.split(RegExp(r'\r?\n'));
    String? title;
    String? artist;
    String? album;
    String? author;
    Duration offset = Duration.zero;
    Duration? totalDuration;

    final parsedEntries = <_RawLineEntry>[];

    for (final rawLine in lines) {
      final trimmed = rawLine.trim();
      if (trimmed.isEmpty) continue;

      // 1. Check for Metadata Tags like [ti:Title]
      final metaMatch = _metaRegex.firstMatch(trimmed);
      if (metaMatch != null) {
        final key = metaMatch.group(1)!.toLowerCase();
        final value = metaMatch.group(2)!.trim();
        switch (key) {
          case 'ti':
            title = value;
            break;
          case 'ar':
            artist = value;
            break;
          case 'al':
            album = value;
            break;
          case 'by':
            author = value;
            break;
          case 'offset':
            final parsedOffset = int.tryParse(value);
            if (parsedOffset != null) {
              offset = Duration(milliseconds: parsedOffset);
            }
            break;
          case 'length':
            totalDuration = _parseClockTime(value);
            break;
        }
        continue;
      }

      // 2. Extract one or multiple timestamps from line head, e.g. [00:12.34][01:45.67]Chorus
      final timestampMatches = _timestampRegex.allMatches(trimmed).toList();
      if (timestampMatches.isEmpty) continue;

      // Text begins after the last timestamp match
      final lastMatch = timestampMatches.last;
      final lineContent = trimmed.substring(lastMatch.end).trim();

      // Check for enhanced syllables in content: <00:12.34>Hello <00:13.00>world
      final syllableList = _parseSyllables(lineContent);
      final plainText = syllableList.isNotEmpty
          ? syllableList.map((s) => s.text).join('')
          : lineContent;

      for (final tm in timestampMatches) {
        final start = _parseTimestampMatch(tm);
        parsedEntries.add(
          _RawLineEntry(
            start: start,
            text: plainText,
            syllables: syllableList,
          ),
        );
      }
    }

    if (parsedEntries.isEmpty) {
      return LyricsDocument(
        lines: const <LyricLine>[],
        title: title,
        artist: artist,
        album: album,
        author: author,
        totalDuration: totalDuration,
        offset: offset,
      );
    }

    // Sort entries strictly by start timestamp
    parsedEntries.sort((a, b) => a.start.compareTo(b.start));

    // Combine duplicate timestamps into main line + translation if applicable
    final finalizedLines = <LyricLine>[];
    for (int i = 0; i < parsedEntries.length; i++) {
      final current = parsedEntries[i];

      // Check if subsequent entry shares the exact same timestamp (often translation)
      if (i + 1 < parsedEntries.length &&
          parsedEntries[i + 1].start == current.start &&
          parsedEntries[i + 1].text != current.text) {
        final translationText = parsedEntries[i + 1].text;
        // Determine end timestamp
        final nextStart = (i + 2 < parsedEntries.length)
            ? parsedEntries[i + 2].start
            : current.start + const Duration(seconds: 4);
        final lineEnd = _computeLineEnd(current, nextStart);

        finalizedLines.add(
          LyricLine(
            text: current.text,
            start: current.start,
            end: lineEnd,
            syllables: current.syllables,
            translation: translationText,
          ),
        );
        i++; // Skip the translation line
        continue;
      }

      final nextStart = (i + 1 < parsedEntries.length)
          ? parsedEntries[i + 1].start
          : current.start + const Duration(seconds: 4);
      final lineEnd = _computeLineEnd(current, nextStart);

      finalizedLines.add(
        LyricLine(
          text: current.text,
          start: current.start,
          end: lineEnd,
          syllables: current.syllables,
        ),
      );
    }

    return LyricsDocument(
      lines: finalizedLines,
      title: title,
      artist: artist,
      album: album,
      author: author,
      totalDuration: totalDuration,
      offset: offset,
    );
  }

  static Duration _computeLineEnd(_RawLineEntry entry, Duration nextLineStart) {
    // If enhanced syllables exist, the end is at least the last syllable's end
    if (entry.syllables.isNotEmpty) {
      final lastEnd = entry.syllables.last.end;
      if (lastEnd > entry.start) return lastEnd;
    }

    // Standard LRC: end at next line start or capped at 7 seconds
    final durationUntilNext = nextLineStart - entry.start;
    if (durationUntilNext > Duration.zero &&
        durationUntilNext <= const Duration(seconds: 7)) {
      return nextLineStart;
    } else if (durationUntilNext > const Duration(seconds: 7)) {
      // Natural gap between verses or instrumental break
      return entry.start + const Duration(milliseconds: 3800);
    } else {
      return entry.start + const Duration(milliseconds: 3000);
    }
  }

  static List<LyricSyllable> _parseSyllables(String content) {
    final matches = _syllableRegex.allMatches(content).toList();
    if (matches.isEmpty) return const <LyricSyllable>[];

    final syllables = <LyricSyllable>[];
    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      final start = _parseSyllableMatch(m);
      final text = m.group(4) ?? '';

      Duration end;
      if (i + 1 < matches.length) {
        end = _parseSyllableMatch(matches[i + 1]);
      } else {
        end = start + const Duration(milliseconds: 400);
      }

      if (end < start) end = start + const Duration(milliseconds: 200);

      if (text.isNotEmpty) {
        syllables.add(
          LyricSyllable(
            text: text,
            start: start,
            end: end,
          ),
        );
      }
    }
    return syllables;
  }

  static Duration _parseTimestampMatch(RegExpMatch match) {
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final rawFrac = match.group(3);

    int milliseconds = 0;
    if (rawFrac != null) {
      if (rawFrac.length == 1) {
        milliseconds = int.parse(rawFrac) * 100;
      } else if (rawFrac.length == 2) {
        milliseconds = int.parse(rawFrac) * 10;
      } else {
        milliseconds = int.parse(rawFrac.substring(0, 3));
      }
    }

    return Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static Duration _parseSyllableMatch(RegExpMatch match) {
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final rawFrac = match.group(3);

    int milliseconds = 0;
    if (rawFrac != null) {
      if (rawFrac.length == 1) {
        milliseconds = int.parse(rawFrac) * 100;
      } else if (rawFrac.length == 2) {
        milliseconds = int.parse(rawFrac) * 10;
      } else {
        milliseconds = int.parse(rawFrac.substring(0, 3));
      }
    }

    return Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  static Duration? _parseClockTime(String raw) {
    final parts = raw.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]);
      final s = double.tryParse(parts[1]);
      if (m != null && s != null) {
        return Duration(
          minutes: m,
          milliseconds: (s * 1000).round(),
        );
      }
    }
    return null;
  }
}

class _RawLineEntry {
  final Duration start;
  final String text;
  final List<LyricSyllable> syllables;

  _RawLineEntry({
    required this.start,
    required this.text,
    required this.syllables,
  });
}
