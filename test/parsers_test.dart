import 'package:flutter_synced_lyrics/flutter_synced_lyrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LrcParser Tests', () {
    test('parses standard LRC with metadata and timestamps', () {
      const sample = '''
[ti:Bohemian Rhapsody]
[ar:Queen]
[al:A Night at the Opera]
[by:Govind Tank]
[offset:+250]
[00:02.50]Is this the real life?
[00:06.80]Is this just fantasy?
[00:11.20]Caught in a landslide
''';

      final doc = LrcParser.parse(sample);
      expect(doc.title, equals('Bohemian Rhapsody'));
      expect(doc.artist, equals('Queen'));
      expect(doc.album, equals('A Night at the Opera'));
      expect(doc.author, equals('Govind Tank'));
      expect(doc.offset, equals(const Duration(milliseconds: 250)));
      expect(doc.lines.length, equals(3));

      expect(doc.lines[0].text, equals('Is this the real life?'));
      expect(doc.lines[0].start, equals(const Duration(milliseconds: 2500)));
      expect(doc.lines[0].end, equals(const Duration(milliseconds: 6800)));

      expect(doc.lines[1].text, equals('Is this just fantasy?'));
      expect(doc.lines[1].start, equals(const Duration(milliseconds: 6800)));

      expect(doc.lines[2].text, equals('Caught in a landslide'));
      expect(doc.lines[2].start, equals(const Duration(milliseconds: 11200)));
    });

    test('parses enhanced syllable-by-syllable LRC', () {
      const sample = '''
[00:10.00]<00:10.00>Never <00:10.50>gonna <00:11.20>give <00:11.80>you <00:12.40>up<00:13.00>
[00:14.00]<00:14.00>Never <00:14.50>gonna <00:15.10>let <00:15.70>you <00:16.30>down<00:17.00>
''';

      final doc = LrcParser.parse(sample);
      expect(doc.lines.length, equals(2));

      final firstLine = doc.lines.first;
      expect(firstLine.text, equals('Never gonna give you up'));
      expect(firstLine.hasSyllables, isTrue);
      expect(firstLine.syllables.length, equals(5));

      expect(firstLine.syllables[0].text, equals('Never '));
      expect(
        firstLine.syllables[0].start,
        equals(const Duration(milliseconds: 10000)),
      );
      expect(
        firstLine.syllables[0].end,
        equals(const Duration(milliseconds: 10500)),
      );

      // Verify progress computation
      expect(
        firstLine.syllables[0].getProgress(const Duration(milliseconds: 10250)),
        closeTo(0.5, 0.01),
      );
    });

    test('parses duplicate timestamps as translations', () {
      const sample = '''
[00:05.00]君の名は
[00:05.00]Your Name
[00:10.00]前前前世
[00:10.00]Past Past Past Life
''';

      final doc = LrcParser.parse(sample);
      expect(doc.lines.length, equals(2));
      expect(doc.lines[0].text, equals('君の名は'));
      expect(doc.lines[0].translation, equals('Your Name'));
      expect(doc.lines[1].text, equals('前前前世'));
      expect(doc.lines[1].translation, equals('Past Past Past Life'));
    });
  });

  group('TtmlParser Tests', () {
    test('parses full Apple Music / W3C TTML XML with spans', () {
      const ttml = '''
<?xml version="1.0" encoding="utf-8"?>
<tt xmlns="http://www.w3.org/ns/ttml" xmlns:ttm="http://www.w3.org/ns/ttml#metadata">
  <head>
    <metadata>
      <ttm:title>Blinding Lights</ttm:title>
      <ttm:artist>The Weeknd</ttm:artist>
    </metadata>
  </head>
  <body>
    <div>
      <p begin="00:00:03.200" end="00:00:06.500">
        <span begin="00:00:03.200" end="00:00:04.000">I&#39;ve </span>
        <span begin="00:00:04.000" end="00:00:04.800">been </span>
        <span begin="00:00:04.800" end="00:00:05.600">tryin&#39; </span>
        <span begin="00:00:05.600" end="00:00:06.500">to call</span>
      </p>
      <p begin="00:00:07.000" end="00:00:10.000">
        <span begin="00:07.000" end="00:07.800">I&#39;ve </span>
        <span begin="00:07.800" end="00:08.600">been </span>
        <span begin="00:08.600" end="00:09.300">on </span>
        <span begin="00:09.300" end="00:10.000">my own</span>
      </p>
    </div>
  </body>
</tt>
''';

      final doc = TtmlParser.parse(ttml);
      expect(doc.title, equals('Blinding Lights'));
      expect(doc.artist, equals('The Weeknd'));
      expect(doc.lines.length, equals(2));

      final firstLine = doc.lines.first;
      expect(firstLine.text, equals("I've been tryin' to call"));
      expect(firstLine.hasSyllables, isTrue);
      expect(firstLine.syllables.length, equals(4));
      expect(
        firstLine.start,
        equals(const Duration(milliseconds: 3200)),
      );
      expect(
        firstLine.end,
        equals(const Duration(milliseconds: 6500)),
      );
      expect(firstLine.syllables.first.text, equals("I've "));
    });

    test('parses TTML duration offsets (e.g. 4.5s or 4500ms)', () {
      expect(
        TtmlParser.parseTimestamp('4.5s'),
        equals(const Duration(milliseconds: 4500)),
      );
      expect(
        TtmlParser.parseTimestamp('1200ms'),
        equals(const Duration(milliseconds: 1200)),
      );
      expect(
        TtmlParser.parseTimestamp('01:15.500'),
        equals(const Duration(minutes: 1, seconds: 15, milliseconds: 500)),
      );
      expect(
        TtmlParser.parseTimestamp('01:02:03.400'),
        equals(const Duration(
          hours: 1,
          minutes: 2,
          seconds: 3,
          milliseconds: 400,
        )),
      );
    });
  });

  group('JsonLyricsParser Tests', () {
    test('parses structured JSON lyrics', () {
      const jsonStr = '''
{
  "title": "Starboy",
  "artist": "The Weeknd",
  "lines": [
    {
      "text": "I'm tryna put you in the worst mood",
      "start": 1000,
      "end": 3500,
      "syllables": [
        {"text": "I'm ", "start": 1000, "end": 1400},
        {"text": "tryna ", "start": 1400, "end": 1800},
        {"text": "put you ", "start": 1800, "end": 2600},
        {"text": "in the worst mood", "start": 2600, "end": 3500}
      ]
    }
  ]
}
''';

      final doc = JsonLyricsParser.parse(jsonStr);
      expect(doc.title, equals('Starboy'));
      expect(doc.artist, equals('The Weeknd'));
      expect(doc.lines.length, equals(1));
      expect(doc.lines[0].hasSyllables, isTrue);
      expect(doc.lines[0].syllables.length, equals(4));
    });
  });

  group('Auto-Detect LyricsParser Tests', () {
    test('auto-detects TTML', () {
      const ttml =
          '<tt><body><div><p begin="00:01.00">Hello</p></div></body></tt>';
      final doc = LyricsParser.parse(ttml);
      expect(doc.lines.length, equals(1));
      expect(doc.lines[0].text, equals('Hello'));
    });

    test('auto-detects LRC', () {
      const lrc = '[00:05.00]Hello World';
      final doc = LyricsParser.parse(lrc);
      expect(doc.lines.length, equals(1));
      expect(doc.lines[0].text, equals('Hello World'));
    });

    test('falls back to plain text', () {
      const plain = 'Line 1\nLine 2\nLine 3';
      final doc = LyricsParser.parse(plain);
      expect(doc.lines.length, equals(3));
      expect(doc.lines[0].text, equals('Line 1'));
      expect(doc.lines[1].text, equals('Line 2'));
      expect(doc.lines[2].text, equals('Line 3'));
    });
  });

  group('LyricsDocument Instrumental Break & Index Tests', () {
    test('accurately locates active line and instrumental breaks', () {
      final doc = LyricsDocument(
        lines: [
          const LyricLine(
            text: 'Verse 1',
            start: Duration(seconds: 10),
            end: Duration(seconds: 14),
          ),
          const LyricLine(
            text: 'Verse 2 after guitar solo',
            start: Duration(seconds: 24),
            end: Duration(seconds: 28),
          ),
        ],
      );

      // Before first line
      expect(doc.findLineIndexAt(const Duration(seconds: 5)), equals(-1));

      // During verse 1
      expect(doc.findLineIndexAt(const Duration(seconds: 12)), equals(0));

      // In break (10 second gap between 14s and 24s)
      expect(
        doc.isInstrumentalBreakAt(
          const Duration(seconds: 16),
          minGap: const Duration(seconds: 4),
        ),
        isTrue,
      );

      // Remaining break time at 18s is 24s - 18s = 6s
      expect(
        doc.getRemainingBreakTime(
          const Duration(seconds: 18),
          minGap: const Duration(seconds: 4),
        ),
        equals(const Duration(seconds: 6)),
      );
    });
  });
}
