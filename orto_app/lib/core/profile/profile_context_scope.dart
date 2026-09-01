import 'package:flutter/widgets.dart';

import 'profile_context.dart';

class ProfileContextScope extends InheritedWidget {
  final ProfileContext profileContext;

  const ProfileContextScope({
    super.key,
    required this.profileContext,
    required super.child,
  });

  static ProfileContext of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProfileContextScope>();

    if (scope == null) {
      throw StateError('ProfileContextScope not found in the widget tree.');
    }

    return scope.profileContext;
  }

  static ProfileContext read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<ProfileContextScope>();

    final scope = element?.widget;

    if (scope is! ProfileContextScope) {
      throw StateError('ProfileContextScope not found in the widget tree.');
    }

    return scope.profileContext;
  }

  @override
  bool updateShouldNotify(ProfileContextScope oldWidget) {
    return profileContext.profileId != oldWidget.profileContext.profileId ||
        profileContext.role != oldWidget.profileContext.role;
  }
}
