// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:cybernusa/app.dart';

void main() {
  testWidgets('SecuriGo smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SecuriGoApp());

    // Verify that the splash screen loads first.
    expect(find.text('SecuriGo'), findsOneWidget);

    // Advance past the splash delay and route transition to onboarding.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle(); // Wait for all animations

    // Verify onboarding screen elements.
    expect(find.text('Welcome to SecuriGo.'), findsOneWidget);
    expect(
      find.text('Your Path to Cyber Mastery,\nfrom Beginner to Pro.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
  });
}
