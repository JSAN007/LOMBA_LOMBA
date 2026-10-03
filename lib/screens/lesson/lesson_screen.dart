import 'package:flutter/material.dart';

import '../../components/lesson/lesson_widgets.dart';
import '../../state/app_state_provider.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _scrollController = ScrollController();
  bool _wasAnswered = false;
  int _questionIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    if (state.isLoading) return const LessonUnavailable(loading: true);
    if (state.loadError != null || state.currentLessonQuestions.isEmpty) {
      return const LessonUnavailable(loading: false);
    }

    final changedQuestion = _questionIndex != state.currentQuestionIndex;
    final revealedAnswer = state.isAnswered && !_wasAnswered;
    _questionIndex = state.currentQuestionIndex;
    _wasAnswered = state.isAnswered;

    if (changedQuestion || revealedAnswer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          revealedAnswer ? _scrollController.position.maxScrollExtent : 0,
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
                controller: _scrollController,
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
