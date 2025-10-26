import 'dart:async';
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/presentation/screens/candidates/candidates_by_province_screen.dart';
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/static/iraqi_provinces.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/core/utils/province_search_engine.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';

class ProvincesScreen extends StatefulWidget {
  const ProvincesScreen({super.key});

  @override
  State<ProvincesScreen> createState() => _ProvincesScreenState();
}

class _ProvincesScreenState extends State<ProvincesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  List<String> _allProvinces = [];
  List<String> _filteredProvinces = [];
  Map<String, List<CandidateModel>> _provinceCandidates = {};
final ProvinceSearchEngine _searchEngine = ProvinceSearchEngine();
  
  bool _isLoading = true;
  String? _error;
  int _totalCandidates = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadProvincesAndCandidates();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProvincesAndCandidates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provinces = List<String>.from(IraqiProvinces.allProvinces);
      final raw = LocalDatabase.getCandidates();
      final List<CandidateModel> allCandidates = [];
      raw.forEach(allCandidates.add);

      final Map<String, List<CandidateModel>> provinceMap = {};
      int totalCandidates = 0;
      
      for (final province in provinces) {
        final provinceCandidates = allCandidates
            .where((c) => c.province.trim() == province.trim())
            .toList();
        provinceMap[province] = provinceCandidates;
        totalCandidates += provinceCandidates.length;
      }

      _searchEngine.initialize(provinceMap);

      setState(() {
        _allProvinces = provinces;
        _filteredProvinces = provinces;
        _provinceCandidates = provinceMap;
        _totalCandidates = totalCandidates;
        _isLoading = false;
      });

      AnalyticsService.trackEvent('provinces_data_loaded', parameters: {
        'provinces_count': provinces.length,
        'candidates_count': totalCandidates,
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات: ${e.toString()}';
        _isLoading = false;
      });
      
      AnalyticsService.trackError('load_provinces', e, StackTrace.current);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim();

      if (query.isEmpty) {
        setState(() => _filteredProvinces = List<String>.from(_allProvinces));
        return;
      }

      final searchResult = _searchEngine.search(query);
      setState(() => _filteredProvinces = searchResult.matchedProvinces);

      if (query.isNotEmpty) {
        AnalyticsService.trackEvent('province_search_executed', parameters: {
          'query': query,
          'results_count': searchResult.matchedProvinces.length,
        });
      }
    });
  }

  String? _getTopProvince() {
    if (_provinceCandidates.isEmpty) return null;
    
    return _provinceCandidates.entries
        .reduce((a, b) => a.value.length > b.value.length ? a : b)
        .key;
  }

  // 🎨 ألوان متوافقة مع الوضع المظلم
  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _getSubtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[300]!
        : Colors.grey[600]!;
  }

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _getSearchFieldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[100]!;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = context.tr('provinces');
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // 🎨 ألوان ديناميكية حسب الوضع
    final cardColor = _getCardColor(context);
    final textColor = _getTextColor(context);
    final subtitleColor = _getSubtitleColor(context);
    final backgroundColor = _getBackgroundColor(context);
    final searchFieldColor = _getSearchFieldColor(context);
    final borderColor = _getBorderColor(context);

    if (_isLoading) {
return FZScaffold(
  persistentBottom: FZTab.home,        appBar: AppBar(
          title: Text(titleText, style: TextStyle(color: textColor)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('loading_provinces'),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return FZScaffold(
  persistentBottom: FZTab.home,
        appBar: AppBar(
          title: Text(titleText, style: TextStyle(color: textColor)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProvincesAndCandidates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('retry')),
              ),
            ],
          ),
        ),
      );
    }

    return FZScaffold(
  persistentBottom: FZTab.home,
      appBar: AppBar(
        title: Text(titleText, style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: textColor),
              onPressed: () {
                _searchController.clear();
                setState(() => _filteredProvinces = List.from(_allProvinces));
              },
              tooltip: context.tr('clear_search'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 مربع البحث المحسّن للوضع المظلم
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: TextStyle(color: textColor), // 🎨 لون النص
              decoration: InputDecoration(
                hintText: context.tr('search_province_or_candidate'),
                hintStyle: TextStyle(color: subtitleColor), // 🎨 لون النص التوضيحي
                prefixIcon: Icon(Icons.search, color: subtitleColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: subtitleColor),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: searchFieldColor,
              ),
            ),
          ),

          // 📊 الإحصائيات - مصممة للوضع المظلم
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue[900]!.withValues(alpha: 0.7)
                  : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue[700]!
                    : Colors.blue[100]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context.tr('provinces'), 

                  _allProvinces.length.toString(), 
                  Icons.map,
                  context,
                ),
                _buildStatItem(
                  context.tr('candidates'),

                  _totalCandidates.toString(), 
                  Icons.people,
                  context,
                ),
                _buildStatItem(
                  context.tr('top'), 
                  _getTopProvince() != null 
                      ? _provinceCandidates[_getTopProvince()]!.length.toString()
                      : '0', 
                  Icons.star,
                  context,
                  _getTopProvince(),
                ),
              ],
            ),
          ),

          // ℹ️ معلومات النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${context.tr('showing')} ${_filteredProvinces.length} ${context.tr('of')} ${_allProvinces.length} ${context.tr('provinces')}',
                  style: TextStyle(
                    fontSize: 12, 
                    color: subtitleColor, // 🎨 لون مناسب للوضع المظلم
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    '$_totalCandidates مرشح متاح للبحث',
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),

          // 🧾 النتائج المحسّنة للوضع المظلم
          Expanded(
            child: _filteredProvinces.isEmpty
                ? _buildEmptyState(textColor, subtitleColor, backgroundColor)
                : ListView.separated(
                    itemCount: _filteredProvinces.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: borderColor, // �️ لون الفاصل مناسب للوضع المظلم
                    ),
                    itemBuilder: (context, index) {
                      final province = _filteredProvinces[index];
                      final candidates = _provinceCandidates[province] ?? [];
                      final count = candidates.length;

                      return _buildProvinceItem(
                        province, 
                        count, 
                        context,
                        cardColor,
                        textColor,
                        subtitleColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, BuildContext context, [String? tooltip]) {
    final iconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.blue[200]
        : Colors.blue[700];
    final textColor = _getTextColor(context);

    return Tooltip(
      message: tooltip ?? '',
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
              color: textColor,
            ),
          ),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              color: _getSubtitleColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subtitleColor, Color backgroundColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: subtitleColor, // 🎨 لون مناسب للوضع المظلم
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج مطابقة',
              style: TextStyle(
                fontSize: 18, 
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'بحثك عن "${_searchController.text}" لم يعطِ أي نتائج',
              style: TextStyle(fontSize: 14, color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _filteredProvinces = List.from(_allProvinces));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context).translate('show_all_provinces')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvinceItem(
    String province, 
    int count, 
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: Theme.of(context).brightness == Brightness.dark ? 1 : 2,
      color: cardColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getProvinceColor(count),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_on,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
                    IraqiProvinces.displayName(
            province,
            Localizations.localeOf(context).languageCode,
          ),

          style: TextStyle(
            fontWeight: FontWeight.w600, 
            fontSize: 16,
            color: textColor, // 🎨 لون النص الرئيسي
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count > 0 ? 'عدد المرشحين: $count' : 'لا يوجد مرشحين مسجلين',
              style: TextStyle(
                color: count > 0 
                    ? _getCountColor(count, context) 
                    : subtitleColor,
                fontSize: 12,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: count / 50,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : Colors.grey[200]!,
                color: _getProvinceColor(count),
                minHeight: 3,
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios, 
          size: 16, 
          color: subtitleColor, // 🎨 لون السهم مناسب للوضع المظلم
        ),
        onTap: () {
          AnalyticsService.trackEvent('province_selected', parameters: {
            'province': province,
            'candidates_count': count,
            'search_query': _searchController.text,
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CandidatesByProvinceScreen(province: province),
            ),
          );
        },
      ),
    );
  }

  Color _getProvinceColor(int candidateCount) {
    if (candidateCount == 0) return Colors.grey;
    if (candidateCount < 5) return Colors.blue;
    if (candidateCount < 10) return Colors.green;
    if (candidateCount < 20) return Colors.orange;
    return Colors.red;
  }

  Color _getCountColor(int count, BuildContext context) {
    if (count == 0) return _getSubtitleColor(context);
    if (count < 5) return Colors.blue;
    if (count < 10) return Colors.green;
    if (count < 20) return Colors.orange;
    return Colors.red;
  }
}