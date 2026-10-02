import 'package:flutter/material.dart';
import '../../components/result/mission_result_widgets.dart';
import '../../state/app_state_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.xpEarned,
    required this.isSuccess,
    required this.score,
    required this.totalQuestions,
  });
  final int xpEarned, score, totalQuestions;
  final bool isSuccess;
  @override
  Widget build(BuildContext context) {
    final practice = AppStateProvider.of(context).activePracticeLevel != null;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MissionResultHero(success: isSuccess),
                  const SizedBox(height: 32),
                  MissionResultStats(
                    xp: xpEarned,
                    score: score,
                    total: totalQuestions,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      practice ? 'Kembali ke Practice' : 'Kembali ke Learn',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
