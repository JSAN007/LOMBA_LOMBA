import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../data/level_data.dart';
import '../models/cyber_level.dart';
import '../models/quiz_question.dart';
import '../models/learning_activity.dart';
import '../screens/result/result_screen.dart';
import '../services/progress_store.dart';

class AppState extends ChangeNotifier {
  // User profile
  String username = "SecuriGo";
  int dailyXp = 40;
  final int dailyGoalXp = 100;
  int _legacyStreakDays = 0;
  int get streakDays => _activities.isEmpty
      ? _legacyStreakDays
      : activityStreak(_activities, DateTime.now());
  set streakDays(int value) => _legacyStreakDays = value;
  final List<LearningActivity> _activities = [];
  List<LearningActivity> get activities => List.unmodifiable(_activities);
  final Map<String, LearningActivity> _unsavedActivities = {};
  bool accountDeletionStarted = false;
  int totalXp = 1260;
  int level = 5;
  int totalLessons = 0;
  int successfulLessons = 0;
  int studySeconds = 0;
  static const dailyGoalMinutes = 100;
  int get studyMinutes => studySeconds ~/ 60;
  double get dailyGoalProgress => studySeconds / (dailyGoalMinutes * 60);
  int get completedCourseLevels =>
      completedPracticeLevels.where((id) => id >= 1 && id <= 50).length;
  double get courseProgress => completedCourseLevels / 50;

  void recordStudySecond() {
    if (studySeconds >= dailyGoalMinutes * 60) return;
    studySeconds++;
    if (studySeconds % 60 == 0) _notify();
  }

  void _syncPaths() {
    for (final path in levels) {
      final first = (path.id - 1) * 10 + 1;
      final completed = completedPracticeLevels
          .where((id) => id >= first && id < first + 10)
          .length;
      path.progress = completed / 10;
      path.status = completed == 10
          ? LevelStatus.completed
          : LevelStatus.unlocked;
    }
  }

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
      item.status = LevelStatus.unlocked;
      item.progress = 0;
    }
  }

  Future<void> loadProgress() async {
    if (_progressStore == null || _progressLoaded) return;
    final data = await _progressStore.load();
    if (_progressStore case final ActivityStore store) {
      final history = await store.loadActivities();
      _activities
        ..clear()
        ..addAll(history);
    }
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
    _syncPaths();
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
      // Keep the deployed v1 Firestore shape. All five paths are rebuilt from
      // completedPracticeLevels on load, including the fifth path.
      for (final item in levels.take(4))
        {'id': item.id, 'status': item.status.name, 'progress': item.progress},
    ],
  };

  void _queueSave() {
    if (_progressStore == null || !_progressLoaded || accountDeletionStarted) {
      return;
    }
    final snapshot = _progressSnapshot();
    final activitiesToSave = _unsavedActivities.values.toList();
    _pendingSave = _pendingSave.then((_) async {
      try {
        await _progressStore.save(snapshot);
        if (_progressStore case final ActivityStore store) {
          for (final activity in activitiesToSave) {
            await store.saveActivity(activity);
            _unsavedActivities.remove(activity.id);
          }
        }
        progressSaveError = null;
      } catch (error) {
        progressSaveError = error;
      }
      _notify();
    });
  }

  Future<void> saveProgress() async {
    if (accountDeletionStarted) return;
    if (_progressStore == null) return;
    if (!_progressLoaded) throw StateError('Progress has not loaded yet');
    _queueSave();
    await _pendingSave;
    if (progressSaveError != null) throw progressSaveError!;
  }

  /// Freeze writes before erasing data so a queued save cannot recreate it.
  Future<void> prepareAccountDeletion() async {
    accountDeletionStarted = true;
    await _pendingSave;
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
      final selectedLevel = activePracticeLevel ?? _activeCourseLevel;
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
  int? _activeCourseLevel;
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
  int get currentSessionLevel => activePracticeLevel ?? _activeCourseLevel ?? 1;

  void startLesson(CyberLevel level) {
    if (accountDeletionStarted) return;
    activePracticeLevel = null;
    activeLevel = level;
    final first = (level.id - 1) * 10 + 1;
    var next = first;
    while (next < first + 9 && completedPracticeLevels.contains(next)) {
      next++;
    }
    if (completedPracticeLevels.contains(next)) next = first;
    _setupLessonSession(next);
  }

  bool isPracticeUnlocked(int level) =>
      level >= 1 &&
      level <= 50 &&
      ((level - 1) % 10 == 0 ||
          completedPracticeLevels.contains(level) ||
          completedPracticeLevels.contains(level - 1));

  void startPractice(int level) {
    if (accountDeletionStarted) return;
    if (!isPracticeUnlocked(level)) return;
    activeLevel = null;
    activePracticeLevel = level;
    _setupLessonSession(level);
  }

  void _setupLessonSession(int levelId) {
    _activeCourseLevel = activeLevel != null ? levelId : null;
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
    if (accountDeletionStarted) return;
    final now = DateTime.now().toUtc();
    final activity = LearningActivity(
      id: '${now.microsecondsSinceEpoch}_${totalLessons + 1}',
      occurredAt: now,
      level: currentSessionLevel,
      practice: activePracticeLevel != null,
      success: completedSuccess,
      xp: completedSuccess ? sessionXpEarned : 0,
      correct: sessionCorrectAnswers,
      questions: currentLessonQuestions.length,
    );
    _activities.add(activity);
    _unsavedActivities[activity.id] = activity;
    totalLessons++;
    if (completedSuccess) {
      successfulLessons++;
      final completedLevel = activePracticeLevel ?? _activeCourseLevel;
      if (completedLevel != null) completedPracticeLevels.add(completedLevel);
      dailyXp = math.min(dailyGoalXp, dailyXp + sessionXpEarned);
      totalXp += sessionXpEarned;
      level = 1 + totalXp ~/ 100;

      _syncPaths();
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

    activeLevel = null;
    _activeCourseLevel = null;
    _syncPaths();
    notifyListeners();
  }
}
