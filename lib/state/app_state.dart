import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/level_data.dart';
import '../data/phishing_questions.dart';
import '../models/cyber_level.dart';
import '../models/quiz_question.dart';
import '../screens/result/result_screen.dart';

class AppState extends ChangeNotifier {
  // User profile
  String username = "SecuriGo";
  int dailyXp = 40;
  final int dailyGoalXp = 100;
  int streakDays = 3;
  int totalXp = 1260;
  int level = 5;

  // Levels
  final List<CyberLevel> levels = buildInitialLevels();

  // Current active lesson state
  CyberLevel? activeLevel;
  int? activePracticeLevel;
  final Set<int> completedPracticeLevels = {};
  int currentQuestionIndex = 0;
  int lives = 3;
  bool isAnswered = false;
  bool selectedPhishing = false;
  bool isCorrect = false;
  int sessionCorrectAnswers = 0;
  int sessionXpEarned = 0;

  final List<QuizQuestion> phishingQuestions = buildPhishingQuestions();

  QuizQuestion get currentQuestion => phishingQuestions[currentQuestionIndex];

  void startLesson(CyberLevel level) {
    activePracticeLevel = null;
    activeLevel = level;
    currentQuestionIndex = 0;
    lives = 3;
    isAnswered = false;
    sessionCorrectAnswers = 0;
    sessionXpEarned = 0;
    notifyListeners();
  }

  bool isPracticeUnlocked(int level) =>
      level >= 1 && level <= 50 &&
      ((level - 1) % 10 == 0 || completedPracticeLevels.contains(level) ||
          completedPracticeLevels.contains(level - 1));

  void startPractice(int level) {
    if (!isPracticeUnlocked(level)) return;
    activeLevel = null;
    activePracticeLevel = level;
    currentQuestionIndex = 0;
    lives = 3;
    isAnswered = false;
    sessionCorrectAnswers = 0;
    sessionXpEarned = 0;
    notifyListeners();
  }

  void answerQuestion(bool userSaysPhishing) {
    if (isAnswered) return;

    selectedPhishing = userSaysPhishing;
    isAnswered = true;
    isCorrect = (currentQuestion.isPhishing == userSaysPhishing);

    if (isCorrect) {
      sessionCorrectAnswers++;
      sessionXpEarned += 20; // 20 XP per correct answer
    } else {
      lives = math.max(0, lives - 1);
    }
    notifyListeners();
  }

  void nextQuestion(BuildContext context) {
    isAnswered = false;
    if (lives <= 0) {
      finishLesson(context, completedSuccess: false);
    } else if (currentQuestionIndex < phishingQuestions.length - 1) {
      currentQuestionIndex++;
      notifyListeners();
    } else {
      finishLesson(context, completedSuccess: true);
    }
  }

  void finishLesson(BuildContext context, {required bool completedSuccess}) {
    if (completedSuccess) {
      if (activePracticeLevel != null) {
        completedPracticeLevels.add(activePracticeLevel!);
      }
      dailyXp = math.min(dailyGoalXp, dailyXp + sessionXpEarned);
      totalXp += sessionXpEarned;

      // Unlock next level as demo progression
      if (activeLevel != null && activeLevel!.id == 2) {
        levels[1].status = LevelStatus.completed;
        levels[1].progress = 1.0;
        levels[2].status = LevelStatus.unlocked;
      }
    }
    notifyListeners();

    // Navigate to result screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          xpEarned: completedSuccess ? sessionXpEarned : 0,
          isSuccess: completedSuccess,
          score: sessionCorrectAnswers,
          totalQuestions: phishingQuestions.length,
        ),
      ),
    );
  }

  void resetProgress() {
    completedPracticeLevels.clear();
    activePracticeLevel = null;
    dailyXp = 40;
    totalXp = 1260;
    levels[0].status = LevelStatus.completed;
    levels[0].progress = 1.0;
    levels[1].status = LevelStatus.unlocked;
    levels[1].progress = 0.75;
    for (int i = 2; i < levels.length; i++) {
      levels[i].status = LevelStatus.locked;
      levels[i].progress = 0.0;
    }
    notifyListeners();
  }
}
