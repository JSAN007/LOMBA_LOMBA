import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cyber_colors.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../widgets/cyber_button.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final palette = context.cyber;
    final currentQ = state.currentQuestion;

    double progressRatio =
        (state.currentQuestionIndex) / state.phishingQuestions.length;

    return Scaffold(
      backgroundColor: palette.background,
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
                    icon: Icon(
                      Icons.close_rounded,
                      color: palette.textPrimary,
                      size: 28,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Tinggalkan Misi?",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          content: Text(
                            "Anda akan kehilangan semua progress misi ini jika keluar sekarang.",
                            style: GoogleFonts.nunito(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "Batal",
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Exit lesson screen
                              },
                              child: Text(
                                "Keluar",
                                style: GoogleFonts.nunito(
                                  color: CyberColors.accentRed,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 12,
                          width:
                              (MediaQuery.of(context).size.width - 180) *
                              progressRatio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                CyberColors.primary,
                                CyberColors.secondary,
                              ],
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
                        color: index < state.lives
                            ? CyberColors.accentRed
                            : palette.border,
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
                        color: palette.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mock Email Client Container
                    // Modelled as a third-party mail app, so it keeps its own
                    // light paper colours in both themes.
                    Container(
                      decoration: BoxDecoration(
                        color: CyberPalette.mailBody,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: palette.shadow.withValues(alpha: 0.24),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: CyberPalette.mailChrome,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.mail_outline_rounded,
                                        color: CyberPalette.mailInkMuted,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      // Flexible keeps the window title inside the
                                      // bar on narrow phones and at large text
                                      // scales; without it the Row overflows.
                                      Flexible(
                                        child: Text(
                                          "Kotak Masuk - Protokol Aman",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.nunito(
                                            color: CyberPalette.mailInk,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.more_horiz,
                                  color: CyberPalette.mailInkMuted,
                                  size: 18,
                                ),
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
                                    Text(
                                      "Dari: ",
                                      style: GoogleFonts.nunito(
                                        color: CyberPalette.mailInkMuted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: CyberPalette.mailChrome,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          currentQ.sender,
                                          style: GoogleFonts.nunito(
                                            color: CyberPalette.mailInk,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 16,
                                  color: CyberPalette.mailHairline,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Subjek: ",
                                      style: GoogleFonts.nunito(
                                        color: CyberPalette.mailInkMuted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        currentQ.subject,
                                        style: GoogleFonts.nunito(
                                          color: CyberPalette.mailInk,
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
                          Container(
                            height: 1,
                            color: CyberPalette.mailHairline,
                          ),

                          // Email Body
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: CyberPalette.mailBody,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: CyberPalette.mailHairline,
                                ),
                              ),
                              child: Text(
                                currentQ.body,
                                style: GoogleFonts.nunito(
                                  color: CyberPalette.mailInk,
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

            // DECISION ACTION PANEL OR FEEDBACK SECTION
            state.isAnswered
                ? Container(
                    width: double.infinity,
                    // Solid pastel fill: dark ink stays readable in both themes,
                    // and a correct/wrong verdict reads at a glance.
                    color: state.isCorrect
                        ? CyberColors.accentGreen
                        : CyberColors.accentRed,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feedback Header
                        Row(
                          children: [
                            Icon(
                              state.isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: palette.onAccent,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            // Expanded lets the verdict wrap instead of
                            // overflowing the panel on narrow phones.
                            Expanded(
                              child: Text(
                                state.isCorrect
                                    ? "Jawaban Benar!"
                                    : "Oops, Kurang Tepat!",
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: palette.onAccent,
                                ),
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
                            color: palette.onAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.currentQuestion.explanation,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: palette.onAccent.withValues(alpha: 0.85),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Red Flags List
                        if (state.currentQuestion.isPhishing &&
                            state.currentQuestion.redFlags.isNotEmpty) ...[
                          Text(
                            "Indikator Ancaman (Red Flags):",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: palette.onAccent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...state.currentQuestion.redFlags.map((flag) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.flag_rounded,
                                    color: palette.onAccent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      flag,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: palette.onAccent.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 16),
                        ],

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              state.nextQuestion(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.onAccent,
                              foregroundColor: state.isCorrect
                                  ? CyberColors.accentGreen
                                  : CyberColors.accentRed,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Lanjutkan",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
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

  // Show inline feedback at bottom
  void _showFeedbackPanel(BuildContext context, AppState state) {
    setState(() {
      // Trigger rebuild to show feedback section
    });
  }
}
