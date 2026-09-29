import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const SecuriGoApp());
}

// =========================================================================
// DESIGN SYSTEM & THEMING — Deep Blue
// =========================================================================

class CyberColors {
  // Deep Blue Palette
  static const Color background = Color(0xFF0A1628);
  static const Color surface = Color(0xFF122043);
  static const Color surfaceLight = Color(0xFF1A2D5A);
  static const Color surfaceCard = Color(0xFF15244D);

  // Accent Colors
  static const Color primary = Color(0xFF4A90E2);       // Bright Blue
  static const Color primaryLight = Color(0xFF6DB3F8);   // Light Blue
  static const Color secondary = Color(0xFF7C5CFC);      // Soft Purple
  static const Color accentGreen = Color(0xFF2ECC71);    // Fresh Green
  static const Color accentRed = Color(0xFFE74C3C);      // Soft Red
  static const Color accentYellow = Color(0xFFF39C12);   // Warm Amber
  static const Color accentOrange = Color(0xFFE67E22);   // Orange

  // Text & Border
  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8BA3C7);
  static const Color textMuted = Color(0xFF5A7499);
  static const Color border = Color(0xFF1E3A6E);
  static const Color borderLight = Color(0xFF2A4A80);

  // Navbar
  static const Color navbarBg = Color(0xCC0F1D38);       // Semi-transparent
  static const Color navbarActive = Color(0xFF4A90E2);
  static const Color navbarInactive = Color(0xFF5A7499);
}

class CyberTheme {
  static TextTheme get _nunitoTextTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
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
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: CyberColors.border, width: 1),
        ),
        elevation: 0,
      ),
      textTheme: _nunitoTextTheme,
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
  double progress; // 0.0 to 1.0

  CyberLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.status,
    this.progress = 0.0,
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
  String username = "SecuriGo";
  int dailyXp = 40;
  final int dailyGoalXp = 100;
  int streakDays = 3;
  int totalXp = 1260;
  int level = 5;

  // Levels
  final List<CyberLevel> levels = [
    CyberLevel(
      id: 1,
      title: "Deteksi Phishing",
      subtitle: "Kenali email palsu berbahaya",
      icon: Icons.alternate_email_rounded,
      color: CyberColors.accentGreen,
      status: LevelStatus.completed,
      progress: 1.0,
    ),
    CyberLevel(
      id: 2,
      title: "Password Mastery",
      subtitle: "Buat kata sandi anti retas",
      icon: Icons.vpn_key_rounded,
      color: CyberColors.accentOrange,
      status: LevelStatus.unlocked,
      progress: 0.75,
    ),
    CyberLevel(
      id: 3,
      title: "Social Engineering",
      subtitle: "Waspada manipulasi psikologis",
      icon: Icons.people_outline_rounded,
      color: CyberColors.secondary,
      status: LevelStatus.locked,
      progress: 0.0,
    ),
    CyberLevel(
      id: 4,
      title: "Keamanan Perangkat",
      subtitle: "Proteksi gadget dari malware",
      icon: Icons.phonelink_lock_rounded,
      color: CyberColors.primary,
      status: LevelStatus.locked,
      progress: 0.0,
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
      ..color = CyberColors.primary.withOpacity(0.04)
      ..strokeWidth = 0.5;

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
            pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
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
          // Subtle grid
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),

          // Central Logo
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
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CyberColors.primary.withOpacity(0.15),
                                CyberColors.secondary.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(color: CyberColors.primary.withOpacity(0.6), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: CyberColors.primary.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 4,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            color: CyberColors.primaryLight,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "SecuriGo",
                          style: GoogleFonts.nunito(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Learn Security, Stay Safe",
                          style: GoogleFonts.nunito(
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

          // Loading indicator
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
                Text(
                  "Memuat Modul Belajar...",
                  style: GoogleFonts.nunito(
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
              vertical: BorderSide(color: CyberColors.border, width: 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// =========================================================================
// MAIN SHELL WITH GLASSMORPHISM BOTTOM NAVBAR
// =========================================================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutWrapper(
      child: Scaffold(
        backgroundColor: CyberColors.background,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            PracticeScreen(),
            LeaderboardScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: GlassNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

// =========================================================================
// GLASSMORPHISM BOTTOM NAVBAR
// =========================================================================

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.school_rounded, "Learn"),
      _NavItem(Icons.fitness_center_rounded, "Practice"),
      _NavItem(Icons.emoji_events_rounded, "Leaderboard"),
      _NavItem(Icons.person_rounded, "Profile"),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: CyberColors.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: CyberColors.borderLight.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                return _GlassNavItem(
                  icon: items[index].icon,
                  label: items[index].label,
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}

class _GlassNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_GlassNavItem> createState() => _GlassNavItemState();
}

class _GlassNavItemState extends State<_GlassNavItem> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? CyberColors.navbarActive
        : (_isHovered ? CyberColors.primaryLight : CyberColors.navbarInactive);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: (widget.isActive || _isHovered)
                  ? CyberColors.primary.withOpacity(widget.isActive ? 0.15 : 0.08)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                    color: color,
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
                    color: widget.isOutline ? widget.glowColor : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: widget.isOutline ? widget.glowColor : Colors.white,
                    letterSpacing: 0.5,
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

// Circular Progress Widget (like in the reference image)
class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.color,
    this.size = 44,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: CyberColors.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            "${(progress * 100).toInt()}%",
            style: GoogleFonts.nunito(
              fontSize: size * 0.26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// SCREEN 1: HOME SCREEN (Matching Reference Image)
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
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100), // Extra bottom padding for navbar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======= HEADER SECTION =======
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row with avatar badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Learn Security",
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: CyberColors.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: CyberColors.borderLight, width: 1.5),
                                    ),
                                    child: const Icon(Icons.security_rounded, color: CyberColors.primary, size: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: CyberColors.borderLight, width: 1.5),
                                    ),
                                    child: const Icon(Icons.shield_rounded, color: CyberColors.secondary, size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Level ${state.level} · ${state.totalXp} XP",
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: CyberColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: CyberColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: CyberColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security_rounded, color: CyberColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "${state.streakDays}",
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: CyberColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======= STATS ROW (Streak, XP, Level) =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: CyberColors.accentOrange,
                      value: "${state.streakDays}",
                      label: "Streak",
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.bolt_rounded,
                      iconColor: CyberColors.accentYellow,
                      value: "${state.totalXp}",
                      label: "XP",
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.emoji_events_rounded,
                      iconColor: CyberColors.secondary,
                      value: "${state.level}",
                      label: "Level",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ======= DAILY GOAL & COURSE PROGRESS =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CyberColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CyberColors.border, width: 1),
                  ),
                  child: Column(
                    children: [
                      // Daily Goal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Goal",
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          Text(
                            "${state.dailyXp}/${state.dailyGoalXp} min",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ProgressBar(
                        progress: state.dailyXp / state.dailyGoalXp,
                        color: CyberColors.accentGreen,
                        backgroundColor: CyberColors.accentGreen.withOpacity(0.12),
                      ),
                      const SizedBox(height: 18),
                      // Course Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Course Progress",
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: CyberColors.textPrimary,
                            ),
                          ),
                          Text(
                            "40%",
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CyberColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ProgressBar(
                        progress: 0.4,
                        color: CyberColors.primary,
                        backgroundColor: CyberColors.primary.withOpacity(0.12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======= START LESSON BUTTON =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _StartLessonButton(
                  onPressed: () {
                    // Find first unlocked (non-completed) level
                    CyberLevel? target;
                    for (var level in state.levels) {
                      if (level.status == LevelStatus.unlocked) {
                        target = level;
                        break;
                      }
                    }
                    if (target != null) {
                      state.startLesson(target);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ResponsiveLayoutWrapper(
                            child: LessonScreen(),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ======= YOUR PATH SECTION =======
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Your Path",
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: CyberColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Path lesson cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: state.levels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PathCard(
                        level: level,
                        onTap: () {
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
                                    Expanded(
                                      child: Text(
                                        "Selesaikan level sebelumnya untuk membuka '${level.title}'!",
                                        style: GoogleFonts.nunito(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Reset button
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: () {
                      AppStateProvider.of(context).resetProgress();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Progres disetel ulang untuk simulasi demo!",
                            style: GoogleFonts.nunito(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, color: CyberColors.textMuted, size: 16),
                    label: Text(
                      "Setel Ulang Progres Demo",
                      style: GoogleFonts.nunito(color: CyberColors.textMuted, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======= HOME SCREEN SUBWIDGETS =======

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CyberColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CyberColors.border, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: CyberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CyberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _ProgressBar({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
      builder: (context, value, child) {
        return Container(
          height: 10,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StartLessonButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _StartLessonButton({required this.onPressed});

  @override
  State<_StartLessonButton> createState() => _StartLessonButtonState();
}

class _StartLessonButtonState extends State<_StartLessonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF27AE60),
                    Color(0xFF2ECC71),
                    Color(0xFF27AE60),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "Start Lesson",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final CyberLevel level;
  final VoidCallback onTap;

  const _PathCard({
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = level.status == LevelStatus.locked;
    final isCompleted = level.status == LevelStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CyberColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLocked ? CyberColors.border : level.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isLocked
                    ? CyberColors.surfaceLight
                    : level.color.withOpacity(0.15),
              ),
              child: Center(
                child: Icon(
                  isLocked ? Icons.lock_outline_rounded : level.icon,
                  color: isLocked ? CyberColors.textMuted : level.color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isLocked ? CyberColors.textMuted : CyberColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CyberColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Progress circle
            if (!isLocked)
              CircularProgressWidget(
                progress: level.progress,
                color: isCompleted ? CyberColors.accentGreen : level.color,
                size: 42,
                strokeWidth: 3.5,
              ),
            if (isLocked)
              Icon(
                Icons.chevron_right_rounded,
                color: CyberColors.textMuted,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// PLACEHOLDER SCREENS FOR TABS
// =========================================================================

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberColors.primary.withOpacity(0.1),
                  border: Border.all(color: CyberColors.primary.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.fitness_center_rounded, color: CyberColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                "Practice",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Latihan keamanan siber segera hadir!",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CyberColors.accentYellow.withOpacity(0.1),
                  border: Border.all(color: CyberColors.accentYellow.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: CyberColors.accentYellow, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                "Leaderboard",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Papan peringkat segera hadir!",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [CyberColors.primary, CyberColors.secondary],
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                state.username,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Level ${state.level} · ${state.totalXp} XP",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: CyberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
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
                          title: Text("Tinggalkan Misi?", style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                          content: Text(
                            "Anda akan kehilangan semua progress misi ini jika keluar sekarang.",
                            style: GoogleFonts.nunito(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Batal", style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Exit lesson screen
                              },
                              child: Text("Keluar", style: GoogleFonts.nunito(color: CyberColors.accentRed, fontWeight: FontWeight.w700)),
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
                    Text(
                      "Analisis Email di Bawah ini:",
                      style: GoogleFonts.nunito(
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
                          // Window bar
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
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.mail_outline_rounded, color: Colors.black54, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Kotak Masuk - Protokol Aman",
                                        style: GoogleFonts.nunito(
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
                                    Text("Dari: ", style: GoogleFonts.nunito(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          currentQ.sender,
                                          style: GoogleFonts.nunito(
                                            color: const Color(0xFF334155),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
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
                                    Text("Subjek: ", style: GoogleFonts.nunito(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Expanded(
                                      child: Text(
                                        currentQ.subject,
                                        style: GoogleFonts.nunito(
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
                                style: GoogleFonts.nunito(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  height: 1.5,
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
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Explanation Block
                Text(
                  "Penjelasan Analisis:",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.currentQuestion.explanation,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: CyberColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Red Flags List (For Phishing emails)
                if (state.currentQuestion.isPhishing && state.currentQuestion.redFlags.isNotEmpty) ...[
                  Text(
                    "Indikator Ancaman (Red Flags):",
                    style: GoogleFonts.nunito(
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
                            const Icon(Icons.flag_rounded, color: CyberColors.accentRed, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                flag,
                                style: GoogleFonts.nunito(
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

              // SUCCESS ILLUSTRATION
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
                    child: Icon(
                      isSuccess ? Icons.stars_rounded : Icons.heart_broken_rounded,
                      color: isSuccess ? CyberColors.accentYellow : CyberColors.accentRed,
                      size: 90,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // CELEBRATION HEADER TEXT
              Text(
                isSuccess ? "Misi Selesai!" : "Misi Gagal",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
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
                style: GoogleFonts.nunito(
                  color: CyberColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // PERFORMANCE STATS CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CyberColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CyberColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // XP Gained Stat
                    Column(
                      children: [
                        Text(
                          "XP DIDAPAT",
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: CyberColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: CyberColors.accentYellow, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "+$xpEarned",
                              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
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
                        Text(
                          "SKOR",
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: CyberColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$score / $totalQuestions",
                          style: GoogleFonts.nunito(
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

              const Spacer(),

              // ACTION BUTTON TO RETURN TO HOME
              CyberButton(
                text: isSuccess ? "Kembali ke Beranda" : "Ulangi Misi",
                glowColor: isSuccess ? CyberColors.primary : CyberColors.accentRed,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const MainShell(),
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
