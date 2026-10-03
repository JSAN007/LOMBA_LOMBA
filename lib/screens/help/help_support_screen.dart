import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/cyber_colors.dart';
import '../../widgets/app_snack_bar.dart';

/// Contact channels shown on Help & Support.
///
/// Placeholder addresses: replace the constants below with the real ones.
class SupportContact {
  final String label;
  final String description;
  final IconData icon;
  final String email;
  final Color accent;

  const SupportContact({
    required this.label,
    required this.description,
    required this.icon,
    required this.email,
    required this.accent,
  });
}

const List<SupportContact> kSupportContacts = [
  SupportContact(
    label: 'Contact Admin',
    description: 'Masalah akun, laporan bug, atau permintaan bantuan.',
    icon: Icons.support_agent_rounded,
    email: 'admin@securigo.id',
    accent: CyberColors.accentGreen,
  ),
  SupportContact(
    label: 'Email Pengembang',
    description: 'Saran fitur, laporan celah keamanan, atau feedback.',
    icon: Icons.code_rounded,
    email: 'dev@securigo.id',
    accent: CyberColors.primary,
  ),
];

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.9),
                    colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.headset_mic_rounded,
                      size: 26,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ada yang bisa dibantu?',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hubungi tim kami lewat salah satu kanal di bawah. '
                          'Kami biasanya membalas dalam 1x24 jam.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kontak',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < kSupportContacts.length; i++) ...[
              _ContactCard(contact: kSupportContacts[i]),
              if (i != kSupportContacts.length - 1) const SizedBox(height: 12),
            ],
            const SizedBox(height: 24),
            Text(
              'FAQ Singkat',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    _FaqRow(
                      question: _faqs[i].question,
                      answer: _faqs[i].answer,
                    ),
                    if (i != _faqs.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SupportContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: contact.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: contact.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(contact.icon, size: 20, color: contact.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  contact.label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            contact.description,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    contact.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => _copyEmail(context, contact.email),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy email',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyEmail(BuildContext context, String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    if (!context.mounted) return;
    showAppSnackBar(
      context,
      'Email disalin: $email',
      icon: Icons.check_circle_outline_rounded,
    );
  }
}

class _Faq {
  final String question;
  final String answer;

  const _Faq(this.question, this.answer);
}

const List<_Faq> _faqs = [
  _Faq(
    'Kenapa level saya terkunci?',
    'Selesaikan level sebelumnya terlebih dahulu. Level terbuka otomatis '
        'setelah latihan di level sebelumnya selesai.',
  ),
  _Faq(
    'Progres saya hilang setelah menutup aplikasi?',
    'Untuk versi ini progres latihan tersimpan selama aplikasi berjalan dan '
        'belum disinkronkan ke server.',
  ),
  _Faq(
    'Bagaimana cara membuka badge?',
    'Satu badge terbuka setiap 10 level. Selesaikan seluruh 50 level untuk '
        'membuka kelima badge.',
  ),
];

class _FaqRow extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqRow({required this.question, required this.answer});

  @override
  State<_FaqRow> createState() => _FaqRowState();
}

class _FaqRowState extends State<_FaqRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.answer,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
