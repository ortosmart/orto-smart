import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_scope.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';

void main() {
  late ProfileWriteAuthorityController controller;

  setUp(() {
    controller = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        throw StateError('Unexpected RPC call.');
      }),
      const TimerWriteAuthorityScheduler(),
    );

    addTearDown(controller.dispose);
  });

  testWidgets('provides the same controller through of and read', (
    tester,
  ) async {
    late ProfileWriteAuthorityController listenedController;
    late ProfileWriteAuthorityController readController;

    await tester.pumpWidget(
      ProfileWriteAuthorityScope(
        controller: controller,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              listenedController = ProfileWriteAuthorityScope.of(context);
              readController = ProfileWriteAuthorityScope.read(context);

              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(listenedController, same(controller));
    expect(readController, same(controller));
  });

  testWidgets('fails explicitly when the scope is missing', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            expect(
              () => ProfileWriteAuthorityScope.of(context),
              throwsStateError,
            );
            expect(
              () => ProfileWriteAuthorityScope.read(context),
              throwsStateError,
            );

            return const SizedBox();
          },
        ),
      ),
    );
  });
}
