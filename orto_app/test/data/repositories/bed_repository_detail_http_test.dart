import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _gardenId = '11111111-1111-4111-8111-111111111111';
const _bedId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _bedMap({bool isActive = true}) {
  return {
    'id': _bedId,
    'garden_id': _gardenId,
    'number': 1,
    'name': 'Aiuola di prova',
    'notes': null,
    'is_active': isActive,
    'row_version': 5,
    'bed_geometries': [
      {
        'id': _geometryId,
        'bed_id': _bedId,
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

  group('BedRepository detail HTTP', () {
    test(
      'builds the exact query and returns null for an empty response',
      () async {
        final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

        expect(bed, isNull);
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
          'garden_id': 'eq.$_gardenId',
          'id': 'eq.$_bedId',
          'bed_geometries.valid_to': 'is.null',
        });
      },
    );

    test('decodes a single bed and its geometry', () async {
      responseBody = jsonEncode([_bedMap()]);

      final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

      expect(requests, hasLength(1));
      expect(bed, isNotNull);

      final loaded = bed!;

      expect(loaded.id, _bedId);
      expect(loaded.gardenId, _gardenId);
      expect(loaded.isActive, isTrue);
      expect(loaded.rowVersion, 5);
      expect(loaded.geometry.id, _geometryId);
      expect(loaded.geometry.bedId, _bedId);
      expect(loaded.widthCm, 90);
      expect(loaded.lengthCm, 700);
      expect(loaded.geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(loaded.geometry.validTo, isNull);
      expect(loaded.geometry.rowVersion, 2);
    });

    test('returns a disabled bed without applying an active filter', () async {
      responseBody = jsonEncode([_bedMap(isActive: false)]);

      final bed = await repository.getBed(gardenId: _gardenId, bedId: _bedId);

      expect(requests, hasLength(1));
      expect(
        requests.single.url.queryParameters.containsKey('is_active'),
        isFalse,
      );
      expect(bed, isNotNull);
      expect(bed!.isActive, isFalse);
      expect(bed.id, _bedId);
    });

    test('rejects multiple rows instead of selecting the first', () async {
      responseBody = jsonEncode([_bedMap(), _bedMap()]);

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Expected a single Bed response',
          ),
        ),
      );

      expect(requests, hasLength(1));
    });

    test('propagates a server error without returning null', () async {
      responseStatus = 403;
      responseBody = jsonEncode({
        'code': '42501',
        'message': 'Synthetic permission error',
        'details': null,
        'hint': null,
      });

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
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

    test('rejects a response belonging to another garden', () async {
      final map = _bedMap()
        ..['garden_id'] = '44444444-4444-4444-8444-444444444444';

      responseBody = jsonEncode([map]);

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );

      expect(requests, hasLength(1));
    });

    test('rejects a bed without geometry instead of returning null', () async {
      final map = _bedMap()..['bed_geometries'] = <Map<String, dynamic>>[];

      responseBody = jsonEncode([map]);

      await expectLater(
        repository.getBed(gardenId: _gardenId, bedId: _bedId),
        throwsA(isA<FormatException>()),
      );

      expect(requests, hasLength(1));
    });
  });
}
