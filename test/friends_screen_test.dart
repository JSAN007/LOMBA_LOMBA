import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/screens/friends/friends_screen.dart';
import 'package:cybernusa/services/friends_service.dart';

class ControlledSearch implements PlayerSearch {
  final requests = <String, Completer<List<PlayerSummary>>>{};
  @override
  Future<List<PlayerSummary>> search(String text) {
    final request = Completer<List<PlayerSummary>>();
    requests[text] = request;
    return request.future;
  }
}

void main() {
  testWidgets('Own account remains visible and is labelled Kamu', (
    tester,
  ) async {
    final search = ControlledSearch();
    await tester.pumpWidget(MaterialApp(home: FriendsScreen(search: search)));
    await tester.enterText(find.byType(TextField), 'Jovan');
    await tester.pump(const Duration(milliseconds: 450));
    search.requests['Jovan']!.complete([
      const PlayerSummary(id: 'me', name: 'Jovan', isCurrentUser: true),
    ]);
    await tester.pump();
    expect(find.descendant(of: find.byType(ListTile), matching: find.text('Jovan')), findsOneWidget);
    expect(find.text('Kamu · Pemain SecuriGo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('Newer search wins when an older request completes last', (
    tester,
  ) async {
    final search = ControlledSearch();
    await tester.pumpWidget(MaterialApp(home: FriendsScreen(search: search)));
    await tester.enterText(find.byType(TextField), 'jo');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pump(const Duration(milliseconds: 450));
    search.requests['an']!.complete([
      const PlayerSummary(id: '2', name: 'Ana'),
    ]);
    await tester.pump();
    search.requests['jo']!.complete([
      const PlayerSummary(id: '1', name: 'Jovan'),
    ]);
    await tester.pump();
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Jovan'), findsNothing);
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(find.text('Ana'), findsNothing);
    expect(search.requests.length, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Empty and failed searches show useful states', (tester) async {
    final search = ControlledSearch();
    await tester.pumpWidget(MaterialApp(home: FriendsScreen(search: search)));
    await tester.enterText(find.byType(TextField), 'nobody');
    await tester.pump(const Duration(milliseconds: 450));
    search.requests['nobody']!.complete([]);
    await tester.pump();
    expect(find.text('Belum ketemu'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'error');
    await tester.pump(const Duration(milliseconds: 450));
    search.requests['error']!.completeError(StateError('offline'));
    await tester.pump();
    expect(find.text('Belum bisa mencari'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
