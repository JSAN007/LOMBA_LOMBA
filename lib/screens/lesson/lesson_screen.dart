import 'package:flutter/material.dart';
import '../../components/lesson/lesson_widgets.dart';
import '../../state/app_state_provider.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _scroll = ScrollController();
  bool _wasAnswered = false;
  int _question = -1;
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    if (state.isLoading) return const LessonUnavailable(loading: true);
    if (state.loadError != null || state.currentLessonQuestions.isEmpty) {
      return const LessonUnavailable(loading: false);
    }
    final changedQuestion = _question != state.currentQuestionIndex;
    final reveal = state.isAnswered && !_wasAnswered;
    _question = state.currentQuestionIndex;
    _wasAnswered = state.isAnswered;
    if (changedQuestion || reveal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scroll.hasClients) return;
        _scroll.animateTo(
          reveal ? _scroll.position.maxScrollExtent : 0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LessonHeader(state: state),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  LessonQuestion(state: state),
                  if (state.isAnswered) ...[
                    const SizedBox(height: 24),
                    LessonFeedback(state: state),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
