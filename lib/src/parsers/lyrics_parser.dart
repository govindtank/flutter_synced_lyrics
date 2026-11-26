import '../models/lyrics_document.dart';
import '../models/lyric_line.dart';
import 'json_lyrics_parser.dart';
import 'lrc_parser.dart';
import 'ttml_parser.dart';

/// Unified entry point for parsing any lyrics format (LRC, Syllable LRC, TTML, JSON, or Plain Text).
class LyricsParser {
  const LyricsParser._();

  /// Automatically detects format (TTML, JSON, LRC, or plain text) and parses into a [LyricsDocument].
  static LyricsDocument parse(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) return LyricsDocument.empty;

    // 1. Detect TTML XML
    if (trimmed.startsWith('<') &&
        (trimmed.contains('<tt') ||
            trimmed.contains('<p') ||
            trimmed.contains('xmlns="http://www.w3.org/ns/ttml"'))) {
      final doc = TtmlParser.parse(trimmed);
      if (doc.isNotEmpty) return doc;
    }

    // 2. Detect JSON
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      final doc = JsonLyricsParser.parse(trimmed);
      if (doc.isNotEmpty) return doc;
    }

    // 3. Detect LRC (standard or enhanced syllable)
    if (RegExp(r'\[\d{1,2}:\d{2}').hasMatch(trimmed)) {
      final doc = LrcParser.parse(trimmed);
      if (doc.isNotEmpty) return doc;
    }

    // 4. Fallback to Plain Text with synthetic pacing (3.5s per line)
    return fromPlainText(trimmed);
  }

  /// Explicitly parses Standard or Enhanced Syllable LRC content.
  static LyricsDocument fromLrc(String lrcSource) => LrcParser.parse(lrcSource);

  /// Explicitly parses Timed Text Markup Language (TTML) XML content.
  static LyricsDocument fromTtml(String ttmlSource) =>
      TtmlParser.parse(ttmlSource);

  /// Explicitly parses JSON lyrics source.
  static LyricsDocument fromJson(String jsonSource) =>
      JsonLyricsParser.parse(jsonSource);

  /// Creates a synthetic timed [LyricsDocument] from plain untimed text.
  static LyricsDocument fromPlainText(
    String plainText, {
    Duration lineDuration = const Duration(milliseconds: 3500),
    Duration initialDelay = const Duration(milliseconds: 1000),
  }) {
    final rawLines = plainText.split(RegExp(r'\r?\n'));
    final lines = <LyricLine>[];
    var currentStart = initialDelay;

    for (final raw in rawLines) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final end = currentStart + lineDuration;
      lines.add(
        LyricLine(
          text: trimmed,
          start: currentStart,
          end: end,
        ),
      );
      currentStart = end;
    }

    return LyricsDocument(
      lines: lines,
      totalDuration: currentStart,
    );
  }
}
