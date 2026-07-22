import '../data/models/crop.dart';
import '../data/models/planting.dart';
import '../data/models/rotation_result.dart';

/// Motore agronomico per la valutazione della rotazione colturale.
///
/// Il motore non accede direttamente a Supabase: riceve i dati già caricati
/// dal repository e applica esclusivamente le regole di valutazione.
///
/// Nella versione attuale la valutazione considera:
/// - la famiglia botanica della coltura candidata;
/// - l'ultima stagione in cui la stessa famiglia è stata coltivata;
/// - il numero minimo di stagioni di rotazione richiesto;
/// - le ripetizioni recenti della stessa famiglia.
///
/// Quando si modifica una piantagione esistente, il chiamante deve escludere
/// quella piantagione dalla cronologia passata al metodo [evaluate].
class RotationEngine {
  const RotationEngine._();

  static const int _defaultRotationSeasons = 3;

  /// Valuta l'idoneità di [candidateCrop] rispetto alla cronologia dell'aiuola.
  ///
  /// [history] contiene le piantagioni presenti e passate dell'aiuola.
  /// [cropsById] permette di risalire alla famiglia botanica di ogni
  /// piantagione storica.
  ///
  /// [referenceDate] rappresenta la stagione nella quale si vuole inserire
  /// la nuova coltura. Se non specificata, viene usata la data odierna.
  static RotationResult evaluate({
    required Crop candidateCrop,
    required List<Planting> history,
    required Map<String, Crop> cropsById,
    DateTime? referenceDate,
  }) {
    final candidateFamily = _normalize(candidateCrop.botanicalFamily);

    if (candidateFamily == null) {
      return RotationResult.unknown(
        reason:
            'La famiglia botanica di ${candidateCrop.name} non è disponibile.',
      );
    }

    final requiredSeasons =
        candidateCrop.rotationSeasons ?? _defaultRotationSeasons;

    if (requiredSeasons <= 0) {
      return RotationResult.unknown(
        reason:
            'Il numero di stagioni di rotazione di ${candidateCrop.name} non è valido.',
      );
    }

    final evaluationDate = referenceDate ?? DateTime.now();

    final sameFamilyPlantings = history.where((planting) {
      final historicalCrop = cropsById[planting.cropId];
      final historicalFamily = _normalize(historicalCrop?.botanicalFamily);

      if (historicalFamily == null) {
        return false;
      }

      return historicalFamily == candidateFamily &&
          !planting.sowingDate.isAfter(evaluationDate);
    }).toList()
      ..sort((a, b) => b.sowingDate.compareTo(a.sowingDate));

    if (sameFamilyPlantings.isEmpty) {
      return RotationResult.fromScore(
        score: 100,
        reasons: [
          'Nessuna coltura della famiglia ${candidateCrop.botanicalFamily} '
              'risulta registrata in questa aiuola.',
          'La rotazione è favorevole per ${candidateCrop.name}.',
        ],
        requiredRotationSeasons: requiredSeasons,
      );
    }

    final latestPlanting = sameFamilyPlantings.first;
    final latestCrop = cropsById[latestPlanting.cropId];

    final seasonsSinceSameFamily = _completedSeasonsBetween(
      latestPlanting.sowingDate,
      evaluationDate,
    );

    final reasons = <String>[
      'L’ultima coltura della famiglia ${candidateCrop.botanicalFamily} '
          'registrata in questa aiuola è ${latestCrop?.name ?? 'una coltura non identificata'}, '
          'seminata nel ${latestPlanting.sowingDate.year}.',
    ];

    int score;

    if (seasonsSinceSameFamily >= requiredSeasons) {
      score = 95;

      reasons.add(
        'Sono trascorse $seasonsSinceSameFamily stagioni: '
        'il minimo consigliato è $requiredSeasons.',
      );
      reasons.add('La rotazione della famiglia botanica è rispettata.');
    } else {
      final missingSeasons = requiredSeasons - seasonsSinceSameFamily;

      score = _scoreForIncompleteRotation(
        seasonsElapsed: seasonsSinceSameFamily,
        requiredSeasons: requiredSeasons,
      );

      if (seasonsSinceSameFamily == 0) {
        reasons.add(
          'La stessa famiglia botanica è già presente nella stagione corrente.',
        );
      } else {
        reasons.add(
          'Sono trascorse solo $seasonsSinceSameFamily stagioni '
          'su $requiredSeasons consigliate.',
        );
      }

      reasons.add(
        missingSeasons == 1
            ? 'È consigliabile attendere ancora 1 stagione.'
            : 'È consigliabile attendere ancora $missingSeasons stagioni.',
      );
    }

    final recentRepeats = sameFamilyPlantings.where((planting) {
      final elapsed = _completedSeasonsBetween(
        planting.sowingDate,
        evaluationDate,
      );

      return elapsed < requiredSeasons;
    }).length;

    if (recentRepeats > 1) {
      final repeatPenalty = ((recentRepeats - 1) * 5).clamp(0, 15);
      score -= repeatPenalty;

      reasons.add(
        'La stessa famiglia botanica compare $recentRepeats volte '
        'nel periodo di rotazione considerato.',
      );
    }

    return RotationResult.fromScore(
      score: score.clamp(0, 100),
      reasons: reasons,
      seasonsSinceSameFamily: seasonsSinceSameFamily,
      requiredRotationSeasons: requiredSeasons,
    );
  }

  /// Valuta più colture candidate usando la stessa cronologia.
  ///
  /// Il risultato è ordinato dal punteggio più alto al più basso.
  static List<CropRotationEvaluation> evaluateCandidates({
    required List<Crop> candidateCrops,
    required List<Planting> history,
    required Map<String, Crop> cropsById,
    DateTime? referenceDate,
  }) {
    final evaluations = candidateCrops.map((crop) {
      final result = evaluate(
        candidateCrop: crop,
        history: history,
        cropsById: cropsById,
        referenceDate: referenceDate,
      );

      return CropRotationEvaluation(
        crop: crop,
        result: result,
      );
    }).toList()
      ..sort((a, b) {
        final scoreComparison = b.result.score.compareTo(a.result.score);

        if (scoreComparison != 0) {
          return scoreComparison;
        }

        return a.crop.name.toLowerCase().compareTo(
              b.crop.name.toLowerCase(),
            );
      });

    return List.unmodifiable(evaluations);
  }

  static int _scoreForIncompleteRotation({
    required int seasonsElapsed,
    required int requiredSeasons,
  }) {
    if (seasonsElapsed <= 0) {
      return 15;
    }

    final progress = seasonsElapsed / requiredSeasons;

    if (progress >= 0.75) {
      return 65;
    }

    if (progress >= 0.50) {
      return 50;
    }

    if (progress >= 0.25) {
      return 35;
    }

    return 20;
  }

  /// Calcola il numero di stagioni annuali completate tra due date.
  static int _completedSeasonsBetween(
    DateTime plantingDate,
    DateTime referenceDate,
  ) {
    final difference = referenceDate.year - plantingDate.year;
    return difference < 0 ? 0 : difference;
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim().toLowerCase();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

/// Associa una coltura al risultato prodotto dal Rotation Engine.
class CropRotationEvaluation {
  final Crop crop;
  final RotationResult result;

  const CropRotationEvaluation({
    required this.crop,
    required this.result,
  });
}
