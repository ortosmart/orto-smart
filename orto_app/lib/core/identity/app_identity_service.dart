import 'package:uuid/uuid.dart';

import 'app_session_identity.dart';
import 'client_instance_id_store.dart';

class AppIdentityService {
  static const _nilUuid = '00000000-0000-0000-0000-000000000000';

  final ClientInstanceIdStore _clientInstanceIdStore;
  final Uuid _uuid;

  AppIdentityService(this._clientInstanceIdStore, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  factory AppIdentityService.sharedPreferences() {
    return AppIdentityService(ClientInstanceIdStore.sharedPreferences());
  }

  Future<AppSessionIdentity> createSessionIdentity() async {
    final clientInstanceId = await _clientInstanceIdStore.getOrCreate();
    final sessionId = _uuid.v4();

    if (!_isUsableUuid(sessionId) || sessionId == clientInstanceId) {
      throw StateError('Unable to generate a valid app session UUID.');
    }

    return AppSessionIdentity(
      clientInstanceId: clientInstanceId,
      sessionId: sessionId,
    );
  }

  bool _isUsableUuid(String value) {
    return value != _nilUuid && Uuid.isValidUUID(fromString: value);
  }
}
