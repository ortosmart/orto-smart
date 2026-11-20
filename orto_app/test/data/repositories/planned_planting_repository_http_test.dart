import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late MockClient httpClient;
  late SupabaseClient supabase;
  late PlannedPlantingRepository repository;
  late List<http.Request> requests;

  const seasonId = '55555555-5555-4555-8555-555555555555';

  setUp(() {
    requests = [];

    httpClient = MockClient((request) async {
      requests.add(request);

      return http.Response(
        '[]',
        200,
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

    repository = PlannedPlantingRepository.readOnly(supabase: supabase);
  });

  tearDown(() async {
    await supabase.dispose();
    httpClient.close();
  });

  group('PlannedPlantingRepository.readOnly HTTP', () {
    test('legge le pianificazioni della stagione senza RPC', () async {
      final plantings = await repository.getPlannedPlantingsBySeason(seasonId);

      expect(plantings, isEmpty);
      expect(requests, hasLength(1));

      final request = requests.single;

      expect(request.method, 'GET');
      expect(request.url.scheme, 'https');
      expect(request.url.host, 'orto-smart-test.invalid');
      expect(request.url.path, '/rest/v1/planned_plantings');
      expect(request.body, isEmpty);

      expect(request.url.queryParameters['season_id'], 'eq.$seasonId');
      expect(
        request.url.queryParameters['order'],
        'planned_start_date.asc.nullslast,'
        'start_position_cm.asc.nullslast,id.asc.nullslast',
      );

      final selectedColumns = request.url.queryParameters['select'];
      expect(selectedColumns, isNotNull);
      expect(selectedColumns!.split(','), contains('id'));
      expect(selectedColumns.split(','), contains('season_id'));
      expect(selectedColumns.split(','), contains('status'));
      expect(selectedColumns.split(','), contains('row_version'));
    });

    test('rifiuta la scrittura senza inviare richieste HTTP', () async {
      await expectLater(
        repository.createPlannedPlanting(
          gardenId: '44444444-4444-4444-8444-444444444444',
          seasonId: seasonId,
          bedId: '66666666-6666-4666-8666-666666666666',
          cropId: '77777777-7777-4777-8777-777777777777',
          startMethod: 'direct_rows',
          startDate: DateTime.utc(2026, 11, 18),
          endDate: DateTime.utc(2027, 2, 18),
          startPositionCm: 0,
          lengthCm: 100,
          occupiedWidthCm: 40,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(requests, isEmpty);
    });
  });
}
