import 'package:flutter/material.dart';
import '../../models/narrative_question.dart';
import '../../services/narrative_answer_store.dart';
import 'narrative_answer_form.dart';

class NarrativeScenarioContent extends StatelessWidget {
  const NarrativeScenarioContent({
    super.key,
    required this.question,
    this.answerStore,
  });
  final NarrativeQuestion question;
  final NarrativeAnswerStore? answerStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text('Situasi', style: theme.textTheme.labelLarge),
        const SizedBox(height: 12),
        Text(question.scenario, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        _IncidentLog(log: question.log),
        const SizedBox(height: 24),
        Text(question.question, style: theme.textTheme.titleLarge),
        const SizedBox(height: 24),
        NarrativeAnswerForm(questionId: question.id, store: answerStore),
        const SizedBox(height: 24),
        Text(
          'Penilaian menggunakan rubrik tindakan, prioritas, alasan, dan verifikasi. '
          'Hasil LLM adalah feedback latihan dan belum menambah XP.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IncidentLog extends StatelessWidget {
  const _IncidentLog({required this.log});
  final String log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: const Text('Log pendukung'),
        leading: const Icon(Icons.terminal_rounded),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [SelectableText(log, style: theme.textTheme.bodySmall)],
      ),
    );
  }
}
