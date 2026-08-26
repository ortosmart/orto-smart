import 'package:uuid/uuid.dart';

enum ProfileMemberRole {
  owner,
  worker,
  viewer;

  factory ProfileMemberRole.fromDatabase(String value) {
    return switch (value) {
      'owner' => ProfileMemberRole.owner,
      'worker' => ProfileMemberRole.worker,
      'viewer' => ProfileMemberRole.viewer,
      _ => throw const ProfileContextException(
        ProfileContextFailure.invalidMembership,
      ),
    };
  }
}

enum ProfileContextFailure {
  notAuthenticated,
  membershipNotFound,
  ambiguousMembership,
  invalidMembership,
}

class ProfileContextException implements Exception {
  final ProfileContextFailure failure;

  const ProfileContextException(this.failure);

  @override
  String toString() {
    return 'ProfileContextException(${failure.name})';
  }
}

class ProfileContext {
  static const _nilUuid = '00000000-0000-0000-0000-000000000000';

  final String profileId;
  final ProfileMemberRole role;

  const ProfileContext({required this.profileId, required this.role});

  bool get canWrite => role == ProfileMemberRole.owner;

  factory ProfileContext.fromMembershipMap(Map<String, dynamic> membership) {
    final profileId = membership['profile_id'];
    final role = membership['role'];
    final isEnabled = membership['is_enabled'];

    if (profileId is! String ||
        profileId == _nilUuid ||
        !Uuid.isValidUUID(fromString: profileId) ||
        role is! String ||
        isEnabled != true) {
      throw const ProfileContextException(
        ProfileContextFailure.invalidMembership,
      );
    }

    return ProfileContext(
      profileId: profileId,
      role: ProfileMemberRole.fromDatabase(role),
    );
  }
}
