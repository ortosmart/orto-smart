import 'package:flutter/foundation.dart';

import 'profile_edit_lock.dart';
import 'profile_write_authority_controller.dart';
import 'write_authority_scheduler.dart';

class RouteWriteAvailability extends ChangeNotifier {
  final ProfileWriteAuthorityController? _authority;
  final ProfileEditLockLease? _originalLease;
  final bool Function() isContextValid;
  final WriteAuthorityScheduler scheduler;

  ScheduledWriteAuthorityTask? _expiryTask;

  bool _isDisposed = false;
  bool _isListening = false;
  bool _lastCanWrite = false;

  int _expiryGeneration = 0;

  RouteWriteAvailability({
    required ProfileWriteAuthorityController? authority,
    required this._originalLease,
    required this.isContextValid,
    this.scheduler = const TimerWriteAuthorityScheduler(),
  }) : _authority = authority {
    final delay = _remainingWriteDuration;

    if (authority != null && delay != null) {
      authority.addListener(_refresh);
      _isListening = true;
    }

    _lastCanWrite = _isListening;
    _scheduleExpiry(_isListening ? delay : null);
  }

  bool get canWrite => _isListening && _remainingWriteDuration != null;

  Duration? get _remainingWriteDuration {
    final authority = _authority;
    final originalLease = _originalLease;

    if (_isDisposed || authority == null || originalLease == null) {
      return null;
    }

    try {
      if (!isContextValid()) {
        return null;
      }
    } on Object {
      return null;
    }

    return authority.remainingWriteDurationForLease(originalLease);
  }

  void refresh() {
    _refresh();
  }

  void _refresh() {
    if (_isDisposed) {
      return;
    }

    final delay = _isListening ? _remainingWriteDuration : null;
    final available = delay != null;
    final changed = available != _lastCanWrite;

    _lastCanWrite = available;
    _scheduleExpiry(delay);

    if (changed) {
      notifyListeners();
    }
  }

  void _scheduleExpiry(Duration? delay) {
    _cancelExpiry();

    if (delay == null || delay <= Duration.zero) {
      return;
    }

    final generation = _expiryGeneration;

    _expiryTask = scheduler.schedule(delay, () async {
      if (_isDisposed || generation != _expiryGeneration) {
        return;
      }

      _expiryTask = null;
      _refresh();
    });
  }

  void _cancelExpiry() {
    ++_expiryGeneration;
    _expiryTask?.cancel();
    _expiryTask = null;
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _cancelExpiry();

    if (_isListening) {
      _authority?.removeListener(_refresh);
      _isListening = false;
    }

    super.dispose();
  }
}
