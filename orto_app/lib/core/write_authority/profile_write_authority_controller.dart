import 'package:flutter/foundation.dart';

import '../../data/repositories/profile_edit_lock_repository.dart';
import '../identity/app_session_identity.dart';
import '../profile/profile_context.dart';
import 'profile_edit_lock.dart';
import 'write_authority_scheduler.dart';

enum ProfileWriteAuthorityStatus {
  uninitialized,
  readOnlyMember,
  acquiring,
  writer,
  busy,
  alreadyHeldWithoutToken,
  recovering,
  lost,
  forbidden,
  protocolError,
  released,
}

class ProfileWriteAuthorityUnavailableException implements Exception {
  const ProfileWriteAuthorityUnavailableException();

  @override
  String toString() {
    return 'ProfileWriteAuthorityUnavailableException';
  }
}

class ProfileWriteAuthorityController extends ChangeNotifier {
  static const heartbeatInterval = Duration(seconds: 30);
  static const retryInterval = Duration(seconds: 10);

  final ProfileEditLockRepository _repository;
  final WriteAuthorityScheduler _scheduler;
  final DateTime Function() _utcNow;

  ProfileWriteAuthorityStatus _status =
      ProfileWriteAuthorityStatus.uninitialized;

  ProfileEditLockLease? _lease;
  ScheduledWriteAuthorityTask? _scheduledTask;

  String? _profileId;
  AppSessionIdentity? _identity;

  int _generation = 0;
  bool _heartbeatInProgress = false;
  bool _isDisposed = false;
  ProfileWriteAuthorityController(
    this._repository,
    this._scheduler, {
    DateTime Function()? utcNow,
  }) : _utcNow = utcNow ?? (() => DateTime.now().toUtc());

  ProfileWriteAuthorityStatus get status => _status;

  bool get canWrite =>
      _status == ProfileWriteAuthorityStatus.writer &&
      _lease != null &&
      _lease!.expiresAt.isAfter(_utcNow());

  DateTime? get expiresAt => _lease?.expiresAt;

  int? get rowVersion => _lease?.rowVersion;

  ProfileEditLockLease requireLeaseForWrite() {
    final lease = _lease;

    if (_status != ProfileWriteAuthorityStatus.writer || lease == null) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    if (!lease.expiresAt.isAfter(_utcNow())) {
      _clearLeaseAndTransition(ProfileWriteAuthorityStatus.lost);

      throw const ProfileWriteAuthorityUnavailableException();
    }

    return lease;
  }

  Future<void> initialize({
    required ProfileContext profileContext,
    required AppSessionIdentity identity,
  }) async {
    _ensureNotDisposed();
    _heartbeatInProgress = false;

    final generation = ++_generation;

    _cancelScheduledTask();
    _lease = null;
    _profileId = profileContext.profileId;
    _identity = identity;

    if (!profileContext.canWrite) {
      _transitionTo(ProfileWriteAuthorityStatus.readOnlyMember);
      return;
    }

    _transitionTo(ProfileWriteAuthorityStatus.acquiring);

    await _acquire(generation);
  }

  Future<void> _acquire(int generation) async {
    final profileId = _profileId;
    final identity = _identity;

    if (profileId == null || identity == null) {
      _transitionTo(ProfileWriteAuthorityStatus.protocolError);
      return;
    }

    try {
      final result = await _repository.acquire(
        profileId: profileId,
        identity: identity,
      );

      if (!_isCurrent(generation)) {
        return;
      }

      switch (result) {
        case ProfileEditLockAcquired(:final lease):
          _lease = lease;
          _transitionTo(ProfileWriteAuthorityStatus.writer);
          _scheduleHeartbeat(generation, heartbeatInterval);

        case ProfileEditLockAlreadyHeld():
          _lease = null;
          _transitionTo(ProfileWriteAuthorityStatus.alreadyHeldWithoutToken);

        case ProfileEditLockBusy():
          _lease = null;
          _transitionTo(ProfileWriteAuthorityStatus.busy);

        case ProfileEditLockAcquireForbidden():
          _lease = null;
          _transitionTo(ProfileWriteAuthorityStatus.forbidden);

        case ProfileEditLockAcquireInvalidInput():
          _lease = null;
          _transitionTo(ProfileWriteAuthorityStatus.protocolError);
      }
    } on ProfileEditLockProtocolException {
      if (_isCurrent(generation)) {
        _clearLeaseAndTransition(ProfileWriteAuthorityStatus.protocolError);
      }
    } on Object {
      if (_isCurrent(generation)) {
        _lease = null;
        _transitionTo(ProfileWriteAuthorityStatus.recovering);
        _scheduleAcquireRetry(generation);
      }
    }
  }

  void _scheduleHeartbeat(int generation, Duration delay) {
    if (!_isCurrent(generation) || _lease == null) {
      return;
    }

    _cancelScheduledTask();

    _scheduledTask = _scheduler.schedule(delay, () async {
      _scheduledTask = null;
      await _heartbeat(generation);
    });
  }

  void _scheduleAcquireRetry(int generation) {
    if (!_isCurrent(generation) || _lease != null) {
      return;
    }

    _cancelScheduledTask();

    _scheduledTask = _scheduler.schedule(retryInterval, () async {
      _scheduledTask = null;
      await _acquire(generation);
    });
  }

  Future<void> _heartbeat(int generation) async {
    if (!_isCurrent(generation)) {
      return;
    }

    final lease = _lease;

    if (lease == null) {
      _transitionTo(ProfileWriteAuthorityStatus.lost);
      return;
    }

    if (!lease.expiresAt.isAfter(_utcNow())) {
      _clearLeaseAndTransition(ProfileWriteAuthorityStatus.lost);
      return;
    }

    if (_heartbeatInProgress) {
      _scheduleHeartbeat(generation, retryInterval);
      return;
    }

    _heartbeatInProgress = true;

    try {
      final result = await _repository.heartbeat(lease);

      if (!_isCurrent(generation)) {
        return;
      }

      switch (result) {
        case ProfileEditLockRenewed(:final lease):
          _lease = lease;
          _transitionTo(ProfileWriteAuthorityStatus.writer);
          _scheduleHeartbeat(generation, heartbeatInterval);

        case ProfileEditLockHeartbeatNotHolder():
          _clearLeaseAndTransition(ProfileWriteAuthorityStatus.lost);

        case ProfileEditLockHeartbeatForbidden():
          _clearLeaseAndTransition(ProfileWriteAuthorityStatus.forbidden);
      }
    } on ProfileEditLockProtocolException {
      if (_isCurrent(generation)) {
        _clearLeaseAndTransition(ProfileWriteAuthorityStatus.protocolError);
      }
    } on Object {
      if (_isCurrent(generation)) {
        final currentLease = _lease;

        if (currentLease == null ||
            !currentLease.expiresAt.isAfter(_utcNow())) {
          _clearLeaseAndTransition(ProfileWriteAuthorityStatus.lost);
        } else {
          _transitionTo(ProfileWriteAuthorityStatus.recovering);
          _scheduleHeartbeat(generation, retryInterval);
        }
      }
    } finally {
      _heartbeatInProgress = false;
    }
  }

  Future<void> verifyNow() async {
    _ensureNotDisposed();

    final generation = _generation;

    if (_lease == null ||
        _status == ProfileWriteAuthorityStatus.readOnlyMember ||
        _status == ProfileWriteAuthorityStatus.busy ||
        _status == ProfileWriteAuthorityStatus.alreadyHeldWithoutToken) {
      return;
    }

    _cancelScheduledTask();
    _transitionTo(ProfileWriteAuthorityStatus.recovering);

    await _heartbeat(generation);
  }

  Future<ReleaseProfileEditLockResult?> release() async {
    _ensureNotDisposed();

    ++_generation;
    _cancelScheduledTask();

    final lease = _lease;

    _lease = null;
    _profileId = null;
    _identity = null;

    _transitionTo(ProfileWriteAuthorityStatus.released);

    if (lease == null) {
      return null;
    }

    try {
      return await _repository.release(lease);
    } on Object {
      // Il token locale resta eliminato. Il server libererà il lock
      // mediante release riuscita oppure tramite scadenza del lease.
      return null;
    }
  }

  void _clearLeaseAndTransition(ProfileWriteAuthorityStatus status) {
    _cancelScheduledTask();
    _lease = null;
    _transitionTo(status);
  }

  void _transitionTo(ProfileWriteAuthorityStatus status) {
    if (_isDisposed) {
      return;
    }

    _status = status;
    notifyListeners();
  }

  bool _isCurrent(int generation) {
    return !_isDisposed && generation == _generation;
  }

  void _cancelScheduledTask() {
    _scheduledTask?.cancel();
    _scheduledTask = null;
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('ProfileWriteAuthorityController is disposed.');
    }
  }

  @override
  void dispose() {
    ++_generation;
    _cancelScheduledTask();

    _lease = null;
    _profileId = null;
    _identity = null;
    _isDisposed = true;

    super.dispose();
  }
}
