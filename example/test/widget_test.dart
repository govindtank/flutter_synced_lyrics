import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('SyncedLyricsShowcaseApp smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SyncedLyricsShowcaseApp());
    expect(find.byType(LyricsStudioScreen), findsOneWidget);
  });
}
