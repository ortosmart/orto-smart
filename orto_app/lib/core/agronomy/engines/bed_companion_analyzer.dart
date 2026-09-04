import '../models/bed_companion_analysis.dart';
import '../models/companion_pair_analysis.dart';
import 'companion_engine.dart';

class BedCompanionAnalyzer {
  static BedCompanionAnalysis analyze(List<String> cropIds) {
    final pairs = <CompanionPairAnalysis>[];

    for (var i = 0; i < cropIds.length; i++) {
      for (var j = i + 1; j < cropIds.length; j++) {
        final result = CompanionEngine.analyze(cropIds[i], cropIds[j]);

        pairs.add(
          CompanionPairAnalysis(
            cropAId: cropIds[i],
            cropBId: cropIds[j],
            result: result,
          ),
        );
      }
    }

    return BedCompanionAnalysis(pairs: pairs);
  }
}
