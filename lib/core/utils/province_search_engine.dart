// core/utils/province_search_engine.dart
import 'package:al_faw_zakho/data/models/candidate_model.dart';

class ProvinceSearchEngine {
  late Map<String, List<CandidateModel>> _provinceCandidates;
  late Map<String, Set<String>> _searchIndex;

  void initialize(Map<String, List<CandidateModel>> provinceCandidates) {
    _provinceCandidates = provinceCandidates;
    _buildSearchIndex();
  }

  void _buildSearchIndex() {
    _searchIndex = {};

    _provinceCandidates.forEach((province, candidates) {
      // إضافة المحافظة
      _addToIndex(province.toLowerCase(), province);

      // إضافة المرشحين
      for (final candidate in candidates) {
        _addCandidateToIndex(candidate, province);
      }
    });
  }

  void _addToIndex(String key, String province) {
    _searchIndex.putIfAbsent(key, () => <String>{});
    _searchIndex[key]!.add(province);
  }

  void _addCandidateToIndex(CandidateModel candidate, String province) {
    void addField(String? field) {
      if (field != null && field.isNotEmpty) {
        _addToIndex(field.toLowerCase(), province);
      }
    }

    addField(candidate.nameAr);
    addField(candidate.nameEn);
    addField(candidate.nicknameAr);
    addField(candidate.nicknameEn);
  }

  SearchResult search(String query) {
    if (query.isEmpty) {
      return SearchResult(
        matchedProvinces: _provinceCandidates.keys.toList(),
        hasExactMatch: false,
      );
    }

    final lowerQuery = query.toLowerCase();
    final matchedProvinces = <String>{};
    bool hasExactMatch = false;

    // البحث في الفهرس أولاً (سريع)
    _searchIndex.forEach((key, provinces) {
      if (key.contains(lowerQuery)) {
        matchedProvinces.addAll(provinces);
        if (key == lowerQuery) {
          hasExactMatch = true;
        }
      }
    });

    return SearchResult(
      matchedProvinces: matchedProvinces.toList()..sort(),
      hasExactMatch: hasExactMatch,
    );
  }
}

class SearchResult {
  final List<String> matchedProvinces;
  final bool hasExactMatch;

  SearchResult({
    required this.matchedProvinces,
    required this.hasExactMatch,
  });
}
