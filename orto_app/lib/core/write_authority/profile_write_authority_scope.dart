import 'package:flutter/widgets.dart';

import 'profile_write_authority_controller.dart';

class ProfileWriteAuthorityScope
    extends InheritedNotifier<ProfileWriteAuthorityController> {
  const ProfileWriteAuthorityScope({
    super.key,
    required ProfileWriteAuthorityController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProfileWriteAuthorityController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ProfileWriteAuthorityScope>();

    return scope?.notifier;
  }

  static ProfileWriteAuthorityController of(BuildContext context) {
    final controller = maybeOf(context);

    if (controller == null) {
      throw StateError(
        'ProfileWriteAuthorityScope not found in the widget tree.',
      );
    }

    return controller;
  }

  static ProfileWriteAuthorityController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<ProfileWriteAuthorityScope>();

    final scope = element?.widget;

    if (scope is! ProfileWriteAuthorityScope) {
      throw StateError(
        'ProfileWriteAuthorityScope not found in the widget tree.',
      );
    }

    return scope.notifier!;
  }
}
