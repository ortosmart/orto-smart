import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _secondGardenId = '33333333-3333-4333-8333-333333333333';
const _otherProfileId = '44444444-4444-4444-8444-444444444444';

Map<String, dynamic> _gardenMap({
  String id = _gardenId,
  String profileId = _profileId,
  String name = 'Orto di prova',
  bool isActive = true,
}) {
  return {
    'id': id,
    'profile_id': profileId,
    'name': name,
    'description': 'Descrizione di prova',
    'is_active': isActive,
    'row_version': 3,
  };
}

void main() {
  late MockClient httpClient;
  late SupabaseClient supabase;
  late GardenRepository repository;
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

    repository = GardenRepository(supabase: supabase);
  });

  tearDown(() async {
    await supabase.dispose();
    httpClient.close();
  });

  group('GardenRepository HTTP', () {
    test(
      'builds a Profile-filtered query without selecting one Garden',
      () async {
        final gardens = await repository.getGardens(profileId: _profileId);

        expect(gardens, isEmpty);
        expect(requests, hasLength(1));

        final request = requests.single;

        expect(request.method, 'GET');
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'orto-smart-test.invalid');
        expect(request.url.path, '/rest/v1/gardens');
        expect(request.body, isEmpty);
        expect(request.url.queryParameters, {
          'select': 'id,profile_id,name,description,is_active,row_version',
          'profile_id': 'eq.$_profileId',
          'order': 'name.asc.nullslast,id.asc.nullslast',
        });

        expect(request.headers.containsKey('range'), isFalse);
      },
    );

    test('decodes Garden fields from the HTTP response', () async {
      responseBody = jsonEncode([_gardenMap()]);

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(requests, hasLength(1));
      expect(gardens, hasLength(1));

      final garden = gardens.single;

      expect(garden.id, _gardenId);
      expect(garden.profileId, _profileId);
      expect(garden.name, 'Orto di prova');
      expect(garden.description, 'Descrizione di prova');
      expect(garden.isActive, isTrue);
      expect(garden.rowVersion, 3);
    });

    test('returns multiple Gardens including a disabled Garden', () async {
      responseBody = jsonEncode([
        _gardenMap(name: 'Orto A'),
        _gardenMap(id: _secondGardenId, name: 'Orto B', isActive: false),
      ]);

      final gardens = await repository.getGardens(profileId: _profileId);

      expect(requests, hasLength(1));
      expect(gardens, hasLength(2));
      expect(gardens.map((garden) => garden.id), [_gardenId, _secondGardenId]);
      expect(gardens.first.isActive, isTrue);
      expect(gardens.last.isActive, isFalse);
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
        repository.getGardens(profileId: _profileId),
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

    test('rejects an HTTP response containing another Profile', () async {
      responseBody = jsonEncode([
        _gardenMap(),
        _gardenMap(id: _secondGardenId, profileId: _otherProfileId),
      ]);

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );

      expect(requests, hasLength(1));
    });

    test('rejects malformed Garden data from HTTP', () async {
      final map = _gardenMap()..remove('row_version');
      responseBody = jsonEncode([map]);

      await expectLater(
        repository.getGardens(profileId: _profileId),
        throwsA(isA<FormatException>()),
      );

      expect(requests, hasLength(1));
    });

    for (final invalidId in ['', '   ']) {
      test('rejects Profile ID "$invalidId" without HTTP requests', () async {
        await expectLater(
          repository.getGardens(profileId: invalidId),
          throwsA(isA<ArgumentError>()),
        );

        expect(requests, isEmpty);
      });
    }
  });
}
