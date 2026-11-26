import 'dart:convert';
import '../models/lyrics_document.dart';
import '../models/lyric_line.dart';
import '../models/lyric_syllable.dart';

/// Parses JSON lyric structures from streaming APIs or disk fixtures.
class JsonLyricsParser {
  const JsonLyricsParser();

  /// Parses JSON string or decoded map into a [LyricsDocument].
  static LyricsDocument parse(String jsonSource) {
    try {
      final decoded = jsonDecode(jsonSource);
      if (decoded is Map<String, dynamic>) {
        return _parseMap(decoded);
      } else if (decoded is List) {
        return _parseList(decoded);
      }
    } catch (_) {
      // Fallback on empty document on parse failure
    }
    return LyricsDocument.empty;
  }

  static LyricsDocument _parseMap(Map<String, dynamic> map) {
    final title = map['title'] as String? ?? map['trackName'] as String?;
    final artist = map['artist'] as String? ?? map['artistName'] as String?;
    final album = map['album'] as String?;
    final author = map['author'] as String? ?? map['by'] as String?;
    final offsetMs = map['offset'] as int? ?? 0;

    final rawLines = (map['lines'] ??
        map['lyrics'] ??
        map['syncLyrics'] ??
        map['subtitles']) as List<dynamic>?;

    final lines =
        rawLines != null ? _parseListElements(rawLines) : <LyricLine>[];

    return LyricsDocument(
      lines: lines,
      title: title,
      artist: artist,
      album: album,
      author: author,
      offset: Duration(milliseconds: offsetMs),
    );
  }

  static LyricsDocument _parseList(List<dynamic> list) {
    final lines = _parseListElements(list);
    return LyricsDocument(lines: lines);
  }

  static List<LyricLine> _parseListElements(List<dynamic> list) {
    final lines = <LyricLine>[];

    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is! Map<String, dynamic>) continue;

      final text = item['text'] as String? ??
          item['words'] as String? ??
          item['content'] as String? ??
          '';

      final startMs = _extractMs(
        item['start'] ?? item['startTimeMs'] ?? item['time'] ?? item['begin'],
      );

      int endMs = _extractMs(
        item['end'] ?? item['endTimeMs'] ?? item['end_time'],
      );

      // Estimate end if absent
      if (endMs <= startMs) {
        if (i + 1 < list.length && list[i + 1] is Map<String, dynamic>) {
          final nextStart = _extractMs(
            list[i + 1]['start'] ??
                list[i + 1]['startTimeMs'] ??
                list[i + 1]['time'] ??
                list[i + 1]['begin'],
          );
          if (nextStart > startMs && (nextStart - startMs) <= 6000) {
            endMs = nextStart;
          } else {
            endMs = startMs + 3500;
          }
        } else {
          endMs = startMs + 3500;
        }
      }

      final rawSyllables =
          (item['syllables'] ?? item['words_timed']) as List<dynamic>?;
      final syllables = <LyricSyllable>[];

      if (rawSyllables != null) {
        for (final s in rawSyllables) {
          if (s is Map<String, dynamic>) {
            final sText = s['text'] as String? ?? s['word'] as String? ?? '';
            final sStart = _extractMs(s['start'] ?? s['time'] ?? s['begin']);
            final sEnd = _extractMs(s['end'] ?? s['end_time']);
            if (sText.isNotEmpty) {
              syllables.add(
                LyricSyllable(
                  text: sText,
                  start: Duration(milliseconds: sStart),
                  end: Duration(
                    milliseconds: sEnd > sStart ? sEnd : sStart + 300,
                  ),
                ),
              );
            }
          }
        }
      }

      final translation = item['translation'] as String?;
      final romanization = item['romanization'] as String?;

      if (text.trim().isNotEmpty) {
        lines.add(
          LyricLine(
            text: text,
            start: Duration(milliseconds: startMs),
            end: Duration(milliseconds: endMs),
            syllables: syllables,
            translation: translation,
            romanization: romanization,
          ),
        );
      }
    }

    lines.sort((a, b) => a.start.compareTo(b.start));
    return lines;
  }

  static int _extractMs(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final d = double.tryParse(value);
      if (d != null) return (d * 1000).round();
    }
    return 0;
  }
}
