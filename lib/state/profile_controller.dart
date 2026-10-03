import 'package:flutter/material.dart';

import '../models/user_profile.dart';

/// Holds the editable profile so a change made in Edit Profile survives
/// navigation instead of resetting every time Profile is rebuilt.
class ProfileController extends ChangeNotifier {
  UserProfile _profile;

  ProfileController({UserProfile? initialProfile})
    : _profile = initialProfile ?? UserProfile.dummy();

  UserProfile get profile => _profile;

  void updateProfile({
    required String username,
    required String bio,
    required int avatarPreset,
  }) {
    _profile = _profile.copyWith(
      username: username,
      bio: bio,
      avatarPreset: avatarPreset,
    );
    notifyListeners();
  }
}

/// Inherited wrapper so widgets below Profile can read and watch the profile.
class ProfileProvider extends InheritedNotifier<ProfileController> {
  const ProfileProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ProfileController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProfileProvider>()!
        .notifier!;
  }
}
