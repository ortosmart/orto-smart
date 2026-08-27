import 'dart:async';

import 'package:flutter/widgets.dart';

import '../identity/app_session_identity.dart';
import '../write_authority/profile_write_authority_controller.dart';
import '../write_authority/profile_write_authority_scope.dart';
import 'profile_context.dart';

typedef ProfileContextResolver = Future<ProfileContext> Function();

typedef AppSessionIdentityCreator = Future<AppSessionIdentity> Function();

typedef ProfileWriteAuthorityControllerCreator =
    ProfileWriteAuthorityController Function();

typedef ProfileSessionFailureBuilder =
    Widget Function(BuildContext context, Object failure, VoidCallback retry);

class ProfileSessionGate extends StatefulWidget {
  final ProfileContextResolver resolveProfileContext;
  final AppSessionIdentityCreator createSessionIdentity;
  final ProfileWriteAuthorityControllerCreator createController;
  final Widget loading;
  final ProfileSessionFailureBuilder failureBuilder;
  final Widget child;

  const ProfileSessionGate({
    super.key,
    required this.resolveProfileContext,
    required this.createSessionIdentity,
    required this.createController,
    required this.loading,
    required this.failureBuilder,
    required this.child,
  });

  @override
  State<ProfileSessionGate> createState() {
    return _ProfileSessionGateState();
  }
}

class _ProfileSessionGateState extends State<ProfileSessionGate> {
  late final ProfileWriteAuthorityController _controller;

  int _generation = 0;
  bool _isReady = false;
  bool _isInitializing = false;
  Object? _failure;

  @override
  void initState() {
    super.initState();

    _controller = widget.createController();
    _isInitializing = true;

    final generation = ++_generation;
    unawaited(_initialize(generation));
  }

  Future<void> _initialize(int generation) async {
    try {
      final profileContext = await widget.resolveProfileContext();

      if (!_isCurrent(generation)) {
        return;
      }

      final identity = await widget.createSessionIdentity();

      if (!_isCurrent(generation)) {
        return;
      }

      await _controller.initialize(
        profileContext: profileContext,
        identity: identity,
      );

      if (!_isCurrent(generation)) {
        return;
      }

      setState(() {
        _isReady = true;
        _isInitializing = false;
        _failure = null;
      });
    } on Object catch (failure) {
      if (!_isCurrent(generation)) {
        return;
      }

      setState(() {
        _isReady = false;
        _isInitializing = false;
        _failure = failure;
      });
    }
  }

  bool _isCurrent(int generation) {
    return mounted && generation == _generation;
  }

  void _retry() {
    if (_isInitializing) {
      return;
    }

    final generation = ++_generation;

    setState(() {
      _isReady = false;
      _isInitializing = true;
      _failure = null;
    });

    unawaited(_initialize(generation));
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return widget.loading;
    }

    final failure = _failure;

    if (failure != null) {
      return widget.failureBuilder(context, failure, _retry);
    }

    if (!_isReady) {
      return widget.loading;
    }

    return ProfileWriteAuthorityScope(
      controller: _controller,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    ++_generation;

    unawaited(_controller.release());
    _controller.dispose();

    super.dispose();
  }
}
