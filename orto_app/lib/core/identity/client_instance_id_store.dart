import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

abstract interface class ClientInstanceIdPersistence {
  Future<String?> read();

  Future<void> write(String value);
}

class SharedPreferencesClientInstanceIdPersistence
    implements ClientInstanceIdPersistence {
  static const _storageKey = 'orto_smart.client_instance_id.v1';

  final SharedPreferencesAsync _preferences;

  SharedPreferencesClientInstanceIdPersistence({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<String?> read() {
    return _preferences.getString(_storageKey);
  }

  @override
  Future<void> write(String value) {
    return _preferences.setString(_storageKey, value);
  }
}

class ClientInstanceIdStore {
  static const _nilUuid = '00000000-0000-0000-0000-000000000000';

  final ClientInstanceIdPersistence _persistence;
  final Uuid _uuid;

  ClientInstanceIdStore(this._persistence, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  factory ClientInstanceIdStore.sharedPreferences() {
    return ClientInstanceIdStore(
      SharedPreferencesClientInstanceIdPersistence(),
    );
  }

  Future<String> getOrCreate() async {
    final storedValue = await _persistence.read();

    if (_isUsableUuid(storedValue)) {
      return storedValue!;
    }

    final generatedValue = _uuid.v4();

    if (!_isUsableUuid(generatedValue)) {
      throw StateError('Unable to generate a valid client instance UUID.');
    }

    await _persistence.write(generatedValue);

    return generatedValue;
  }

  bool _isUsableUuid(String? value) {
    return value != null &&
        value != _nilUuid &&
        Uuid.isValidUUID(fromString: value);
  }
}
