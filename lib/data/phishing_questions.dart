import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_question.dart';

/// Reads the introductory question bank from the bundled lesson data.
Future<List<QuizQuestion>> buildPhishingQuestions() async {
  final data =
      jsonDecode(await rootBundle.loadString('assets/data/questions.json'))
          as Map<String, dynamic>;
  final levels = data['levels'] as List<dynamic>;
  final introductory = levels.cast<Map<String, dynamic>>().firstWhere(
    (level) => level['level'] == 1,
  );
  return (introductory['questions'] as List<dynamic>)
      .map(
        (question) => QuizQuestion.fromJson(question as Map<String, dynamic>),
      )
      .toList();
}
