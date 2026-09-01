import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/profile/profile_context_scope.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _otherProfileId = '22222222-2222-4222-8222-222222222222';

const _ownerContext = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

void main() {
  group('ProfileContextScope access', () {
    testWidgets('of returns the provided context', (tester) async {
      ProfileContext? received;

      await tester.pumpWidget(
        ProfileContextScope(
          profileContext: _ownerContext,
          child: Builder(
            builder: (context) {
              received = ProfileContextScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(received, same(_ownerContext));
    });

    testWidgets('read works for a read-only member without a lease', (
      tester,
    ) async {
      const viewerContext = ProfileContext(
        profileId: _profileId,
        role: ProfileMemberRole.viewer,
      );
      ProfileContext? received;

      await tester.pumpWidget(
        ProfileContextScope(
          profileContext: viewerContext,
          child: Builder(
            builder: (context) {
              received = ProfileContextScope.read(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(received, same(viewerContext));
      expect(received!.canWrite, isFalse);
    });

    testWidgets('of throws when the scope is missing', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => ProfileContextScope.of(context),
              throwsA(isA<StateError>()),
            );
            return const SizedBox.shrink();
          },
        ),
      );
    });

    testWidgets('read throws when the scope is missing', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => ProfileContextScope.read(context),
              throwsA(isA<StateError>()),
            );
            return const SizedBox.shrink();
          },
        ),
      );
    });
  });

  group('ProfileContextScope notifications', () {
    testWidgets('of rebuilds its dependent when the profile changes', (
      tester,
    ) async {
      var builds = 0;
      ProfileContext? received;

      final child = Builder(
        builder: (context) {
          builds += 1;
          received = ProfileContextScope.of(context);
          return const SizedBox.shrink();
        },
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: _ownerContext, child: child),
      );

      expect(builds, 1);

      const otherContext = ProfileContext(
        profileId: _otherProfileId,
        role: ProfileMemberRole.owner,
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: otherContext, child: child),
      );

      expect(builds, 2);
      expect(received, same(otherContext));
    });

    testWidgets('of rebuilds its dependent when the role changes', (
      tester,
    ) async {
      var builds = 0;
      ProfileContext? received;

      final child = Builder(
        builder: (context) {
          builds += 1;
          received = ProfileContextScope.of(context);
          return const SizedBox.shrink();
        },
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: _ownerContext, child: child),
      );

      const viewerContext = ProfileContext(
        profileId: _profileId,
        role: ProfileMemberRole.viewer,
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: viewerContext, child: child),
      );

      expect(builds, 2);
      expect(received, same(viewerContext));
      expect(received!.canWrite, isFalse);
    });

    testWidgets('equivalent context does not rebuild the dependent', (
      tester,
    ) async {
      var builds = 0;

      final child = Builder(
        builder: (context) {
          builds += 1;
          ProfileContextScope.of(context);
          return const SizedBox.shrink();
        },
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: _ownerContext, child: child),
      );

      final equivalentContext = ProfileContext(
        profileId: _ownerContext.profileId,
        role: _ownerContext.role,
      );

      expect(identical(equivalentContext, _ownerContext), isFalse);

      await tester.pumpWidget(
        ProfileContextScope(profileContext: equivalentContext, child: child),
      );

      expect(builds, 1);
    });

    testWidgets('read does not subscribe but reads the latest context', (
      tester,
    ) async {
      var builds = 0;
      late BuildContext childContext;

      final child = Builder(
        builder: (context) {
          builds += 1;
          childContext = context;
          ProfileContextScope.read(context);
          return const SizedBox.shrink();
        },
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: _ownerContext, child: child),
      );

      const otherContext = ProfileContext(
        profileId: _otherProfileId,
        role: ProfileMemberRole.viewer,
      );

      await tester.pumpWidget(
        ProfileContextScope(profileContext: otherContext, child: child),
      );

      expect(builds, 1);
      expect(ProfileContextScope.read(childContext), same(otherContext));
    });
  });
}
