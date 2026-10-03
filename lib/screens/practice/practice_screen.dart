import 'package:flutter/material.dart';

import '../../components/practice/choice_practice_list.dart';
import '../../components/practice/narrative_practice_list.dart';
import '../../components/practice/practice_tabs.dart';
import '../../services/narrative_question_repository.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, this.narrativeRepository});
  final NarrativeQuestionRepository? narrativeRepository;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: Column(
        children: [
          const PracticeTabs(),
          Expanded(
            child: TabBarView(
              children: [
                const ChoicePracticeList(),
                NarrativePracticeList(repository: narrativeRepository),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
