import '../models/lyrics_document.dart';
import '../models/lyric_line.dart';
import '../models/lyric_syllable.dart';

/// Full-featured, pure-Dart TTML (Timed Text Markup Language) parser.
///
/// Supports W3C TTML, Apple Music TTML, syllable-level `<span>` elements,
/// translation tracks, and clock/offset timestamp formats.
class TtmlParser {
  const TtmlParser();

  static final RegExp _titleRegex = RegExp(
    r'<(?:\w+:)?title[^>]*>(.*?)</(?:\w+:)?title>',
    caseSensitive: false,
    dotAll: true,
  );
  static final RegExp _artistRegex = RegExp(
    r'<(?:\w+:)?(?:agent|artist)[^>]*>(.*?)</(?:\w+:)?(?:agent|artist)>',
    caseSensitive: false,
    dotAll: true,
  );
  static final RegExp _paragraphRegex = RegExp(
    r'<(?:\w+:)?p\b([^>]*)>(.*?)</(?:\w+:)?p>',
    caseSensitive: false,
    dotAll: true,
  );
  static final RegExp _spanRegex = RegExp(
    r'<(?:\w+:)?span\b([^>]*)>(.*?)</(?:\w+:)?span>',
    caseSensitive: false,
    dotAll: true,
  );

  /// Parses TTML XML content into a [LyricsDocument].
  static LyricsDocument parse(String xmlSource) {
    String? title;
    String? artist;

    final titleMatch = _titleRegex.firstMatch(xmlSource);
    if (titleMatch != null) {
      title = _cleanXmlText(titleMatch.group(1)!);
    }

    final artistMatch = _artistRegex.firstMatch(xmlSource);
    if (artistMatch != null) {
      artist = _cleanXmlText(artistMatch.group(1)!);
    }

    final paragraphMatches = _paragraphRegex.allMatches(xmlSource).toList();
    if (paragraphMatches.isEmpty) {
      return LyricsDocument(
        lines: const <LyricLine>[],
        title: title,
        artist: artist,
      );
    }

    final parsedEntries = <_RawTtmlLine>[];

    for (final pMatch in paragraphMatches) {
      final pAttrs = _parseAttributes(pMatch.group(1) ?? '');
      final pBody = pMatch.group(2) ?? '';

      final beginStr = pAttrs['begin'] ?? pAttrs['start'];
      final endStr = pAttrs['end'];
      final durStr = pAttrs['dur'] ?? pAttrs['duration'];

      if (beginStr == null) continue;

      final start = parseTimestamp(beginStr);
      Duration end;
      if (endStr != null) {
        end = parseTimestamp(endStr);
      } else if (durStr != null) {
        end = start + parseTimestamp(durStr);
      } else {
        end = start + const Duration(milliseconds: 3500);
      }

      if (end < start) {
        end = start + const Duration(milliseconds: 3000);
      }

      final isTranslation = pAttrs['role'] == 'translation' ||
          pAttrs['ttml:role'] == 'translation' ||
          pAttrs['type'] == 'translation';

      // Parse inner <span> elements for word/syllable timings
      final spanMatches = _spanRegex.allMatches(pBody).toList();
      final syllables = <LyricSyllable>[];

      if (spanMatches.isNotEmpty) {
        for (final sMatch in spanMatches) {
          final sAttrs = _parseAttributes(sMatch.group(1) ?? '');
          final sText = _cleanXmlText(sMatch.group(2) ?? '');
          if (sText.isEmpty) continue;

          final sBeginStr = sAttrs['begin'] ?? sAttrs['start'];
          final sEndStr = sAttrs['end'];
          final sDurStr = sAttrs['dur'] ?? sAttrs['duration'];

          Duration sStart = start;
          if (sBeginStr != null) {
            sStart = parseTimestamp(sBeginStr);
          }

          Duration sEnd;
          if (sEndStr != null) {
            sEnd = parseTimestamp(sEndStr);
          } else if (sDurStr != null) {
            sEnd = sStart + parseTimestamp(sDurStr);
          } else {
            sEnd = sStart + const Duration(milliseconds: 400);
          }

          if (sEnd < sStart) {
            sEnd = sStart + const Duration(milliseconds: 200);
          }

          syllables.add(
            LyricSyllable(
              text: sText,
              start: sStart,
              end: sEnd,
            ),
          );
        }
      }

      // If no valid spans were extracted, extract plain text directly
      final plainText = syllables.isNotEmpty
          ? syllables.map((s) => s.text).join('')
          : _cleanXmlText(pBody);

      if (plainText.trim().isNotEmpty) {
        parsedEntries.add(
          _RawTtmlLine(
            start: start,
            end: end,
            text: plainText,
            syllables: syllables,
            isTranslation: isTranslation,
          ),
        );
      }
    }

    parsedEntries.sort((a, b) => a.start.compareTo(b.start));

    // Consolidate main lines and translations
    final finalized = <LyricLine>[];
    for (int i = 0; i < parsedEntries.length; i++) {
      final current = parsedEntries[i];
      if (current.isTranslation && finalized.isNotEmpty) {
        // Attach translation to previous line if within range
        final prev = finalized.removeLast();
        finalized.add(prev.copyWith(translation: current.text));
        continue;
      }

      // Check if immediate next is a translation for this exact timestamp
      if (i + 1 < parsedEntries.length &&
          (parsedEntries[i + 1].isTranslation ||
              parsedEntries[i + 1].start == current.start) &&
          parsedEntries[i + 1].text != current.text) {
        finalized.add(
          LyricLine(
            text: current.text,
            start: current.start,
            end: current.end,
            syllables: current.syllables,
            translation: parsedEntries[i + 1].text,
          ),
        );
        i++;
        continue;
      }

      finalized.add(
        LyricLine(
          text: current.text,
          start: current.start,
          end: current.end,
          syllables: current.syllables,
        ),
      );
    }

    return LyricsDocument(
      lines: finalized,
      title: title,
      artist: artist,
    );
  }

  /// Parses clock time (hh:mm:ss.fraction or mm:ss.fraction) or offset time (3.5s / 3500ms).
  static Duration parseTimestamp(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return Duration.zero;

    // Suffix: ms
    if (trimmed.endsWith('ms')) {
      final ms = double.tryParse(trimmed.substring(0, trimmed.length - 2));
      return Duration(milliseconds: (ms ?? 0).round());
    }

    // Suffix: s
    if (trimmed.endsWith('s')) {
      final s = double.tryParse(trimmed.substring(0, trimmed.length - 1));
      return Duration(milliseconds: ((s ?? 0) * 1000).round());
    }

    // Clock formats: 00:01:23.450 or 01:23.450
    final parts = trimmed.split(':');
    if (parts.length == 3) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = double.tryParse(parts[2]) ?? 0.0;
      return Duration(
        hours: h,
        minutes: m,
        milliseconds: (s * 1000).round(),
      );
    } else if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = double.tryParse(parts[1]) ?? 0.0;
      return Duration(
        minutes: m,
        milliseconds: (s * 1000).round(),
      );
    } else if (parts.length == 1) {
      final s = double.tryParse(parts[0]);
      if (s != null) {
        return Duration(milliseconds: (s * 1000).round());
      }
    }

    return Duration.zero;
  }

  static Map<String, String> _parseAttributes(String rawAttrs) {
    final map = <String, String>{};
    final attrRegex = RegExp(r'([\w:.-]+)=(?:"([^"]*)"|' r"'([^']*)')");
    for (final m in attrRegex.allMatches(rawAttrs)) {
      final key = m.group(1)!.toLowerCase();
      final val = m.group(2) ?? m.group(3) ?? '';
      map[key] = val;
    }
    return map;
  }

  static String _cleanXmlText(String text) {
    // Strip child tags if any remaining
    final stripped = text.replaceAll(RegExp(r'<[^>]+>'), '');
    return _decodeXmlEntities(stripped);
  }

  static String _decodeXmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');
  }
}

class _RawTtmlLine {
  final Duration start;
  final Duration end;
  final String text;
  final List<LyricSyllable> syllables;
  final bool isTranslation;

  _RawTtmlLine({
    required this.start,
    required this.end,
    required this.text,
    required this.syllables,
    required this.isTranslation,
  });
}
