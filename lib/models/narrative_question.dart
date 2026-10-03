class NarrativeQuestion {
  const NarrativeQuestion({
    required this.id,
    required this.title,
    required this.scenario,
    required this.log,
    required this.question,
  });

  final String id;
  final String title;
  final String scenario;
  final String log;
  final String question;

  factory NarrativeQuestion.fromJson(Map<String, dynamic> json) =>
      NarrativeQuestion(
        id: json['id'] as String,
        title: json['title'] as String,
        scenario: json['scenario'] as String,
        log: json['log'] as String,
        question: (json['task'] ?? json['question']) as String,
      );
}
