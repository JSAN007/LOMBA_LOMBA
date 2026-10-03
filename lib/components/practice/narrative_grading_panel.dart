import 'package:flutter/material.dart';
import '../../services/narrative_grader.dart';

class NarrativeGradingPanel extends StatefulWidget {
  const NarrativeGradingPanel({
    super.key,
    required this.questionId,
    required this.answer,
    this.grader,
  });
  final String questionId;
  final String answer;
  final NarrativeGrader? grader;
  @override
  State<NarrativeGradingPanel> createState() => _NarrativeGradingPanelState();
}

class _NarrativeGradingPanelState extends State<NarrativeGradingPanel> {
  late final NarrativeGrader _grader;
  NarrativeGrade? _result;
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _grader = widget.grader ?? LocalNarrativeGrader();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _grader.load(widget.questionId);
      if (mounted) setState(() => _result = result);
    } catch (_) {
      // Grading can be retried explicitly without blocking draft editing.
    }
  }

  Future<void> _grade() async {
    if (_busy) return;
    final answer = widget.answer.trim();
    if (answer.isEmpty) {
      setState(() => _error = 'Tulis jawabanmu sebelum meminta penilaian.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await _grader.grade(widget.questionId, answer);
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is GradingFailure
              ? error.message
              : 'Penilaian belum berhasil. Coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    final matches = result != null && result.answer == widget.answer.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _busy ? null : _grade,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(_busy ? 'Sedang menilai…' : 'Nilai jawaban'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        if (matches) _GradeResult(grade: result),
        if (result != null && !matches)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Jawaban berubah. Minta penilaian untuk jawaban terbaru.',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _GradeResult extends StatelessWidget {
  const _GradeResult({required this.grade});
  final NarrativeGrade grade;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${grade.score}/100', style: theme.textTheme.headlineMedium),
            Text(
              grade.engine == 'local-nlp'
                  ? 'Penilaian NLP lokal'
                  : 'Penilaian LLM',
              style: theme.textTheme.labelLarge,
            ),
            if (grade.assessmentNote != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  grade.assessmentNote!,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Tingkat kemampuan: ${grade.skillLevel}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Berdasarkan jawaban ini, bukan level akun atau penilaian kemampuan keseluruhan.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            for (final entry in grade.abilities.entries)
              _AbilityScore(name: entry.key, score: entry.value),
            const SizedBox(height: 12),
            Text(grade.feedback, style: theme.textTheme.bodyLarge),
            for (final improvement in grade.improvements)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '• $improvement',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AbilityScore extends StatelessWidget {
  const _AbilityScore({required this.name, required this.score});
  final String name;
  final int score;
  static const _labels = {
    'accuracy': 'Ketepatan tindakan',
    'priorities': 'Prioritas penanganan',
    'reasoning': 'Alasan dan analisis',
    'verification': 'Verifikasi pemulihan',
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_labels[name] ?? name}: $score/25',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: (score / 25).clamp(0, 1),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
