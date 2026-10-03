import 'package:flutter/material.dart';
import '../../models/narrative_question.dart';
import '../../services/narrative_question_repository.dart';
import '../../screens/practice/narrative_scenario_screen.dart';

class NarrativePracticeList extends StatefulWidget {
  const NarrativePracticeList({super.key, this.repository});
  final NarrativeQuestionRepository? repository;

  @override
  State<NarrativePracticeList> createState() => _NarrativePracticeListState();
}

class _NarrativePracticeListState extends State<NarrativePracticeList> {
  late Future<List<NarrativeQuestion>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = (widget.repository ?? NarrativeQuestionRepository()).load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<NarrativeQuestion>>(
    future: _questions,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: TextButton.icon(
            onPressed: () => setState(
              () => _questions =
                  (widget.repository ?? NarrativeQuestionRepository()).load(),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Skenario belum dimuat. Coba lagi'),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final questions = snapshot.requireData;
      if (questions.isEmpty) {
        return const Center(child: Text('Belum ada skenario.'));
      }
      return ListView.separated(
        key: const PageStorageKey('narrative-practice'),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        itemCount: questions.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => index == 0
            ? _NarrativeIntro(count: questions.length)
            : _NarrativeCard(question: questions[index - 1], number: index),
      );
    },
  );
}

class _NarrativeIntro extends StatelessWidget {
  const _NarrativeIntro({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Text(
    '$count skenario · Analisis insiden\n'
    'Baca cerita dan log pendukung, lalu tulis langkah penanganan beserta alasannya. '
    'Simpan draf di akun atau minta penilaian beserta saran perbaikan.',
    style: Theme.of(context).textTheme.bodyMedium,
  );
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({required this.question, required this.number});
  final NarrativeQuestion question;
  final int number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.article_outlined, color: theme.colorScheme.primary),
        title: Text('Skenario $number · ${question.title}'),
        subtitle: const Text('Analisis kasus · Tulis langkah penanganan'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NarrativeScenarioScreen(question: question),
          ),
        ),
      ),
    );
  }
}
