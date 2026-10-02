import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/cyber_colors.dart';
import '../auth/auth_gate.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Flat vector illustration - phone sized
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: CyberColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shield
                    Icon(
                      Icons.shield_outlined,
                      size: 90,
                      color: CyberColors.primary.withValues(alpha: 0.3),
                    ),
                    // Laptop
                    Positioned(
                      bottom: 35,
                      child: Icon(
                        Icons.laptop_mac_outlined,
                        size: 60,
                        color: CyberColors.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                    // Person
                    Positioned(
                      top: 30,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 45,
                        color: CyberColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Title
              Text(
                'Welcome to SecuriGo.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: CyberColors.textPrimary,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              Text(
                'Your Path to Cyber Mastery,\nfrom Beginner to Pro.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: CyberColors.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AuthGate(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CyberColors.accentGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
