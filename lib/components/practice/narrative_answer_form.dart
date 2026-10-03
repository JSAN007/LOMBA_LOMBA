import 'package:flutter/material.dart';
import '../../services/narrative_answer_store.dart';
import 'narrative_grading_panel.dart';

class NarrativeAnswerForm extends StatefulWidget {
  const NarrativeAnswerForm({super.key, required this.questionId, this.store});

  final String questionId;
  final NarrativeAnswerStore? store;

  @override
  State<NarrativeAnswerForm> createState() => _NarrativeAnswerFormState();
}

class _NarrativeAnswerFormState extends State<NarrativeAnswerForm> {
  final _controller = TextEditingController();
  late final NarrativeAnswerStore _store;
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;
  bool _edited = false;
  String? _error;
  String? _savedAnswer;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? NarrativeAnswerStore.forCurrentAccount();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadFailed = false;
    });
    try {
      final answer = await _store.load(widget.questionId);
      if (!mounted) return;
      if (!_edited) _controller.text = answer ?? '';
      _savedAnswer = answer;
    } catch (_) {
      if (!mounted) return;
      _loadFailed = true;
      _error =
          'Jawaban sebelumnya belum bisa dimuat. Kamu tetap bisa mengetik. Muat ulang sebelum menyimpan.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || _loading || _loadFailed) return;
    final answer = _controller.text.trim();
    if (answer.isEmpty) {
      setState(() => _error = 'Tulis langkah penangananmu terlebih dahulu.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _store.save(widget.questionId, answer);
      if (mounted) setState(() => _savedAnswer = answer);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Jawaban belum tersimpan. Periksa koneksi dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved =
        _savedAnswer != null && _savedAnswer == _controller.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Jawabanmu', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Jelaskan tindakan yang kamu ambil, alasannya, dan cara memastikan masalah teratasi.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          enabled: !_saving,
          minLines: 6,
          maxLines: 12,
          maxLength: 4000,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {
            _edited = true;
            if (!_loadFailed) _error = null;
          }),
          decoration: InputDecoration(
            hintText:
                '1. Langkah pertama yang saya lakukan…\n2. Alasannya…\n3. Saya memastikan hasilnya dengan…',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (_edited && _savedAnswer != null && !saved)
          _PreviousAnswer(
            answer: _savedAnswer!,
            onRestore: () => setState(() {
              _controller.text = _savedAnswer!;
              _edited = false;
            }),
          ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading || _saving
              ? null
              : _loadFailed
              ? _load
              : _save,
          icon: Icon(_loadFailed ? Icons.refresh_rounded : Icons.save_outlined),
          label: Text(
            _loading
                ? 'Memuat jawaban…'
                : _saving
                ? 'Menyimpan…'
                : _loadFailed
                ? 'Muat ulang jawaban'
                : 'Simpan jawaban',
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Text(
            saved
                ? 'Draf jawaban tersimpan di akun'
                : 'Simpan jawabanmu sebelum meninggalkan halaman ini.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        NarrativeGradingPanel(
          questionId: widget.questionId,
          answer: _controller.text,
        ),
      ],
    );
  }
}

class _PreviousAnswer extends StatelessWidget {
  const _PreviousAnswer({required this.answer, required this.onRestore});
  final String answer;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: const Text('Lihat jawaban yang sudah tersimpan'),
    children: [
      SelectableText(answer, style: Theme.of(context).textTheme.bodyMedium),
      TextButton(
        onPressed: onRestore,
        child: const Text('Gunakan jawaban tersimpan'),
      ),
    ],
  );
}

