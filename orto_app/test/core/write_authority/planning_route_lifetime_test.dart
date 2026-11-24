import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/write_authority/planning_route_lifetime.dart';
import 'package:orto_app/core/write_authority/route_write_availability.dart';

class _TrackedAvailability extends RouteWriteAvailability {
  int invalidationCalls = 0;
  int disposalCalls = 0;

  bool throwOnInvalidate = false;

  _TrackedAvailability()
    : super(authority: null, originalLease: null, isContextValid: () => true);

  @override
  void invalidate() {
    invalidationCalls++;
    super.invalidate();

    if (throwOnInvalidate) {
      throw StateError('Simulated invalidation failure.');
    }
  }

  @override
  void dispose() {
    disposalCalls++;
    super.dispose();
  }
}

void main() {
  late _TrackedAvailability availability;
  late PlanningRouteLifetime lifetime;

  setUp(() {
    availability = _TrackedAvailability();
    lifetime = PlanningRouteLifetime(availability: availability);
  });

  tearDown(() {
    if (availability.disposalCalls == 0) {
      availability.dispose();
    }
  });

  test('T01 lifetime starts open with the original availability', () {
    expect(lifetime.isClosed, isFalse);
    expect(lifetime.availability, same(availability));
    expect(availability.invalidationCalls, 0);
    expect(availability.disposalCalls, 0);
  });

  test('T02 closing without dependents invalidates and disposes', () {
    lifetime.close();

    expect(lifetime.isClosed, isTrue);
    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });

  test('T03 repeated close is idempotent', () {
    lifetime.close();
    lifetime.close();
    lifetime.close();

    expect(lifetime.isClosed, isTrue);
    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });

  test('T04 releasing a dependent preserves the originating route', () {
    final release = lifetime.retain();

    release();

    expect(lifetime.isClosed, isFalse);
    expect(availability.invalidationCalls, 0);
    expect(availability.disposalCalls, 0);

    lifetime.close();

    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });

  test('T05 closing origin preserves notifier until dependent release', () {
    final release = lifetime.retain();

    lifetime.close();

    expect(lifetime.isClosed, isTrue);
    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 0);
    expect(availability.canWrite, isFalse);

    void listener() {}

    expect(() => availability.addListener(listener), returnsNormally);

    availability.removeListener(listener);

    release();

    expect(availability.disposalCalls, 1);
  });

  test('T06 disposal waits for all retained references', () {
    final releaseFirst = lifetime.retain();
    final releaseSecond = lifetime.retain();
    final releaseThird = lifetime.retain();

    lifetime.close();

    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 0);

    releaseSecond();
    expect(availability.disposalCalls, 0);

    releaseFirst();
    expect(availability.disposalCalls, 0);

    releaseThird();
    expect(availability.disposalCalls, 1);
  });

  test('T07 repeated dependent release is idempotent', () {
    final releaseFirst = lifetime.retain();
    final releaseSecond = lifetime.retain();

    lifetime.close();

    releaseFirst();
    releaseFirst();
    releaseFirst();

    expect(availability.disposalCalls, 0);

    releaseSecond();
    releaseSecond();

    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });

  test('T08 closed lifetime rejects new references', () {
    final release = lifetime.retain();

    lifetime.close();

    expect(lifetime.retain, throwsStateError);
    expect(availability.disposalCalls, 0);

    release();

    expect(availability.disposalCalls, 1);
    expect(lifetime.retain, throwsStateError);
    expect(availability.disposalCalls, 1);
  });

  test('T09 dependents can reopen while origin remains open', () {
    for (var index = 0; index < 5; index++) {
      final release = lifetime.retain();

      expect(lifetime.availability, same(availability));

      release();

      expect(lifetime.isClosed, isFalse);
      expect(availability.invalidationCalls, 0);
      expect(availability.disposalCalls, 0);
    }

    lifetime.close();

    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });

  test('T10 origin reference is released if invalidation throws', () {
    final release = lifetime.retain();

    availability.throwOnInvalidate = true;

    expect(lifetime.close, throwsStateError);

    expect(lifetime.isClosed, isTrue);
    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 0);

    expect(lifetime.close, returnsNormally);
    expect(lifetime.retain, throwsStateError);

    release();

    expect(availability.invalidationCalls, 1);
    expect(availability.disposalCalls, 1);
  });
}
