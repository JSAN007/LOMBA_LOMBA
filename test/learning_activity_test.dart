import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/models/learning_activity.dart';

void main() {
  LearningActivity event(String id, String time) => LearningActivity(
    id: id,
    occurredAt: DateTime.parse(time),
    level: 11,
    practice: true,
    success: true,
    xp: 100,
    correct: 5,
    questions: 5,
  );
  test('activity uses WIB days and survives serialization', () {
    final item = event('one', '2026-10-02T18:00:00Z');
    expect(item.day, DateTime(2026, 10, 3));
    expect(LearningActivity.fromMap(item.id, item.toMap()).xp, 100);
  });
  test('streak counts distinct consecutive days, including yesterday', () {
    final history = [
      event('1', '2026-10-01T08:00:00Z'),
      event('2', '2026-10-02T08:00:00Z'),
      event('3', '2026-10-02T09:00:00Z'),
    ];
    expect(activityStreak(history, DateTime.utc(2026, 10, 3, 8)), 2);
    expect(activityStreak(history, DateTime.utc(2026, 10, 4, 8)), 0);
    history.add(event('4', '2026-10-03T08:00:00Z'));
    expect(activityStreak(history, DateTime.utc(2026, 10, 3, 8)), 3);
  });
}
