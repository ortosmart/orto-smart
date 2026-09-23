import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/catalog_capabilities.dart';
import 'package:orto_app/data/repositories/catalog_authority_repository.dart';

class _RpcRecorder {
  dynamic response;
  String? functionName;
  Map<String, dynamic>? parameters;

  Future<dynamic> call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    this.functionName = functionName;
    this.parameters = parameters;
    return response;
  }
}

void main() {
  test('maps current catalog capabilities', () async {
    final rpc = _RpcRecorder()
      ..response = {
        'status': 'ok',
        'can_manage_identity': true,
        'can_ingest': false,
        'can_review': true,
        'can_publish': false,
        'row_version': 3,
      };
    final repository = CatalogAuthorityRepository.withInvoker(rpc.call);

    final result = await repository.getMyCapabilities();
    expect(rpc.functionName, 'get_my_catalog_capabilities');
    expect(rpc.parameters, isEmpty);
    expect(result.canManageIdentity, isTrue);
    expect(result.canIngest, isFalse);
    expect(result.canReview, isTrue);
    expect(result.canPublish, isFalse);
    expect(result.rowVersion, 3);
  });

  for (final entry in {
    'claimed': ClaimInitialCatalogAuthorityStatus.claimed,
    'already_initialized':
        ClaimInitialCatalogAuthorityStatus.alreadyInitialized,
    'already_claimed': ClaimInitialCatalogAuthorityStatus.alreadyClaimed,
    'forbidden': ClaimInitialCatalogAuthorityStatus.forbidden,
  }.entries) {
    test('maps claim status ${entry.key}', () async {
      final rpc = _RpcRecorder()..response = {'status': entry.key};
      final repository = CatalogAuthorityRepository.withInvoker(rpc.call);

      expect(await repository.claimInitialAuthority(), entry.value);
      expect(rpc.functionName, 'claim_initial_catalog_authority');
      expect(rpc.parameters, isEmpty);
    });
  }

  test('rejects an unknown capability protocol response', () async {
    final rpc = _RpcRecorder()..response = {'status': 'forbidden'};
    final repository = CatalogAuthorityRepository.withInvoker(rpc.call);
    await expectLater(repository.getMyCapabilities(), throwsFormatException);
  });
}
