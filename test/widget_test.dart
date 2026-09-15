// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:cybernusa/main.dart';

void main() {
  testWidgets('SecuriGo smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecuriGoApp());

    // Verify that the splash screen loads first.
    expect(find.text('SecuriGo'), findsOneWidget);
    expect(find.text('Learn Security, Stay Safe'), findsOneWidget);

    // Advance the fake clock by 3 seconds to complete the splash transition
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // trigger frame rebuild after navigation

    // Verify that the main homepage elements are loaded.
    expect(find.text('Misi Harian'), findsOneWidget);
    expect(find.text('PETA MISI KEAMANAN'), findsOneWidget);
  });
}
