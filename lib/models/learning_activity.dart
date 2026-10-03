DateTime activityDay(DateTime time) {
  final wib = time.toUtc().add(const Duration(hours: 7));
  return DateTime(wib.year, wib.month, wib.day);
}

class LearningActivity {
  const LearningActivity({
    required this.id,
    required this.occurredAt,
    required this.level,
    required this.practice,
    required this.success,
    required this.xp,
    required this.correct,
    required this.questions,
  });
  final String id;
  final DateTime occurredAt;
  final int level, xp, correct, questions;
  final bool practice, success;
  DateTime get day => activityDay(occurredAt);

  Map<String, dynamic> toMap() => {
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'level': level,
    'practice': practice,
    'success': success,
    'xp': xp,
    'correct': correct,
    'questions': questions,
  };

  factory LearningActivity.fromMap(String id, Map<String, dynamic> data) =>
      LearningActivity(
        id: id,
        occurredAt: DateTime.parse(data['occurredAt'] as String),
        level: data['level'] as int,
        practice: data['practice'] as bool,
        success: data['success'] as bool,
        xp: data['xp'] as int,
        correct: data['correct'] as int,
        questions: data['questions'] as int,
      );
}

int activityStreak(Iterable<LearningActivity> history, DateTime now) {
  final days = history.map((event) => event.day).toSet();
  var cursor = activityDay(now);
  if (!days.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
