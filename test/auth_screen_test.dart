import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cybernusa/core/theme/cyber_theme.dart';
import 'package:cybernusa/screens/auth/auth_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  testWidgets('Registration validates email, password and confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: CyberTheme.dark, home: const AuthScreen()),
    );
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jo');
    await tester.enterText(fields.at(1), 'invalid');
    await tester.enterText(fields.at(2), '123');
    await tester.enterText(fields.at(3), '456');
    await tester.ensureVisible(find.text('Buat akun'));
    await tester.tap(find.text('Buat akun'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
    expect(find.text('Gunakan minimal 8 karakter.'), findsOneWidget);
    expect(find.text('Password belum sama.'), findsOneWidget);
  });
  testWidgets('Unconfigured backend never grants account access', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: CyberTheme.dark, home: const AuthScreen()),
    );
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'jo@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.ensureVisible(find.text('Masuk ke SecuriGo'));
    await tester.tap(find.text('Masuk ke SecuriGo'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Layanan akun belum tersedia. Silakan coba lagi setelah konfigurasi aplikasi selesai.',
      ),
      findsOneWidget,
    );
  });
}
