class QuizQuestion {
  final int id;
  final String sender;
  final String subject;
  final String body;
  final bool isPhishing;
  final String explanation;
  final List<String> redFlags;

  QuizQuestion({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
    required this.isPhishing,
    required this.explanation,
    required this.redFlags,
  });
}
