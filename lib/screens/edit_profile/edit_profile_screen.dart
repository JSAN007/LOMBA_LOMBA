import 'package:flutter/material.dart';

import '../../data/avatar_presets.dart';
import '../../state/profile_controller.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/avatar_pickers.dart';
import '../../components/delete_account_section.dart';

/// Edit Profile: change the display name, the bio, and the avatar preset.
///
/// Edits are held locally and only pushed into [ProfileController] on save, so
/// backing out leaves the profile untouched.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _nameMin = 3;
  static const int _nameMax = 24;
  static const int _bioMax = 160;

  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  late int _avatarPreset;

  /// Snapshot of the saved profile taken once, so the dirty check compares
  /// against what is actually stored instead of re-reading the provider.
  late String _savedName;
  late String _savedBio;
  late int _savedAvatar;

  bool _seeded = false;
  String? _nameError;
  bool _dirty = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;

    final profile = ProfileProvider.of(context).profile;
    _savedName = profile.username;
    _savedBio = profile.bio;
    _savedAvatar = profile.avatarPreset;

    _nameController = TextEditingController(text: _savedName);
    _bioController = TextEditingController(text: _savedBio);
    _avatarPreset = _savedAvatar;

    _nameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
    _seeded = true;
  }

  bool get _dirtyNow =>
      _nameController.text.trim() != _savedName ||
      _bioController.text.trim() != _savedBio ||
      _avatarPreset != _savedAvatar;

  void _onChanged() {
    // Always rebuild: the live preview and the character counters reflect every
    // keystroke, not just the transitions in and out of the dirty state.
    if (!mounted) return;
    setState(() => _dirty = _dirtyNow);
  }

  @override
  void dispose() {
    if (_seeded) {
      _nameController
        ..removeListener(_onChanged)
        ..dispose();
      _bioController
        ..removeListener(_onChanged)
        ..dispose();
    }
    super.dispose();
  }

  bool get _isNameValid =>
      _nameError == null && _nameController.text.trim().length >= _nameMin;

  void _validateName(String value) {
    final trimmed = value.trim();
    String? error;
    if (trimmed.isEmpty) {
      error = 'Nama tidak boleh kosong';
    } else if (trimmed.length < _nameMin) {
      error = 'Minimal $_nameMin karakter';
    } else if (trimmed.length > _nameMax) {
      error = 'Maksimal $_nameMax karakter';
    }
    if (error != _nameError) setState(() => _nameError = error);
  }

  void _save() {
    if (!_isNameValid) return;
    ProfileProvider.of(context).updateProfile(
      username: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarPreset: _avatarPreset,
    );
    Navigator.of(context).pop();
    showAppSnackBar(
      context,
      'Profil berhasil disimpan',
      icon: Icons.check_circle_outline_rounded,
    );
  }

  // The pickers apply the choice themselves and dismiss, so there is no result
  // to read back from the sheet.
  Future<void> _pickAvatar() {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (_) => PresetAvatarPicker(
        selectedIndex: _avatarPreset,
        onSelected: (index) => setState(() {
          _avatarPreset = index;
          // Recomputed from every field: renaming and then re-picking the
          // original avatar must not clear the pending name change.
          _dirty = _dirtyNow;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _MediaPreview(
                    avatarPreset: _avatarPreset,
                    username: _nameController.text.trim(),
                    onEditAvatar: _pickAvatar,
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'Identitas',
                    icon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama tampilan',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          onChanged: _validateName,
                          maxLength: _nameMax,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Nama kamu',
                            errorText: _nameError,
                            counterText:
                                '${_nameController.text.trim().length}/$_nameMax',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bio',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          maxLength: _bioMax,
                          decoration: InputDecoration(
                            hintText: 'Ceritakan sedikit tentang kamu',
                            counterText:
                                '${_bioController.text.trim().length}/$_bioMax',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HintCard(avatarName: avatarPresetName(_avatarPreset)),
                  const SizedBox(height: 24),
                  const DeleteAccountSection(),
                ],
              ),
            ),
            _SaveBar(
              dirty: _dirty,
              enabled: _isNameValid,
              onCancel: () => Navigator.of(context).pop(),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}

/// Live header preview, so the name/avatar/cover choices are visible before
/// anything is saved.
class _MediaPreview extends StatelessWidget {
  static const double _avatarRadius = 44;

  final int avatarPreset;
  final String username;
  final VoidCallback onEditAvatar;

  const _MediaPreview({
    required this.avatarPreset,
    required this.username,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        GestureDetector(
          onTap: onEditAvatar,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: avatarPreset >= 0
                    ? AvatarGradient(presetIndex: avatarPreset)
                    : CircleAvatar(
                        radius: _avatarRadius,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username.isEmpty ? 'Nama kamu' : username,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String avatarName;

  const _HintCard({required this.avatarName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Avatar: $avatarName. '
              'Perubahan baru disimpan setelah kamu menekan Simpan.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final bool dirty;
  final bool enabled;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _SaveBar({
    required this.dirty,
    required this.enabled,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Batal'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              // Save stays disabled until something actually changed and the
              // name is valid, so it reads as the confirming action.
              onPressed: enabled && dirty ? onSave : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
