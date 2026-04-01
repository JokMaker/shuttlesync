// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:shuttlesync/src/app/shuttlesync_app.dart';

void main() {
  testWidgets('App builds (smoke test)', (WidgetTester tester) async {
    await tester.pumpWidget(const ShuttleSyncApp());

    // If the widget tree mounts without throwing, this is enough for CI sanity.
    // (We intentionally do not wait for the splash auto-navigation because it
    // uses animations/timers that can be noisy in widget tests.)
    expect(find.byType(ShuttleSyncApp), findsOneWidget);
  });
}
