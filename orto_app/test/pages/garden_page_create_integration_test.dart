import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/profile/profile_context_scope.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_scope.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/create_garden_page.dart';
import 'package:orto_app/pages/garden_page.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';

class _ScheduledTask implements ScheduledWriteAuthorityTask {
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  void cancel() => _active = false;
}

class _Scheduler implements WriteAuthorityScheduler {
  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) => _ScheduledTask();
}

void main() {
  testWidgets('Crea orto follows write authority release', (tester) async {
    final releaseResponse = Completer<dynamic>();
    final now = DateTime.utc(2026, 11, 15, 12);

    final authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        if (functionName == 'acquire_profile_edit_lock') {
          return {
            'status': 'acquired',
            'lock_token': 'token-esclusivamente-fittizio',
            'expires_at': '2026-11-15T12:02:00+00:00',
            'row_version': 1,
          };
        }

        if (functionName == 'release_profile_edit_lock') {
          return await releaseResponse.future;
        }

        throw StateError('RPC inattesa: $functionName');
      }),
      _Scheduler(),
      utcNow: () => now,
    );
    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: _profileId,
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );

    expect(authority.canWrite, isTrue);

    final gardenRepository = GardenRepository.withLoader(
      (_) async => <Map<String, dynamic>>[],
    );
    final bedRepository = BedRepository.withLoader((_) async => []);
    final plantingRepository = PlantingRepository.withLoader(
      (_) async => <Map<String, dynamic>>[],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileContextScope(
          profileContext: const ProfileContext(
            profileId: _profileId,
            role: ProfileMemberRole.owner,
          ),
          child: ProfileWriteAuthorityScope(
            controller: authority,
            child: Scaffold(
              body: GardenPage(
                repository: gardenRepository,
                bedRepository: bedRepository,
                plantingRepository: plantingRepository,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final createButton = find.widgetWithText(FilledButton, 'Crea orto');

    expect(createButton, findsOneWidget);
    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);

    final releaseFuture = authority.release();
    await tester.pump();

    expect(authority.canWrite, isFalse);
    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);
    expect(find.byType(CreateGardenPage), findsNothing);

    releaseResponse.complete({'status': 'released'});
    await releaseFuture;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
