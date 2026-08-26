import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_identity_service.dart';
import 'package:orto_app/core/identity/client_instance_id_store.dart';
import 'package:uuid/uuid.dart';

class _FakeClientInstanceIdPersistence implements ClientInstanceIdPersistence {
  String? value;
  int writeCount = 0;

  _FakeClientInstanceIdPersistence({this.value});

  @override
  Future<String?> read() async {
    return value;
  }

  @override
  Future<void> write(String value) async {
    this.value = value;
    writeCount++;
  }
}

void main() {
  group('ClientInstanceIdStore', () {
    test('creates and persists a client instance ID when missing', () async {
      final persistence = _FakeClientInstanceIdPersistence();
      final store = ClientInstanceIdStore(persistence);

      final clientInstanceId = await store.getOrCreate();

      expect(Uuid.isValidUUID(fromString: clientInstanceId), isTrue);
      expect(clientInstanceId, isNot('00000000-0000-0000-0000-000000000000'));
      expect(persistence.value, clientInstanceId);
      expect(persistence.writeCount, 1);
    });

    test('reuses an existing valid client instance ID', () async {
      const existingClientInstanceId = '11111111-1111-4111-8111-111111111111';

      final persistence = _FakeClientInstanceIdPersistence(
        value: existingClientInstanceId,
      );
      final store = ClientInstanceIdStore(persistence);

      final clientInstanceId = await store.getOrCreate();

      expect(clientInstanceId, existingClientInstanceId);
      expect(persistence.writeCount, 0);
    });

    test('replaces an invalid persisted value', () async {
      final persistence = _FakeClientInstanceIdPersistence(
        value: 'valore-corrotto',
      );
      final store = ClientInstanceIdStore(persistence);

      final clientInstanceId = await store.getOrCreate();

      expect(Uuid.isValidUUID(fromString: clientInstanceId), isTrue);
      expect(clientInstanceId, isNot('valore-corrotto'));
      expect(persistence.value, clientInstanceId);
      expect(persistence.writeCount, 1);
    });
  });
  test('replaces the nil UUID', () async {
    final persistence = _FakeClientInstanceIdPersistence(
      value: '00000000-0000-0000-0000-000000000000',
    );
    final store = ClientInstanceIdStore(persistence);

    final clientInstanceId = await store.getOrCreate();

    expect(clientInstanceId, isNot('00000000-0000-0000-0000-000000000000'));
    expect(persistence.value, clientInstanceId);
    expect(persistence.writeCount, 1);
  });

  group('AppIdentityService', () {
    test('keeps the client ID stable and creates a new session ID', () async {
      final persistence = _FakeClientInstanceIdPersistence();
      final store = ClientInstanceIdStore(persistence);
      final service = AppIdentityService(store);

      final firstIdentity = await service.createSessionIdentity();
      final secondIdentity = await service.createSessionIdentity();

      expect(firstIdentity.clientInstanceId, secondIdentity.clientInstanceId);
      expect(firstIdentity.sessionId, isNot(secondIdentity.sessionId));
      expect(firstIdentity.sessionId, isNot(firstIdentity.clientInstanceId));
      expect(Uuid.isValidUUID(fromString: firstIdentity.sessionId), isTrue);
      expect(Uuid.isValidUUID(fromString: secondIdentity.sessionId), isTrue);

      // Soltanto il client ID viene persistito.
      expect(persistence.value, firstIdentity.clientInstanceId);
      expect(persistence.writeCount, 1);
    });
  });
}
