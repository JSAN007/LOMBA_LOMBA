import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/narrative_question.dart';

class NarrativeQuestionRepository {
  NarrativeQuestionRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<NarrativeQuestion>> load() async {
    final raw = await _bundle.loadString(
      'assets/data/narrative_questions.json',
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['questions'] as List)
        .map((row) => NarrativeQuestion.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }
}
