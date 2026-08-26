import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';

void main() {
  const scheduler = TimerWriteAuthorityScheduler();

  test('executes a scheduled action once', () async {
    final completed = Completer<void>();

    late ScheduledWriteAuthorityTask task;

    task = scheduler.schedule(Duration.zero, () async {
      completed.complete();
    });

    expect(task.isActive, isTrue);

    await completed.future.timeout(const Duration(seconds: 1));

    expect(task.isActive, isFalse);
  });

  test('cancels a scheduled action', () async {
    var executed = false;

    final task = scheduler.schedule(const Duration(milliseconds: 20), () async {
      executed = true;
    });

    expect(task.isActive, isTrue);

    task.cancel();

    expect(task.isActive, isFalse);

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(executed, isFalse);
  });
}
