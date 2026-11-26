import 'package:flutter/material.dart';
import 'package:flutter_synced_lyrics/flutter_synced_lyrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LyricsController Tests', () {
    test('accurately tracks active line and syllable transitions', () {
      final doc = LyricsDocument(
        lines: [
          const LyricLine(
            text: 'First line',
            start: Duration(seconds: 1),
            end: Duration(seconds: 4),
            syllables: [
              LyricSyllable(
                text: 'First ',
                start: Duration(seconds: 1),
                end: Duration(seconds: 2),
              ),
              LyricSyllable(
                text: 'line',
                start: Duration(seconds: 2),
                end: Duration(seconds: 4),
              ),
            ],
          ),
          const LyricLine(
            text: 'Second line',
            start: Duration(seconds: 5),
            end: Duration(seconds: 8),
          ),
        ],
      );

      final controller = LyricsController(document: doc);

      // Initial state
      expect(controller.currentLineIndex, equals(-1));
      expect(controller.currentLine, isNull);

      // Seek to 1.5s (within first syllable)
      controller.setProgress(const Duration(milliseconds: 1500));
      expect(controller.currentLineIndex, equals(0));
      expect(controller.currentSyllableIndex, equals(0));
      expect(controller.currentSyllable?.text, equals('First '));

      // Seek to 3s (second syllable)
      controller.setProgress(const Duration(seconds: 3));
      expect(controller.currentLineIndex, equals(0));
      expect(controller.currentSyllableIndex, equals(1));
      expect(controller.currentSyllable?.text, equals('line'));

      // Seek to 6s (second line)
      controller.setProgress(const Duration(seconds: 6));
      expect(controller.currentLineIndex, equals(1));
      expect(controller.currentLine?.text, equals('Second line'));
    });

    test('invokes onSeekRequest callback upon seeking', () {
      Duration? requestedSeek;
      final controller = LyricsController(
        document: const LyricsDocument(
          lines: [
            LyricLine(
              text: 'Line 1',
              start: Duration(seconds: 2),
              end: Duration(seconds: 5),
            ),
          ],
        ),
        onSeekRequest: (pos) => requestedSeek = pos,
      );

      controller.seek(const Duration(seconds: 2));
      expect(requestedSeek, equals(const Duration(seconds: 2)));
      expect(controller.currentLineIndex, equals(0));
    });

    test('manual scroll pause and resume', () {
      final controller = LyricsController(
        config: const LyricsConfig(
          idleTimeoutBeforeResume: Duration(milliseconds: 100),
        ),
      );

      expect(controller.isUserScrolling, isFalse);
      controller.onUserScrollStarted();
      expect(controller.isUserScrolling, isTrue);

      controller.resumeAutoScroll();
      expect(controller.isUserScrolling, isFalse);
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('MiniLyricsBar displays active lyric line', (tester) async {
      final doc = LyricsDocument(
        lines: [
          const LyricLine(
            text: 'Now singing this verse',
            start: Duration(seconds: 1),
            end: Duration(seconds: 5),
          ),
        ],
      );
      final controller = LyricsController(document: doc);
      controller.setProgress(const Duration(seconds: 2));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MiniLyricsBar(controller: controller),
          ),
        ),
      );

      expect(find.text('Now singing this verse'), findsOneWidget);
    });

    testWidgets('LyricsView renders list of lyrics with tap interaction',
        (tester) async {
      Duration? tappedTimestamp;
      final doc = LyricsDocument(
        lines: [
          const LyricLine(
            text: 'Verse One',
            start: Duration(seconds: 2),
            end: Duration(seconds: 5),
          ),
          const LyricLine(
            text: 'Verse Two',
            start: Duration(seconds: 6),
            end: Duration(seconds: 9),
          ),
        ],
      );

      final controller = LyricsController(
        document: doc,
        onSeekRequest: (ts) => tappedTimestamp = ts,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LyricsView(
              controller: controller,
              theme: LyricsPreset.spotify(),
            ),
          ),
        ),
      );

      expect(find.text('Verse One'), findsOneWidget);
      expect(find.text('Verse Two'), findsOneWidget);

      // Tap second line to seek
      await tester.tap(find.text('Verse Two'));
      await tester.pump();

      expect(tappedTimestamp, equals(const Duration(seconds: 6)));
    });

    testWidgets('AmbientLyricsBackdrop renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmbientLyricsBackdrop(
              child: Center(child: Text('Ambient Child')),
            ),
          ),
        ),
      );

      expect(find.text('Ambient Child'), findsOneWidget);
    });
  });
}
