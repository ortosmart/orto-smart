import '../identity/app_session_identity.dart';

class ProfileEditLockProtocolException implements Exception {
  const ProfileEditLockProtocolException();

  @override
  String toString() {
    return 'ProfileEditLockProtocolException';
  }
}

class ProfileEditLockLease {
  final String profileId;
  final AppSessionIdentity identity;
  final String lockToken;
  final DateTime expiresAt;
  final int rowVersion;

  const ProfileEditLockLease({
    required this.profileId,
    required this.identity,
    required this.lockToken,
    required this.expiresAt,
    required this.rowVersion,
  });

  ProfileEditLockLease renewed({
    required DateTime expiresAt,
    required int rowVersion,
  }) {
    return ProfileEditLockLease(
      profileId: profileId,
      identity: identity,
      lockToken: lockToken,
      expiresAt: expiresAt,
      rowVersion: rowVersion,
    );
  }
}

sealed class AcquireProfileEditLockResult {
  const AcquireProfileEditLockResult();
}

final class ProfileEditLockAcquired extends AcquireProfileEditLockResult {
  final ProfileEditLockLease lease;

  const ProfileEditLockAcquired(this.lease);
}

final class ProfileEditLockAlreadyHeld extends AcquireProfileEditLockResult {
  const ProfileEditLockAlreadyHeld();
}

final class ProfileEditLockBusy extends AcquireProfileEditLockResult {
  const ProfileEditLockBusy();
}

final class ProfileEditLockAcquireForbidden
    extends AcquireProfileEditLockResult {
  const ProfileEditLockAcquireForbidden();
}

final class ProfileEditLockAcquireInvalidInput
    extends AcquireProfileEditLockResult {
  const ProfileEditLockAcquireInvalidInput();
}

sealed class HeartbeatProfileEditLockResult {
  const HeartbeatProfileEditLockResult();
}

final class ProfileEditLockRenewed extends HeartbeatProfileEditLockResult {
  final ProfileEditLockLease lease;

  const ProfileEditLockRenewed(this.lease);
}

final class ProfileEditLockHeartbeatNotHolder
    extends HeartbeatProfileEditLockResult {
  const ProfileEditLockHeartbeatNotHolder();
}

final class ProfileEditLockHeartbeatForbidden
    extends HeartbeatProfileEditLockResult {
  const ProfileEditLockHeartbeatForbidden();
}

sealed class ReleaseProfileEditLockResult {
  const ReleaseProfileEditLockResult();
}

final class ProfileEditLockReleased extends ReleaseProfileEditLockResult {
  const ProfileEditLockReleased();
}

final class ProfileEditLockReleaseNotHolder
    extends ReleaseProfileEditLockResult {
  const ProfileEditLockReleaseNotHolder();
}

final class ProfileEditLockTransferPending
    extends ReleaseProfileEditLockResult {
  const ProfileEditLockTransferPending();
}

final class ProfileEditLockReleaseForbidden
    extends ReleaseProfileEditLockResult {
  const ProfileEditLockReleaseForbidden();
}
