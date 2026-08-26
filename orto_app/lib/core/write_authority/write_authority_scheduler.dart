import 'dart:async';

typedef ScheduledWriteAuthorityAction = Future<void> Function();

abstract interface class ScheduledWriteAuthorityTask {
  bool get isActive;

  void cancel();
}

abstract interface class WriteAuthorityScheduler {
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  );
}

class TimerWriteAuthorityScheduler implements WriteAuthorityScheduler {
  const TimerWriteAuthorityScheduler();

  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    final timer = Timer(delay, () => unawaited(action()));

    return _TimerScheduledWriteAuthorityTask(timer);
  }
}

class _TimerScheduledWriteAuthorityTask implements ScheduledWriteAuthorityTask {
  final Timer _timer;

  const _TimerScheduledWriteAuthorityTask(this._timer);

  @override
  bool get isActive => _timer.isActive;

  @override
  void cancel() {
    _timer.cancel();
  }
}
