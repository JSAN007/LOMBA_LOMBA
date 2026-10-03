import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../data/level_data.dart';
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

  // Questions Data
  final Map<int, List<QuizQuestion>> _allQuestions = {};
  bool isLoading = true;

  final AssetBundle _questionBundle;

  AppState({AssetBundle? questionBundle})
    : _questionBundle = questionBundle ?? rootBundle {
    _loadQuestions();
  }

  String? loadError;

  Future<void> _loadQuestions() async {
    try {
      final String jsonString = await _questionBundle.loadString(
        'assets/data/questions.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> levelsData = data['levels'];

      for (var levelJson in levelsData) {
        int levelId = levelJson['level'];
        List<dynamic> qs = levelJson['questions'];
        _allQuestions[levelId] = qs
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
      }
      final selectedLevel = activePracticeLevel ?? activeLevel?.id;
      if (selectedLevel != null) {
        currentLessonQuestions = _allQuestions[selectedLevel] ?? [];
      }
    } catch (e, stack) {
      loadError = e.toString();
      debugPrint("=================================");
      debugPrint("ERROR LOADING QUESTIONS: $e");
      debugPrint("$stack");
      debugPrint("=================================");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Current active lesson state
  CyberLevel? activeLevel;
  int? activePracticeLevel;
  final Set<int> completedPracticeLevels = {};

  List<QuizQuestion> currentLessonQuestions = [];
  int currentQuestionIndex = 0;
  int lives = 3;
  bool isAnswered = false;
  int? selectedAnswerIndex;
  bool isCorrect = false;
  int sessionCorrectAnswers = 0;
  int sessionXpEarned = 0;

  QuizQuestion get currentQuestion =>
      currentLessonQuestions[currentQuestionIndex];

  void startLesson(CyberLevel level) {
    activePracticeLevel = null;
    activeLevel = level;
    _setupLessonSession(level.id);
  }

  bool isPracticeUnlocked(int level) =>
      level >= 1 &&
      level <= 50 &&
      ((level - 1) % 10 == 0 ||
          completedPracticeLevels.contains(level) ||
          completedPracticeLevels.contains(level - 1));

  void startPractice(int level) {
    if (!isPracticeUnlocked(level)) return;
    activeLevel = null;
    activePracticeLevel = level;
    _setupLessonSession(level);
  }

  void _setupLessonSession(int levelId) {
    currentLessonQuestions = _allQuestions[levelId] ?? [];
    currentQuestionIndex = 0;
    lives = 3;
    isAnswered = false;
    selectedAnswerIndex = null;
    sessionCorrectAnswers = 0;
    sessionXpEarned = 0;
    notifyListeners();
  }

  void answerQuestion(int answerIndex) {
    if (isAnswered) return;

    selectedAnswerIndex = answerIndex;
    isAnswered = true;
    isCorrect = (currentQuestion.correctAnswerIndex == answerIndex);

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
    selectedAnswerIndex = null;

    if (lives <= 0) {
      finishLesson(context, completedSuccess: false);
    } else if (currentQuestionIndex < currentLessonQuestions.length - 1) {
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

      // Unlock next level logic
      if (activeLevel != null && activeLevel!.id < levels.length) {
        levels[activeLevel!.id - 1].status = LevelStatus.completed;
        levels[activeLevel!.id - 1].progress = 1.0;

        if (activeLevel!.id < levels.length) {
          levels[activeLevel!.id].status = LevelStatus.unlocked;
        }
      }
    }
    notifyListeners();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          xpEarned: completedSuccess ? sessionXpEarned : 0,
          isSuccess: completedSuccess,
          score: sessionCorrectAnswers,
          totalQuestions: currentLessonQuestions.length,
        ),
      ),
    );
  }

  void resetProgress() {
    completedPracticeLevels.clear();
    activePracticeLevel = null;
    dailyXp = 40;
    totalXp = 1260;

    if (levels.isNotEmpty) {
      levels[0].status = LevelStatus.completed;
      levels[0].progress = 1.0;
    }
    if (levels.length > 1) {
      levels[1].status = LevelStatus.unlocked;
      levels[1].progress = 0.75;
    }
    for (int i = 2; i < levels.length; i++) {
      levels[i].status = LevelStatus.locked;
      levels[i].progress = 0.0;
    }
    notifyListeners();
  }
}
