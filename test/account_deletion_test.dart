import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/services/account_deletion_service.dart';

void main() {
  test('wrong password never erases data', () async {
    var erased = false;
    await expectLater(
      deleteAccountInOrder(
        reauthenticate: () async => throw StateError('wrong password'),
        pauseWrites: () async {},
        eraseData: () async {
          erased = true;
        },
        eraseIdentity: () async {},
      ),
      throwsStateError,
    );
    expect(erased, false);
  });
  test(
    'cleanup failure preserves auth identity so deletion can be retried',
    () async {
      var deleted = false;
      await expectLater(
        deleteAccountInOrder(
          reauthenticate: () async {},
          pauseWrites: () async {},
          eraseData: () async => throw StateError('offline'),
          eraseIdentity: () async {
            deleted = true;
          },
        ),
        throwsStateError,
      );
      expect(deleted, false);
    },
  );
  test(
    'identity is removed only after writes stop and all data is erased',
    () async {
      final steps = <String>[];
      await deleteAccountInOrder(
        reauthenticate: () async {
          steps.add('auth');
        },
        pauseWrites: () async {
          steps.add('pause');
        },
        eraseData: () async {
          steps.add('data');
        },
        eraseIdentity: () async {
          steps.add('identity');
        },
      );
      expect(steps, ['auth', 'pause', 'data', 'identity']);
    },
  );
}
