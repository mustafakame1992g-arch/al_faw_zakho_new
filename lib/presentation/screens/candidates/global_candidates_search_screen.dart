// lib/presentation/screens/candidates/global_candidates_search_screen.dart

import 'dart:async' show Timer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/presentation/screens/candidates/candidate_details_screen.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'dart:developer' as developer;
import 'package:al_faw_zakho/core/localization/app_localizations.dart';

class GlobalCandidatesSearchScreen extends StatefulWidget {
  const GlobalCandidatesSearchScreen({super.key});

  @override
  State<GlobalCandidatesSearchScreen> createState() =>
      _GlobalCandidatesSearchScreenState();
}

class _GlobalCandidatesSearchScreenState
    extends State<GlobalCandidatesSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer; // 🆕 مؤقت Debouncing

  List<CandidateModel> _allCandidates = [];
  List<CandidateModel> _filteredCandidates = [];
  bool _isLoading = true;
  bool _hasSearched = false; // 🆕 تتبع ما إذا تم البحث

  @override
  void initState() {
    super.initState();
    _loadAllCandidates();
    _searchController.addListener(_onSearchChanged);
    AnalyticsService.trackEvent('global_search_opened');
  }

  Future<void> _loadAllCandidates() async {
    try {
      final List<dynamic> rawCandidates =
          List<dynamic>.from(LocalDatabase.getCandidates());
      final List<CandidateModel> all = [];

      for (final e in rawCandidates) {
        CandidateModel? c;
        if (e is CandidateModel) {
          c = e;
        } else if (e is Map<String, dynamic>) {
          c = CandidateModel.fromJson(e);
        } else if (e is Map) {
          c = CandidateModel.fromJson(Map<String, dynamic>.from(e));
        }
        if (c != null) all.add(c);
      }

      setState(() {
        _allCandidates = all;
        _filteredCandidates = [];
        _isLoading = false;
      });

      developer.log('✅ Loaded ${_allCandidates.length} total candidates',
          name: 'GLOBAL_SEARCH');
    } catch (e, stack) {
      AnalyticsService.trackError('global_search_load', e, stack);
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    // 🆕 إلغاء المؤقت السابق إن وجد
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // 🆕 إنشاء مؤقت جديد
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();

      setState(() {
        _hasSearched = query.isNotEmpty;
      });

      if (query.isEmpty) {
        setState(() => _filteredCandidates = []);
        return;
      }

      final results = _allCandidates.where((candidate) {
        final nameAr = candidate.nameAr.toLowerCase();
        final nameEn = candidate.nameEn.toLowerCase();
        final nickAr = candidate.nicknameAr.toLowerCase();
        final nickEn = candidate.nicknameEn.toLowerCase();
        final province = candidate.province.toLowerCase();

        return nameAr.contains(query) ||
            nameEn.contains(query) ||
            nickAr.contains(query) ||
            nickEn.contains(query) ||
            province.contains(query);
      }).toList();

      setState(() => _filteredCandidates = results);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredCandidates = [];
      _hasSearched = false; // 🆕 إعادة تعيين حالة البحث
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // 🆕 تنظيف المؤقت
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.watch<LanguageProvider>().languageCode;
    final isArabic = languageCode == 'ar' || languageCode.startsWith('ar');

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).translate('search_candidates')),
        centerTitle: true,
        elevation: 2,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              //tooltip: isArabic ? 'مسح البحث' : 'Clear search',
              tooltip: AppLocalizations.of(context).translate('clear_search'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchField(context, isArabic),
                Expanded(child: _buildResultsList(context, isArabic)),
              ],
            ),
    );
  }

  Widget _buildSearchField(BuildContext context, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: _searchController,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: isArabic
              ? 'ابحث عن اسم مرشح أو محافظة...'
              : 'Search candidate name or province...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.search,
              color: isDark ? Colors.grey[400] : Colors.grey[600]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // 🆕 الحالة: لم يتم البحث بعد
    if (!_hasSearched) {
      return _buildInitialState(isArabic, isDark, textColor, subtitleColor!);
    }

    // 🆕 الحالة: تم البحث ولكن لا توجد نتائج
    if (_filteredCandidates.isEmpty) {
      return _buildNoResultsState(isArabic, isDark, textColor, subtitleColor!);
    }

    // الحالة: توجد نتائج
    return _buildResultsSuccessState(isDark);
  }

  // 🆕 بناء واجهة الحالة الأولية (قبل البحث)
  Widget _buildInitialState(
      bool isArabic, bool isDark, Color textColor, Color subtitleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'ابحث عن المرشحين' : 'Search Candidates',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'ابحث باستخدام:\n• اسم المرشح\n• اللقب\n• اسم المحافظة'
                : 'Search by:\n• Candidate name\n• Nickname\n• Province name',
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.blue[100]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.blue[200] : Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isArabic
                        ? '${_allCandidates.length} مرشح متاح للبحث'
                        : '${_allCandidates.length} candidates available for search',
                    style: TextStyle(
                      color: isDark ? Colors.blue[200] : Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 بناء واجهة عدم وجود نتائج
  Widget _buildNoResultsState(
      bool isArabic, bool isDark, Color textColor, Color subtitleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            isArabic ? 'لا توجد نتائج' : 'No Results Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic
                ? 'لم نتمكن من العثور على أي نتائج لـ "${_searchController.text}"'
                : 'We couldn\'t find any results for "${_searchController.text}"',
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'تأكد من كتابة الاسم بشكل صحيح أو جرب كلمات بحث أخرى'
                : 'Make sure you spelled the name correctly or try different search terms',
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSuggestionChip(
                isArabic ? 'عرض الكل' : 'Show All',
                Icons.list,
                () => _clearSearch(),
                isDark,
              ),
              _buildSuggestionChip(
                isArabic ? 'المحافظات' : 'Provinces',
                Icons.map,
                () {
                  _searchController.text = isArabic ? 'محافظة' : 'province';
                },
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🆕 بناء قائمة النتائج الناجحة
  Widget _buildResultsSuccessState(bool isDark) {
    return Column(
      children: [
        // 🆕 شريط معلومات النتائج
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredCandidates.length} نتيجة',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_filteredCandidates.isNotEmpty)
                Text(
                  _searchController.text,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),

        // قائمة النتائج
        Expanded(
          child: ListView.builder(
            itemCount: _filteredCandidates.length,
            itemBuilder: (context, index) {
              final candidate = _filteredCandidates[index];
              return _CandidateSearchCard(candidate: candidate);
            },
          ),
        ),
      ],
    );
  }

  // 🆕 بناء رقاقة اقتراح
  Widget _buildSuggestionChip(
      String text, IconData icon, VoidCallback onTap, bool isDark) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      onPressed: onTap,
      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<Timer?>('_debounceTimer', _debounceTimer));
  }
}

class _CandidateSearchCard extends StatelessWidget {
  final CandidateModel candidate;

  const _CandidateSearchCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isDark ? 1 : 2,
      color: isDark ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: _buildAvatar(),
        title: Text(
          candidate.getName(lang),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.getNickname(lang),
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              candidate.province,
              style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CandidateDetailsScreen(candidate: candidate),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final logoPath =
        (candidate.listLogo != null && candidate.listLogo!.isNotEmpty)
            ? candidate.listLogo!
            : 'assets/images/logo.png';
    return CircleAvatar(
      radius: 26,
      backgroundImage: AssetImage(logoPath),
    );
  }
}
