import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/profile/profile_context.dart';

typedef CurrentAuthUserIdProvider = String? Function();

typedef ActiveProfileMembershipLoader =
    Future<List<Map<String, dynamic>>> Function(String authUserId);

class ProfileContextRepository {
  final CurrentAuthUserIdProvider _currentAuthUserId;
  final ActiveProfileMembershipLoader _loadActiveMemberships;

  factory ProfileContextRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return ProfileContextRepository.withProviders(
      () => client.auth.currentUser?.id,
      (authUserId) async {
        final response = await client
            .from('profile_memberships')
            .select('profile_id, role, is_enabled')
            .eq('auth_user_id', authUserId)
            .eq('is_enabled', true)
            .order('created_at');

        return response
            .map((membership) => Map<String, dynamic>.from(membership))
            .toList(growable: false);
      },
    );
  }

  ProfileContextRepository.withProviders(
    this._currentAuthUserId,
    this._loadActiveMemberships,
  );
  Future<List<ProfileContext>> loadAvailableProfileContexts() async {
    final authUserId = _currentAuthUserId();

    if (authUserId == null) {
      throw const ProfileContextException(
        ProfileContextFailure.notAuthenticated,
      );
    }

    final memberships = await _loadActiveMemberships(authUserId);

    return memberships
        .map(ProfileContext.fromMembershipMap)
        .toList(growable: false);
  }

  Future<ProfileContext> resolveSingleProfileContext() async {
    final contexts = await loadAvailableProfileContexts();

    if (contexts.isEmpty) {
      throw const ProfileContextException(
        ProfileContextFailure.membershipNotFound,
      );
    }

    if (contexts.length > 1) {
      throw const ProfileContextException(
        ProfileContextFailure.ambiguousMembership,
      );
    }

    return contexts.single;
  }
}
