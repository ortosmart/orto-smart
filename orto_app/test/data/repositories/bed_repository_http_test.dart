import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/bed_write_result.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Map<String, dynamic> _bedMap() {
  return {
    'id': '11111111-1111-4111-8111-111111111111',
    'garden_id': '22222222-2222-4222-8222-222222222222',
    'number': 1,
    'name': 'Aiuola di prova',
    'notes': null,
    'is_active': true,
    'row_version': 3,
    'bed_geometries': [
      {
        'id': '33333333-3333-4333-8333-333333333333',
        'bed_id': '11111111-1111-4111-8111-111111111111',
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'row_version': 2,
      },
    ],
  };
}

void main() {
  late MockClient httpClient;
  late SupabaseClient supabase;
  late BedRepository repository;
  late List<http.Request> requests;
  late String responseBody;
  late int responseStatus;

  setUp(() {
    requests = [];
    responseBody = '[]';
    responseStatus = 200;

    httpClient = MockClient((request) async {
      requests.add(request);

      return http.Response(
        responseBody,
        responseStatus,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });

    supabase = SupabaseClient(
      'https://orto-smart-test.invalid',
      'chiave-esclusivamente-fittizia',
      httpClient: httpClient,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

    repository = BedRepository(supabase: supabase);
  });

  tearDown(() async {
    await supabase.dispose();
    httpClient.close();
  });

  group('BedRepository HTTP', () {
    test('builds the expected read query', () async {
      final beds = await repository.getBeds(
        gardenId: '22222222-2222-4222-8222-222222222222',
      );

      expect(beds, isEmpty);
      expect(requests, hasLength(1));

      final request = requests.single;

      expect(request.method, 'GET');
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'orto-smart-test.invalid');
      expect(request.url.path, '/rest/v1/beds');
      expect(request.body, isEmpty);

      expect(request.url.queryParameters, {
        'select':
            'id,garden_id,number,name,notes,is_active,row_version,'
            'bed_geometries('
            'id,bed_id,width_cm,length_cm,valid_from,valid_to,row_version)',
        'garden_id': 'eq.22222222-2222-4222-8222-222222222222',
        'is_active': 'eq.true',
        'bed_geometries.valid_to': 'is.null',
        'order': 'number.asc.nullslast',
      });
    });

    test('decodes the HTTP response into Bed and BedGeometry', () async {
      responseBody = jsonEncode([_bedMap()]);

      final beds = await repository.getBeds(
        gardenId: '22222222-2222-4222-8222-222222222222',
      );

      expect(requests, hasLength(1));
      expect(beds, hasLength(1));

      final bed = beds.single;

      expect(bed.id, '11111111-1111-4111-8111-111111111111');
      expect(bed.code, 'A01');
      expect(bed.name, 'Aiuola di prova');
      expect(bed.isActive, isTrue);
      expect(bed.rowVersion, 3);
      expect(bed.geometry.id, '33333333-3333-4333-8333-333333333333');
      expect(bed.geometry.bedId, bed.id);
      expect(bed.widthCm, 90);
      expect(bed.lengthCm, 700);
      expect(bed.geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(bed.geometry.validTo, isNull);
      expect(bed.geometry.rowVersion, 2);
    });

    test('propagates a server error without returning an empty list', () async {
      responseStatus = 403;
      responseBody = jsonEncode({
        'code': '42501',
        'message': 'Synthetic permission error',
        'details': null,
        'hint': null,
      });

      await expectLater(
        repository.getBeds(gardenId: '22222222-2222-4222-8222-222222222222'),
        throwsA(
          isA<PostgrestException>().having(
            (error) => error.code,
            'code',
            '42501',
          ),
        ),
      );

      expect(requests, hasLength(1));
    });

    test('does not silently omit a bed without geometry', () async {
      final map = _bedMap()..['bed_geometries'] = <Map<String, dynamic>>[];

      responseBody = jsonEncode([map]);

      await expectLater(
        repository.getBeds(gardenId: '22222222-2222-4222-8222-222222222222'),
        throwsA(isA<FormatException>()),
      );

      expect(requests, hasLength(1));
    });
  });
  group('BedRepository write HTTP', () {
    const profileId = '44444444-4444-4444-8444-444444444444';
    const gardenId = '22222222-2222-4222-8222-222222222222';
    const bedId = '11111111-1111-4111-8111-111111111111';
    const geometryId = '33333333-3333-4333-8333-333333333333';
    const clientId = '55555555-5555-4555-8555-555555555555';
    const sessionId = '66666666-6666-4666-8666-666666666666';
    const fakeToken = 'token-esclusivamente-fittizio';

    setUp(() {
      repository = BedRepository(
        supabase: supabase,
        requireLeaseForWrite: () => ProfileEditLockLease(
          profileId: profileId,
          identity: const AppSessionIdentity(
            clientInstanceId: clientId,
            sessionId: sessionId,
          ),
          lockToken: fakeToken,
          expiresAt: DateTime.utc(2099, 1, 1),
          rowVersion: 1,
        ),
      );

      responseBody = jsonEncode({'status': 'write_forbidden'});
    });

    void expectRpcRequest(
      String functionName,
      Map<String, dynamic> domainParameters,
    ) {
      expect(requests, hasLength(1));

      final request = requests.single;

      expect(request.method, 'POST');
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'orto-smart-test.invalid');
      expect(request.url.path, '/rest/v1/rpc/$functionName');
      expect(request.url.queryParameters, isEmpty);
      expect(request.headers['content-type'], startsWith('application/json'));
      expect(jsonDecode(request.body), {
        'target_profile_id': profileId,
        'target_client_id': clientId,
        'target_session_id': sessionId,
        'lock_token': fakeToken,
        ...domainParameters,
      });
    }

    test('posts create_bed with explicit null optional values', () async {
      final result = await repository.createBed(
        gardenId: gardenId,
        number: 1,
        widthCm: 90,
        lengthCm: 700,
      );

      expect(result, isA<CreateBedWriteForbidden>());
      expectRpcRequest('create_bed', {
        'target_garden_id': gardenId,
        'bed_number': 1,
        'bed_name': null,
        'bed_notes': null,
        'geometry_width_cm': 90,
        'geometry_length_cm': 700,
        'geometry_valid_from': null,
      });
    });

    test('posts update_bed with version and descriptive fields', () async {
      final result = await repository.updateBed(
        bedId: bedId,
        expectedRowVersion: 7,
        number: 2,
        name: 'Aiuola tè e aromatiche',
        notes: 'Misure "verificate"\nSeconda riga',
      );

      expect(result, isA<UpdateBedWriteForbidden>());
      expectRpcRequest('update_bed', {
        'target_bed_id': bedId,
        'expected_row_version': 7,
        'bed_number': 2,
        'bed_name': 'Aiuola tè e aromatiche',
        'bed_notes': 'Misure "verificate"\nSeconda riga',
      });
    });

    test('posts set_bed_active with boolean false', () async {
      final result = await repository.setBedActive(
        bedId: bedId,
        expectedRowVersion: 7,
        isActive: false,
      );

      expect(result, isA<SetBedActiveWriteForbidden>());
      expectRpcRequest('set_bed_active', {
        'target_bed_id': bedId,
        'expected_row_version': 7,
        'bed_is_active': false,
      });
    });

    test('posts change_bed_geometry with a civil date', () async {
      final result = await repository.changeBedGeometry(
        bedId: bedId,
        expectedRowVersion: 7,
        widthCm: 100,
        lengthCm: 700,
        validFrom: DateTime(2026, 6, 1, 15, 30),
      );

      expect(result, isA<ChangeBedGeometryWriteForbidden>());
      expectRpcRequest('change_bed_geometry', {
        'target_bed_id': bedId,
        'expected_row_version': 7,
        'geometry_width_cm': 100,
        'geometry_length_cm': 700,
        'geometry_valid_from': '2026-06-01',
      });
    });

    test('posts correct_bed_geometry with target and reason', () async {
      final result = await repository.correctBedGeometry(
        bedId: bedId,
        geometryId: geometryId,
        expectedRowVersion: 7,
        widthCm: 110,
        lengthCm: 700,
        validFrom: DateTime(2026, 5, 1),
        reason: 'Rettifica: misura iniziale errata.',
      );

      expect(result, isA<CorrectBedGeometryWriteForbidden>());
      expectRpcRequest('correct_bed_geometry', {
        'target_bed_id': bedId,
        'target_geometry_id': geometryId,
        'expected_row_version': 7,
        'geometry_width_cm': 110,
        'geometry_length_cm': 700,
        'geometry_valid_from': '2026-05-01',
        'correction_reason': 'Rettifica: misura iniziale errata.',
      });
    });
  });
}
