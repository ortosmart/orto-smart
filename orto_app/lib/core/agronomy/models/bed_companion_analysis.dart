import 'companion_pair_analysis.dart';

class BedCompanionAnalysis {
  final List<CompanionPairAnalysis> pairs;

  const BedCompanionAnalysis({required this.pairs});

  int get totalPairs => pairs.length;

  int get compatiblePairs => pairs.where((p) => p.result.compatible).length;

  int get incompatiblePairs => pairs.where((p) => !p.result.compatible).length;

  bool get hasIncompatibilities => incompatiblePairs > 0;
}
