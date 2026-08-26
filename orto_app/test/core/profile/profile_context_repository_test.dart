import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/data/repositories/profile_context_repository.dart';

const _authUserId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _profileId = '11111111-1111-4111-8111-111111111111';
const _secondProfileId = '22222222-2222-4222-8222-222222222222';

Map<String, dynamic> _membership({
  String profileId = _profileId,
  String role = 'owner',
  bool isEnabled = true,
}) {
  return {'profile_id': profileId, 'role': role, 'is_enabled': isEnabled};
}

ProfileContextRepository _repository({
  String? authUserId = _authUserId,
  List<Map<String, dynamic>> memberships = const [],
}) {
  return ProfileContextRepository.withProviders(() => authUserId, (
    requestedAuthUserId,
  ) async {
    expect(requestedAuthUserId, _authUserId);
    return memberships;
  });
}

void main() {
  group('ProfileContext', () {
    test('owner can write', () {
      final context = ProfileContext.fromMembershipMap(
        _membership(role: 'owner'),
      );

      expect(context.profileId, _profileId);
      expect(context.role, ProfileMemberRole.owner);
      expect(context.canWrite, isTrue);
    });

    test('worker is read only', () {
      final context = ProfileContext.fromMembershipMap(
        _membership(role: 'worker'),
      );

      expect(context.role, ProfileMemberRole.worker);
      expect(context.canWrite, isFalse);
    });

    test('viewer is read only', () {
      final context = ProfileContext.fromMembershipMap(
        _membership(role: 'viewer'),
      );

      expect(context.role, ProfileMemberRole.viewer);
      expect(context.canWrite, isFalse);
    });
  });
  group('ProfileContextRepository', () {
    test('loads all available active Profile contexts', () async {
      final repository = _repository(
        memberships: [
          _membership(),
          _membership(profileId: _secondProfileId, role: 'viewer'),
        ],
      );

      final contexts = await repository.loadAvailableProfileContexts();

      expect(contexts, hasLength(2));
      expect(contexts[0].profileId, _profileId);
      expect(contexts[0].role, ProfileMemberRole.owner);
      expect(contexts[1].profileId, _secondProfileId);
      expect(contexts[1].role, ProfileMemberRole.viewer);
    });

    test('resolves the only active Profile in V1', () async {
      final repository = _repository(memberships: [_membership()]);

      final context = await repository.resolveSingleProfileContext();

      expect(context.profileId, _profileId);
      expect(context.role, ProfileMemberRole.owner);
      expect(context.canWrite, isTrue);
    });
    Matcher hasFailure(ProfileContextFailure failure) {
      return isA<ProfileContextException>().having(
        (error) => error.failure,
        'failure',
        failure,
      );
    }

    test('rejects an unauthenticated user', () async {
      final repository = _repository(authUserId: null);

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.notAuthenticated)),
      );
    });

    test('rejects a missing active membership', () async {
      final repository = _repository();

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.membershipNotFound)),
      );
    });

    test('rejects multiple active memberships in V1', () async {
      final repository = _repository(
        memberships: [
          _membership(),
          _membership(profileId: _secondProfileId),
        ],
      );

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.ambiguousMembership)),
      );
    });

    test('rejects an unknown role', () async {
      final repository = _repository(
        memberships: [_membership(role: 'unknown')],
      );

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.invalidMembership)),
      );
    });

    test('rejects a disabled membership returned unexpectedly', () async {
      final repository = _repository(
        memberships: [_membership(isEnabled: false)],
      );

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.invalidMembership)),
      );
    });

    test('rejects an invalid Profile ID', () async {
      final repository = _repository(
        memberships: [_membership(profileId: 'profile-non-valido')],
      );

      await expectLater(
        repository.resolveSingleProfileContext(),
        throwsA(hasFailure(ProfileContextFailure.invalidMembership)),
      );
    });
  });
}
