import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/screens/friends/friends_screen.dart';
import 'package:cybernusa/services/friends_service.dart';
import 'package:cybernusa/services/friend_network.dart';

class SearchJovan implements PlayerSearch {
  @override
  Future<List<PlayerSummary>> search(String text) async => [
    const PlayerSummary(id: 'jovan', name: 'Jovan'),
  ];
}

class TestNetwork implements FriendNetwork {
  TestNetwork(this.uid);
  @override
  final String uid;
  final controller = StreamController<List<FriendLink>>.broadcast();
  final sendResult = Completer<void>();
  int sends = 0;
  String? accepted;
  @override
  Stream<List<FriendLink>> watch() => controller.stream;
  @override
  Future<void> send(PlayerSummary player) {
    sends++;
    return sendResult.future;
  }

  @override
  Future<void> accept(FriendLink link) async {
    accepted = link.id;
    controller.add([
      FriendLink(
        id: link.id,
        sender: link.sender,
        recipient: link.recipient,
        senderName: link.senderName,
        recipientName: link.recipientName,
        accepted: true,
      ),
    ]);
  }

  @override
  Future<void> remove(FriendLink link) async {
    controller.add([]);
  }
}

const request = FriendLink(
  id: 'pair',
  sender: 'me',
  recipient: 'jovan',
  senderName: 'Saya',
  recipientName: 'Jovan',
  accepted: false,
);

void main() {
  testWidgets('Add friend sends once and becomes Terkirim after persistence', (
    tester,
  ) async {
    final network = TestNetwork('me');
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsScreen(search: SearchJovan(), network: network),
      ),
    );
    network.controller.add([]);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'jo');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();
    await tester.tap(find.byTooltip('Tambah teman'));
    await tester.pump();
    expect(network.sends, 1);
    final busyButton = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Mengirim…',
      ),
    );
    expect(busyButton.onPressed, isNull);
    network.controller.add([request]);
    network.sendResult.complete();
    await tester.pumpAndSettle();
    expect(find.text('Terkirim'), findsOneWidget);
    expect(find.byTooltip('Tambah teman'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await network.controller.close();
  });
  testWidgets('Incoming request accepts into friends and can be removed', (
    tester,
  ) async {
    final network = TestNetwork('jovan');
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsScreen(search: SearchJovan(), network: network),
      ),
    );
    network.controller.add([request]);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terima'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terima'));
    await tester.pumpAndSettle();
    expect(network.accepted, 'pair');
    expect(find.text('Temanmu · 1'), findsOneWidget);
    expect(find.text('Terima'), findsNothing);
    await tester.ensureVisible(find.text('Hapus teman'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus teman'));
    await tester.pumpAndSettle();
    expect(find.text('Temanmu · 0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await network.controller.close();
  });
  testWidgets('Failed send does not falsely mark player as a friend', (
    tester,
  ) async {
    final network = TestNetwork('me');
    await tester.pumpWidget(
      MaterialApp(
        home: FriendsScreen(search: SearchJovan(), network: network),
      ),
    );
    network.controller.add([]);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'jo');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump();
    await tester.tap(find.byTooltip('Tambah teman'));
    network.sendResult.completeError(StateError('Gagal mengirim'));
    await tester.pumpAndSettle();
    expect(find.text('Gagal mengirim'), findsOneWidget);
    expect(find.text('Terkirim'), findsNothing);
    expect(find.byTooltip('Tambah teman'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await network.controller.close();
  });
}
