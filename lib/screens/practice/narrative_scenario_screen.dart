import 'package:flutter/material.dart';
import '../../components/practice/narrative_scenario_content.dart';
import '../../models/narrative_question.dart';
import '../../services/narrative_answer_store.dart';

class NarrativeScenarioScreen extends StatelessWidget {
  const NarrativeScenarioScreen({
    super.key,
    required this.question,
    this.answerStore,
  });
  final NarrativeQuestion question;
  final NarrativeAnswerStore? answerStore;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(question.title)),
    body: NarrativeScenarioContent(
      question: question,
      answerStore: answerStore,
    ),
  );
}
