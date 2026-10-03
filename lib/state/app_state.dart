import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../data/level_data.dart';
import '../models/cyber_level.dart';
import '../models/quiz_question.dart';
import '../screens/result/result_screen.dart';
import '../services/progress_store.dart';

class AppState extends ChangeNotifier {
  // User profile
  String username = "SecuriGo";
  int dailyXp = 40;
  final int dailyGoalXp = 100;
  int streakDays = 3;
  int totalXp = 1260;
  int level = 5;
  int totalLessons = 0;
  int successfulLessons = 0;

  // Levels
  final List<CyberLevel> levels = buildInitialLevels();

  // Questions Data
  final Map<int, List<QuizQuestion>> _allQuestions = {};
  bool isLoading = true;

  final AssetBundle _questionBundle;
  final ProgressStore? _progressStore;
  Future<void> _pendingSave = Future<void>.value();
  bool _disposed = false;
  bool _progressLoaded = false;
  bool isSigningOut = false;
  Object? progressSaveError;

  AppState({AssetBundle? questionBundle, ProgressStore? progressStore})
    : _questionBundle = questionBundle ?? rootBundle,
      _progressStore = progressStore {
    if (progressStore != null) _resetAccountProgress();
    _loadQuestions();
  }

  void _resetAccountProgress() {
    dailyXp = 0;
    streakDays = 0;
    totalXp = 0;
    level = 1;
    totalLessons = 0;
    successfulLessons = 0;
    completedPracticeLevels.clear();
    for (final item in levels) {
      item.status = item.id == 1 ? LevelStatus.unlocked : LevelStatus.locked;
      item.progress = 0;
    }
  }

  Future<void> loadProgress() async {
    if (_progressStore == null || _progressLoaded) return;
    final data = await _progressStore.load();
    if (_disposed) return;
    if (data != null) {
      dailyXp = (data['dailyXp'] as num).toInt();
      streakDays = (data['streakDays'] as num).toInt();
      totalXp = (data['totalXp'] as num).toInt();
      level = (data['level'] as num).toInt();
      totalLessons = (data['totalLessons'] as num).toInt();
      successfulLessons = (data['successfulLessons'] as num).toInt();
      completedPracticeLevels
        ..clear()
        ..addAll((data['completedPracticeLevels'] as List).cast<int>());
      final savedLevels = data['levels'] as List;
      for (final saved in savedLevels.cast<Map>()) {
        final id = (saved['id'] as num).toInt();
        if (id < 1 || id > levels.length) continue;
        levels[id - 1].status = LevelStatus.values.byName(
          saved['status'] as String,
        );
        levels[id - 1].progress = (saved['progress'] as num).toDouble();
      }
    } else {
      await _progressStore.save(_progressSnapshot());
    }
    _progressLoaded = true;
    _notify();
  }

  Map<String, dynamic> _progressSnapshot() => {
    'schemaVersion': 1,
    'dailyXp': dailyXp,
    'streakDays': streakDays,
    'totalXp': totalXp,
    'level': level,
    'totalLessons': totalLessons,
    'successfulLessons': successfulLessons,
    'completedPracticeLevels': completedPracticeLevels.toList()..sort(),
    'levels': [
      for (final item in levels)
        {'id': item.id, 'status': item.status.name, 'progress': item.progress},
    ],
  };

  void _queueSave() {
    if (_progressStore == null || !_progressLoaded) return;
    final snapshot = _progressSnapshot();
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _progressStore.save(snapshot);
        progressSaveError = null;
      } catch (error) {
        progressSaveError = error;
      }
      _notify();
    });
  }

  Future<void> saveProgress() async {
    if (_progressStore == null) return;
    if (!_progressLoaded) throw StateError('Progress has not loaded yet');
    _queueSave();
    await _pendingSave;
    if (progressSaveError != null) throw progressSaveError!;
  }

  Future<void> signOut(Future<void> Function() signOutAccount) async {
    if (isSigningOut) return;
    isSigningOut = true;
    _notify();
    try {
      await saveProgress();
      await signOutAccount();
    } finally {
      isSigningOut = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
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
      _notify();
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
    totalLessons++;
    if (completedSuccess) {
      successfulLessons++;
      if (activePracticeLevel != null) {
        completedPracticeLevels.add(activePracticeLevel!);
      }
      dailyXp = math.min(dailyGoalXp, dailyXp + sessionXpEarned);
      totalXp += sessionXpEarned;
      level = 1 + totalXp ~/ 100;

      // Unlock next level logic
      if (activeLevel != null && activeLevel!.id <= levels.length) {
        levels[activeLevel!.id - 1].status = LevelStatus.completed;
        levels[activeLevel!.id - 1].progress = 1.0;

        if (activeLevel!.id < levels.length) {
          levels[activeLevel!.id].status = LevelStatus.unlocked;
        }
      }
    }
    _queueSave();
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
    if (_progressStore != null) {
      _resetAccountProgress();
      activePracticeLevel = null;
      activeLevel = null;
      _queueSave();
      _notify();
      return;
    }
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
