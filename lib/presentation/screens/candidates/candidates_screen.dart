// lib/presentation/screens/candidates/candidates_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/providers/connectivity_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/presentation/widgets/error_screen.dart';
import 'package:al_faw_zakho/presentation/widgets/loading_screen.dart';
import 'package:al_faw_zakho/presentation/screens/candidates/global_candidates_search_screen.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _rawCandidates = [];
  List<String> _allProvinces = [];
  List<String> _filteredProvinces = [];

  bool _isLoading = true;
  String? _error;
  bool _usingMockData = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadCandidates();
    AnalyticsService.trackEvent('candidates_screen_opened');
  }

  Future<void> _loadCandidates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _usingMockData = false;
      });

      final connectivity =
          Provider.of<ConnectivityProvider>(context, listen: false);
      final localCandidates = LocalDatabase.getCandidates();

      if (localCandidates.isNotEmpty) {
        _rawCandidates = localCandidates;
        _allProvinces = _extractUniqueProvinces(_rawCandidates);
        _filteredProvinces = List<String>.from(_allProvinces);
        setState(() => _isLoading = false);
        return;
      }

      if (!connectivity.isOnline) {
        setState(() {
          _error = 'لا يمكن تحميل البيانات بدون اتصال بالإنترنت.';
          _isLoading = false;
        });
        return;
      }

      // (مستقبلاً: تحميل من API)
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
    } catch (e, stack) {
      AnalyticsService.trackError('load_candidates', e, stack);
      setState(() {
        _error = 'حدث خطأ أثناء تحميل المرشحين: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // استخراج المحافظة من عنصر ديناميكي بأمان
  String? _getProvince(dynamic e) {
    try {
      if (e is Map) {
        final v = e['province'];
        return v?.toString().trim();
      } else {
        final v = (e as dynamic).province; // dynamic access
        return v?.toString().trim();
      }
    } catch (_) {
      return null;
    }
  }

  // استخراج المحافظات الفريدة مرتبة
  List<String> _extractUniqueProvinces(List<dynamic> items) {
    final set = <String>{};
    for (final e in items) {
      final p = _getProvince(e);
      if (p != null && p.isNotEmpty) set.add(p);
    }
    final list = set.toList()..sort((a, b) => a.compareTo(b));
    return list;
  }

  // البحث عن المحافظة
  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredProvinces = List<String>.from(_allProvinces));
      return;
    }
    setState(() {
      _filteredProvinces =
          _allProvinces.where((p) => p.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
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
        title: Text(
          isArabic ? 'محافظات المرشحين' : 'Candidates by Province',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            tooltip: isArabic ? 'بحث شامل عن جميع المرشحين' : 'Global Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GlobalCandidatesSearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildProvinceSearchBody(context, isArabic),
    );
  }

  // واجهة المحافظات + شريط البحث
  Widget _buildProvinceSearchBody(BuildContext context, bool isArabic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) return const LoadingScreen(progress: 0.5);

    if (_error != null) {
      return ErrorScreen(error: _error!, onRetry: _loadCandidates);
    }

    if (_filteredProvinces.isEmpty) {
      return Center(
        child: Text(
          isArabic ? 'لا توجد محافظات مطابقة للبحث' : 'No provinces found',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.grey, // 🎨 نص واضح
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, // 🎨 نص واضح
            ),
            decoration: InputDecoration(
              hintText: isArabic ? 'ابحث عن محافظة...' : 'Search province...',
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600], // 🎨 نص توضيحي واضح
              ),
              prefixIcon: Icon(Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
              fillColor: isDark
                  ? Colors.grey[800]!
                  : Colors.grey[100]!, // 🎨 خلفية مناسبة
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredProvinces.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark
                  ? Colors.grey[700]!
                  : Colors.grey[300]!, // 🎨 فاصل مناسب
            ),
            itemBuilder: (context, index) {
              final province = _filteredProvinces[index];
              return _buildProvinceItem(province, isArabic, isDark);
            },
          ),
        ),
        if (_usingMockData)
          Container(
            padding: const EdgeInsets.all(8),
            color: isDark
                ? Colors.orange[900]!
                : Colors.orange[50]!, // 🎨 خلفية مناسبة
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'عرض بيانات تجريبية',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ✅ تحسين الألوان للوضع المظلم
  Widget _buildProvinceItem(String province, bool isArabic, bool isDark) {
    return ListTile(
      leading: Icon(
        Icons.location_on,
        color:
            isDark ? Colors.blue[300] : Colors.blueAccent, // 🎨 تحسين التباين
      ),
      title: Text(
        province,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16, // 🎨 تحسين حجم الخط
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/candidates_by_province',
          arguments: province,
        );
        AnalyticsService.trackEvent('province_selected', parameters: {
          'province': province,
        });
      },
    );
  }
}
