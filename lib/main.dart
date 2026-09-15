import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const SecuriGoApp());
}

// =========================================================================
// DESIGN SYSTEM & THEMING
// =========================================================================

class CyberColors {
  static const Color background = Color(0xFF0B0D17);
  static const Color surface = Color(0xFF16192B);
  static const Color surfaceLight = Color(0xFF22263F);
  static const Color primary = Color(0xFF00F2FE); // Neon Cyan
  static const Color secondary = Color(0xFF9B5DE5); // Electric Purple
  static const Color accentGreen = Color(0xFF00E676); // Emerald Neon Green
  static const Color accentRed = Color(0xFFFF1744); // Ruby Neon Red
  static const Color accentYellow = Color(0xFFFFD600); // Amber Yellow
  static const Color border = Color(0xFF2C314E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F9CAE);
}

class CyberTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: CyberColors.background,
      colorScheme: const ColorScheme.dark(
        primary: CyberColors.primary,
        secondary: CyberColors.secondary,
        surface: CyberColors.surface,
        error: CyberColors.accentRed,
      ),
      cardTheme: CardThemeData(
        color: CyberColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: CyberColors.border, width: 1.5),
        ),
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: CyberColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: CyberColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: CyberColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: CyberColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: CyberColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

// =========================================================================
// MOCK DATA & APP STATE
// =========================================================================

enum LevelStatus { locked, unlocked, completed }

class CyberLevel {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  LevelStatus status;

  CyberLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
  });
}

class QuizQuestion {
  final int id;
  final String sender;
  final String subject;
  final String body;
  final bool isPhishing;
  final String explanation;
  final List<String> redFlags;

  QuizQuestion({
    required this.id,
    required this.sender,
    required this.subject,
    required this.body,
    required this.isPhishing,
    required this.explanation,
    required this.redFlags,
  });
}

class AppState extends ChangeNotifier {
  // User profile
  String username = "SiberNaut-01";
  int dailyXp = 40;
  final int dailyGoalXp = 100;
  int streakDays = 3;
  int totalXp = 450;

  // Levels
  final List<CyberLevel> levels = [
    CyberLevel(
      id: 1,
      title: "Deteksi Phishing",
      subtitle: "Kenali email palsu berbahaya",
      icon: Icons.alternate_email_rounded,
      color: CyberColors.primary,
      status: LevelStatus.unlocked,
    ),
    CyberLevel(
      id: 2,
      title: "Password Mastery",
      subtitle: "Buat kata sandi anti retas",
      icon: Icons.vpn_key_rounded,
      color: CyberColors.secondary,
      status: LevelStatus.locked,
    ),
    CyberLevel(
      id: 3,
      title: "Social Engineering",
      subtitle: "Waspada manipulasi psikologis",
      icon: Icons.people_outline_rounded,
      color: CyberColors.accentYellow,
      status: LevelStatus.locked,
    ),
    CyberLevel(
      id: 4,
      title: "Keamanan Perangkat",
      subtitle: "Proteksi gadget dari malware",
      icon: Icons.phonelink_lock_rounded,
      color: CyberColors.accentGreen,
      status: LevelStatus.locked,
    ),
  ];

  // Current active lesson state
  CyberLevel? activeLevel;
  int currentQuestionIndex = 0;
  int lives = 3;
  bool isAnswered = false;
  bool selectedPhishing = false;
  bool isCorrect = false;
  int sessionCorrectAnswers = 0;
  int sessionXpEarned = 0;

  final List<QuizQuestion> phishingQuestions = [
    QuizQuestion(
      id: 1,
      sender: "layanan@bank-cimb-aman.com",
      subject: "PENTING: Blokir Akun Sementara!",
      body: "Kepada Nasabah Yth,\n\nKami mendeteksi aktivitas mencurigakan pada akun Anda. Demi keamanan, akun Anda telah dinonaktifkan sementara.\n\nSilakan klik tautan di bawah ini untuk verifikasi ulang identitas Anda dalam 24 jam agar akun tidak ditutup permanen:\n👉 http://cimb-verifikasi-akun.online/login\n\nHormat kami,\nLayanan Pelanggan Bank CIMB",
      isPhishing: true,
      explanation: "Domain pengirim (bank-cimb-aman.com) dan link tujuan (cimb-verifikasi-akun.online) menggunakan domain tidak resmi (bukan domain asli bank). Bank resmi tidak akan pernah mengancam memblokir akun Anda dalam 24 jam via link eksternal tidak aman.",
      redFlags: ["Domain pengirim mencurigakan", "Menggunakan tautan HTTP tidak aman", "Tuntutan mendesak (ancaman 24 jam)"],
    ),
    QuizQuestion(
      id: 2,
      sender: "noreply@google.com",
      subject: "Notifikasi Keamanan: Login Baru di Windows",
      body: "Halo SiberNaut,\n\nAkun Google Anda baru saja digunakan untuk login di perangkat Windows baru (Jakarta, Indonesia).\n\nJika ini adalah Anda, tidak perlu ada tindakan lebih lanjut. Jika ini bukan Anda, silakan tinjau aktivitas akun Anda segera di menu keamanan akun Google Anda.\n\nTerima kasih,\nTim Akun Google",
      isPhishing: false,
      explanation: "Email ini aman. Domain pengirim (google.com) adalah resmi, dan email tersebut hanya memberikan notifikasi keamanan tanpa meminta Anda mengklik tautan verifikasi data pribadi yang mencurigakan.",
      redFlags: [],
    ),
    QuizQuestion(
      id: 3,
      sender: "admin-hrd@company-awards.xyz",
      subject: "Selamat! Anda Mendapatkan Bonus Kuartal dari HRD!",
      body: "Halo rekan-rekan,\n\nManajemen perusahaan ingin memberikan apresiasi atas kerja keras Anda selama kuartal ini. Anda terpilih sebagai salah satu penerima bonus tunai senilai Rp5.000.000.\n\nSegera unduh formulir penerimaan bonus di tautan berikut dan isi data rekening bank Anda:\n🔗 http://company-awards.xyz/download/form_bonus.xlsx.exe\n\nJangan beritahu rekan kerja lain demi kerahasiaan bonus Anda!",
      isPhishing: true,
      explanation: "Email ini phishing! Domain pengirim (company-awards.xyz) mencurigakan. File yang diminta diunduh berakhiran .xlsx.exe (file eksekusi berbahaya/malware menyamar sebagai dokumen Excel). HRD resmi tidak akan melarang Anda mengonfirmasi ke bagian keuangan.",
      redFlags: ["Ekstensi file ganda .xlsx.exe (Malware)", "Domain pengirim mencurigakan", "Iming-iming bonus bernilai besar"],
    ),
    QuizQuestion(
      id: 4,
      sender: "notifikasi@kurir-ekspedisi-cepat.xyz",
      subject: "Gagal Kirim: Paket Anda Tertahan di Bea Cukai",
      body: "Pelanggan yang terhormat,\n\nPaket dengan nomor resi JNE-993821-ID tidak dapat dikirimkan karena alamat tidak lengkap dan ada biaya kekurangan pajak bea cukai sebesar Rp15.000.\n\nSilakan selesaikan pembayaran dan perbarui alamat Anda segera melalui aplikasi pelacak paket di tautan berikut:\n🔗 http://kurir-ekspedisi-cepat.xyz/update-resi-pajak\n\nJika dalam 48 jam tidak ada pembayaran, paket akan dikembalikan ke pengirim.",
      isPhishing: true,
      explanation: "Email ini adalah phishing ekspedisi (Smishing/Phishing Paket). Domain pengirim (kurir-ekspedisi-cepat.xyz) bukan domain resmi JNE atau bea cukai. Ekspedisi resmi tidak meminta Anda mengunduh aplikasi mencurigakan atau membayar kekurangan pajak bea cukai melalui link eksternal tidak aman.",
      redFlags: ["Domain kurir palsu", "Meminta biaya tambahan via link tidak resmi", "Batas waktu 48 jam yang mendesak"],
    ),
  ];

  QuizQuestion get currentQuestion => phishingQuestions[currentQuestionIndex];

  void startLesson(CyberLevel level) {
    activeLevel = level;
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
      dailyXp = math.min(dailyGoalXp, dailyXp + sessionXpEarned);
      totalXp += sessionXpEarned;

      // Unlock next level as demo progression
      if (activeLevel != null && activeLevel!.id == 1) {
        levels[0].status = LevelStatus.completed;
        levels[1].status = LevelStatus.unlocked;
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
    dailyXp = 40;
    totalXp = 450;
    levels[0].status = LevelStatus.unlocked;
    for (int i = 1; i < levels.length; i++) {
      levels[i].status = LevelStatus.locked;
    }
    notifyListeners();
  }
}

// Central Inherited Widget for dependency injection
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
  }
}

// =========================================================================
// MAIN APP COMPONENT
// =========================================================================

class SecuriGoApp extends StatefulWidget {
  const SecuriGoApp({super.key});

  @override
  State<SecuriGoApp> createState() => _SecuriGoAppState();
}

class _SecuriGoAppState extends State<SecuriGoApp> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _appState,
      child: MaterialApp(
        title: 'SecuriGo',
        debugShowCheckedModeBanner: false,
        theme: CyberTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

// =========================================================================
// BACKGROUND & SPARKLE DECORATIONS
// =========================================================================

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberColors.primary.withOpacity(0.08)
      ..strokeWidth = 1.0;

    double step = 32;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =========================================================================
// SCREEN 0: SPLASH SCREEN
// =========================================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _controller.forward();

    // Auto navigate after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ResponsiveLayoutWrapper(child: HomeScreen()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Cyber tech grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // Central Glowing Logo and Title
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Shield Icon Container with Neon Glow
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CyberColors.primary.withOpacity(0.1),
                            border: Border.all(color: CyberColors.primary, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withOpacity(0.2),
                                blurRadius: 24,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: CyberColors.primary,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title (no emojis)
                        const Text(
                          "SecuriGo",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        const Text(
                          "Learn Security, Stay Safe",
                          style: TextStyle(
                            fontSize: 14,
                            color: CyberColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Lower Loading indicator
          Positioned(
            bottom: 80,
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const LinearProgressIndicator(
                      backgroundColor: CyberColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(CyberColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Memuat Modul Belajar...",
                  style: TextStyle(
                    color: CyberColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Responsive Wrapper for Desktop/Tablet displays
class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveLayoutWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: const BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: CyberColors.border, width: 1.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGETS & SHARED COMPONENTS
// =========================================================================

// Glowing Action Button
class CyberButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  final bool isOutline;
  final IconData? icon;

  const CyberButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.glowColor = CyberColors.primary,
    this.isOutline = false,
    this.icon,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: widget.isOutline
                ? null
                : LinearGradient(
                    colors: [
                      widget.glowColor,
                      widget.glowColor.withBlue(math.min(255, widget.glowColor.blue + 40)),
                    ],
                  ),
            border: widget.isOutline
                ? Border.all(color: widget.glowColor, width: 2)
                : null,
            boxShadow: widget.isOutline
                ? []
                : [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.isOutline ? widget.glowColor : Colors.black87,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: widget.isOutline ? widget.glowColor : Colors.black87,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// SCREEN 1: HOME SCREEN
// =========================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // PROFILE & STATUS HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  children: [
                    // Profile Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Avatar with clean Material design icon instead of emoji
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [CyberColors.primary, CyberColors.secondary],
                                  ),
                                  border: Border.all(color: CyberColors.border, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.username,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text(
                                      "Keamanan Siber Pemula",
                                      style: TextStyle(
                                        color: CyberColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak Indicator with local fire icon instead of emoji
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: CyberColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CyberColors.accentYellow.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: CyberColors.accentYellow,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${state.streakDays} Hari",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CyberColors.accentYellow,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // DAILY PROGRESS CARD
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.insights_rounded,
                                      color: CyberColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Misi Harian",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${state.dailyXp}/${state.dailyGoalXp} XP",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: CyberColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // XP Progress Bar
                            Stack(
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: CyberColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: math.min(1.0, state.dailyXp / state.dailyGoalXp),
                                  ),
                                  builder: (context, value, child) {
                                    return Container(
                                      height: 16,
                                      width: (MediaQuery.of(context).size.width - 80) * value,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [CyberColors.primary, CyberColors.secondary],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CyberColors.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Kumpulkan 60 XP lagi untuk mempertahankan streak!",
                              style: TextStyle(
                                fontSize: 12,
                                color: CyberColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SUBTITLE MAP SECTION
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    "PETA MISI KEAMANAN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // LEVEL PATHWAY MAP
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(bottom: 60),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dynamic connecting line behind nodes
                    Positioned(
                      top: 40,
                      bottom: 40,
                      child: CustomPaint(
                        size: Size(160, 480),
                        painter: PathLinePainter(levelsCount: state.levels.length),
                      ),
                    ),

                    // Level circular buttons
                    Column(
                      children: List.generate(state.levels.length, (index) {
                        final level = state.levels[index];
                        final alignIndex = index % 3;
                        Alignment nodeAlignment = Alignment.center;

                        if (alignIndex == 0) {
                          nodeAlignment = const Alignment(-0.4, 0);
                        } else if (alignIndex == 1) {
                          nodeAlignment = const Alignment(0.4, 0);
                        } else {
                          nodeAlignment = Alignment.center;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          width: double.infinity,
                          child: Align(
                            alignment: nodeAlignment,
                            child: LevelNodeWidget(
                              level: level,
                              pulseController: _pulseController,
                              onPressed: () {
                                if (level.status != LevelStatus.locked) {
                                  state.startLesson(level);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ResponsiveLayoutWrapper(
                                        child: LessonScreen(),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: CyberColors.surfaceLight,
                                      content: Row(
                                        children: [
                                          const Icon(Icons.lock_outline, color: CyberColors.secondary),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Selesaikan level sebelumnya untuk membuka '${level.title}'!",
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // RESET BUTTON FOR DEMO REPLAY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextButton.icon(
                  onPressed: () {
                    state.resetProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Progres disetel ulang untuk simulasi demo!"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: CyberColors.textSecondary, size: 16),
                  label: const Text(
                    "Setel Ulang Progres Demo",
                    style: TextStyle(color: CyberColors.textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background path lines painter
class PathLinePainter extends CustomPainter {
  final int levelsCount;

  PathLinePainter({required this.levelsCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CyberColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = CyberColors.secondary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double startX = size.width / 2;
    double startY = 40.0;
    path.moveTo(startX, startY);

    List<Offset> points = [];
    points.add(Offset(startX - 50, 40));
    points.add(Offset(startX + 50, 160));
    points.add(Offset(startX, 280));
    points.add(Offset(startX - 50, 400));

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      double xc = (points[i - 1].dx + points[i].dx) / 2;
      double yc = (points[i - 1].dy + points[i].dy) / 2;
      path.quadraticBezierTo(points[i - 1].dx, points[i - 1].dy, xc, yc);
    }
    path.lineTo(points.last.dx, points.last.dy);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Interactive circular Node
class LevelNodeWidget extends StatelessWidget {
  final CyberLevel level;
  final AnimationController pulseController;
  final VoidCallback onPressed;

  const LevelNodeWidget({
    super.key,
    required this.level,
    required this.pulseController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLocked = level.status == LevelStatus.locked;
    final bool isCompleted = level.status == LevelStatus.completed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Level Circle Button
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            double glowScale = 1.0 + (pulseController.value * 0.15);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulse Ring (Only for unlocked, non-completed level)
                if (!isLocked && !isCompleted)
                  Container(
                    width: 80 * glowScale,
                    height: 80 * glowScale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: level.color.withOpacity(0.15),
                      border: Border.all(
                        color: level.color.withOpacity(0.3),
                        width: 2.0,
                      ),
                    ),
                  ),

                // Main Circle Node
                GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLocked
                          ? const LinearGradient(colors: [Color(0xFF2C314E), Color(0xFF1E2235)])
                          : LinearGradient(
                              colors: [level.color, level.color.withOpacity(0.7)],
                            ),
                      border: Border.all(
                        color: isLocked
                            ? CyberColors.border
                            : (isCompleted ? CyberColors.accentGreen : Colors.white),
                        width: 3.0,
                      ),
                      boxShadow: isLocked
                          ? []
                          : [
                              BoxShadow(
                                color: level.color.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: Center(
                      child: Icon(
                        isLocked
                            ? Icons.lock_outline_rounded
                            : (isCompleted ? Icons.check_circle_outline_rounded : level.icon),
                        color: isLocked ? CyberColors.textSecondary : Colors.black87,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        // Level Info label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: CyberColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CyberColors.border),
          ),
          child: Column(
            children: [
              Text(
                level.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? CyberColors.textSecondary : Colors.white,
                ),
              ),
              Text(
                isLocked ? "Terkunci" : (isCompleted ? "Selesai" : "Mulai"),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isLocked
                      ? CyberColors.textSecondary
                      : (isCompleted ? CyberColors.accentGreen : CyberColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// SCREEN 2: LESSON / QUIZ SCREEN
// =========================================================================

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentQ = state.currentQuestion;

    double progressRatio = (state.currentQuestionIndex) / state.phishingQuestions.length;

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // LESSON HEADER BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Back / Close
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: CyberColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text("Tinggalkan Misi?"),
                          content: const Text(
                            "Anda akan kehilangan semua progress misi ini jika keluar sekarang.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Batal", style: TextStyle(color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Exit lesson screen
                              },
                              child: const Text("Keluar", style: TextStyle(color: CyberColors.accentRed)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Progress Bar Indicator
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: CyberColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 12,
                          width: (MediaQuery.of(context).size.width - 180) * progressRatio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [CyberColors.primary, CyberColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Lives / Hearts Display
                  Row(
                    children: List.generate(3, (index) {
                      return Icon(
                        Icons.favorite_rounded,
                        color: index < state.lives ? CyberColors.accentRed : CyberColors.border,
                        size: 24,
                      );
                    }),
                  ),
                ],
              ),
            ),

            // SIMULATED EMAIL CONTENT PANEL
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Analisis Email di Bawah ini:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CyberColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mock Email Client Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Windows-like client bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEF4444))),
                                    const SizedBox(width: 6),
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF59E0B))),
                                    const SizedBox(width: 6),
                                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                                  ],
                                ),
                                const Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.mail_outline_rounded, color: Colors.black54, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        "Kotak Masuk - Protokol Aman",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.more_horiz, color: Colors.black45, size: 18),
                              ],
                            ),
                          ),

                          // Email Header Details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Dari: ", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          currentQ.sender,
                                          style: const TextStyle(
                                            color: Color(0xFF334155),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            fontFamily: 'monospace',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16, color: Colors.black12),
                                Row(
                                  children: [
                                    const Text("Subjek: ", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Expanded(
                                      child: Text(
                                        currentQ.subject,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: Colors.black12),

                          // Email Body
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                currentQ.body,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  height: 1.5,
                                  fontFamily: 'system-ui',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // DECISION ACTION PANEL
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Safe / Aman Button
                  Expanded(
                    child: CyberButton(
                      text: "Aman",
                      icon: Icons.shield_rounded,
                      glowColor: CyberColors.accentGreen,
                      isOutline: true,
                      onPressed: () {
                        state.answerQuestion(false);
                        _showFeedbackPanel(context, state);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Phishing Button
                  Expanded(
                    child: CyberButton(
                      text: "Phishing",
                      icon: Icons.warning_rounded,
                      glowColor: CyberColors.accentRed,
                      onPressed: () {
                        state.answerQuestion(true);
                        _showFeedbackPanel(context, state);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide-up feedback bottom panel
  void _showFeedbackPanel(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool correct = state.isCorrect;
        final String title = correct ? "Jawaban Benar!" : "Oops, Kurang Tepat!";
        final Color themeColor = correct ? CyberColors.accentGreen : CyberColors.accentRed;
        final IconData headerIcon = correct ? Icons.check_circle_rounded : Icons.cancel_rounded;

        return PopScope(
          canPop: false,
          child: Container(
            decoration: BoxDecoration(
              color: CyberColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              border: Border.all(color: CyberColors.border, width: 1.5),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Feedback Header
                Row(
                  children: [
                    Icon(headerIcon, color: themeColor, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Explanation Block
                const Text(
                  "Penjelasan Analisis:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.currentQuestion.explanation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CyberColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Red Flags List (For Phishing emails)
                if (state.currentQuestion.isPhishing && state.currentQuestion.redFlags.isNotEmpty) ...[
                  const Text(
                    "Indikator Ancaman (Red Flags):",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: CyberColors.accentYellow,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.currentQuestion.redFlags.map((flag) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("🚩 ", style: TextStyle(fontSize: 11)),
                            Expanded(
                              child: Text(
                                flag,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CyberColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Continue Button
                CyberButton(
                  text: "Lanjutkan",
                  glowColor: themeColor,
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    state.nextQuestion(context); // Proceed
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// SCREEN 3: RESULT SCREEN
// =========================================================================

class ResultScreen extends StatelessWidget {
  final int xpEarned;
  final bool isSuccess;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.xpEarned,
    required this.isSuccess,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // SUCCESS ILLUSTRATION (TROPHY / MEDAL)
              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSuccess ? CyberColors.accentGreen : CyberColors.accentRed).withOpacity(0.1),
                    border: Border.all(
                      color: (isSuccess ? CyberColors.accentGreen : CyberColors.accentRed).withOpacity(0.3),
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Icon decorations (no emojis)
                        Icon(
                          isSuccess ? Icons.stars_rounded : Icons.heart_broken_rounded,
                          color: isSuccess ? CyberColors.accentYellow : CyberColors.accentRed,
                          size: 90,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CELEBRATION HEADER TEXT
              Text(
                isSuccess ? "Misi Selesai!" : "Misi Gagal",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isSuccess ? CyberColors.accentGreen : CyberColors.accentRed,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSuccess
                    ? "Hebat! Anda berhasil mengenali ancaman siber dengan baik."
                    : "Kehabisan nyawa! Pelajari kembali penjelasan email yang mencurigakan.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CyberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // PERFORMANCE STATS CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // XP Gained Stat
                      Column(
                        children: [
                          const Text(
                            "XP DIDAPAT",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, color: CyberColors.accentYellow, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "+$xpEarned",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),

                      // Divider Line
                      Container(width: 1.5, height: 40, color: CyberColors.border),

                      // Score Stat
                      Column(
                        children: [
                          const Text(
                            "SKOR",
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CyberColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$score / $totalQuestions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: score == totalQuestions ? CyberColors.accentGreen : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ACTION BUTTON TO RETURN TO HOME
              CyberButton(
                text: isSuccess ? "Kembali ke Beranda" : "Ulangi Misi",
                glowColor: isSuccess ? CyberColors.primary : CyberColors.accentRed,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const ResponsiveLayoutWrapper(
                        child: HomeScreen(),
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
