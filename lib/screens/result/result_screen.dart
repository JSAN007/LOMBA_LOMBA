import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cyber_colors.dart';
import '../../widgets/cyber_button.dart';
import '../main_shell.dart';

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
    final palette = context.cyber;

    return Scaffold(
      backgroundColor: palette.background,
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
                    color: (isSuccess ? CyberColors.accentGreen : CyberColors.accentRed).withValues(alpha: 0.1),
                    border: Border.all(
                      color: (isSuccess ? CyberColors.accentGreen : CyberColors.accentRed).withValues(alpha: 0.3),
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
                  color: palette.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // PERFORMANCE STATS CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // XP Gained Stat
                    Column(
                      children: [
                        Text(
                          "XP DIDAPAT",
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: palette.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flash_on_rounded, color: CyberColors.accentYellow, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              "+$xpEarned",
                              style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: palette.textPrimary),
                            ),
                          ],
                        )
                      ],
                    ),

                    // Divider Line
                    Container(width: 1.5, height: 40, color: palette.border),

                    // Score Stat
                    Column(
                      children: [
                        Text(
                          "SKOR",
                          style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold, color: palette.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$score / $totalQuestions",
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: score == totalQuestions ? CyberColors.accentGreen : palette.textPrimary,
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
