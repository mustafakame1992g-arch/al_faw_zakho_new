// lib/presentation/screens/candidates/candidates_by_province_screen.dart

import 'dart:async';
import 'dart:developer' as developer;

import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/static/iraqi_provinces.dart';
import 'package:al_faw_zakho/presentation/screens/candidates/candidate_details_screen.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_bottom_nav.dart';
import 'package:al_faw_zakho/presentation/widgets/fz_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CandidatesByProvinceScreen extends StatefulWidget {
  const CandidatesByProvinceScreen({
    super.key,
    required this.province,
  });
  final String province;

  @override
  State<CandidatesByProvinceScreen> createState() =>
      _CandidatesByProvinceScreenState();
}

class _CandidatesByProvinceScreenState
    extends State<CandidatesByProvinceScreen> {
  final TextEditingController _searchController = TextEditingController();
// 🆕

  List<CandidateModel> _allCandidates = [];
  List<CandidateModel> _filteredCandidates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    _searchController.addListener(_onSearchChanged);
    AnalyticsService.trackEvent(
      'candidates_by_province_opened',
      parameters: {
        'province': widget.province,
      },
    );
  }

  Future<void> _loadCandidates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final List<dynamic> rawCandidates =
          List<dynamic>.from(LocalDatabase.getCandidates());
      final String provinceKey = widget.province.trim();

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

        if (c != null) {
          all.add(c);
        }
      }

      // 🔍 المرشحين حسب المحافظة المطلوبة
      final provinceFiltered =
          all.where((c) => c.province.trim() == provinceKey).toList();

      _allCandidates = provinceFiltered;
      _filteredCandidates = _allCandidates;

      developer.log(
        '✅ Loaded ${_allCandidates.length} candidate(s) for $provinceKey',
        name: 'CANDIDATES',
      );

      setState(() => _isLoading = false);
    } catch (e, stack) {
      AnalyticsService.trackError('load_candidates_by_province', e, stack);
      setState(() {
        _isLoading = false;
        _error = 'فشل تحميل مرشحي المحافظة';
        _allCandidates = [];
        _filteredCandidates = [];
      });
    }
  }

// 🆕 إضافة متغير Debouncer في أعلى الكلاس
  Timer? _debounceTimer;

  void _onSearchChanged() {
    // 🆕 إلغاء المؤقت السابق إذا كان نشطاً
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // 🆕 إنشاء مؤقت جديد للبحث
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        setState(() => _filteredCandidates = _allCandidates);
        return;
      }

      setState(() {
        _filteredCandidates = _allCandidates.where((candidate) {
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
      });
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FZScaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('about_name'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary, // وضوح مضمون
              ),
            ),
            Text(
              IraqiProvinces.displayName(
                  widget.province,
                  Localizations.localeOf(context).languageCode,
                ),
              
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.grey[300]
                    : Colors.white.withValues(alpha: .7), // 🎨 نص ثانوي واضح
              
            ),),
          ],
        ),
        centerTitle: false,
        elevation: 2,
        actions: [
          // 🆕 إضافة زر مسح البحث في AppBar
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: isDark ? Colors.white : Colors.white,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _filteredCandidates = _allCandidates;
                });
              },
              tooltip: AppLocalizations.of(context).translate('clear_search'),
            ),
        ],
      ),
      persistentBottom: FZTab.home,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(isDark)
              : _buildCandidatesList(isArabic, isDark),
    );
  }

  Widget _buildSearchBar(bool isArabic, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87, // 🎨 نص واضح
        ),
        decoration: InputDecoration(
          hintText:
              AppLocalizations.of(context).translate('search_within_province'),
          hintStyle: TextStyle(
            color: isDark
                ? Colors.grey[400]
                : Colors.grey[600], // 🎨 نص توضيحي واضح
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
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
          fillColor:
              isDark ? Colors.grey[800]! : Colors.grey[100]!, // 🎨 خلفية مناسبة
        ),
      ),
    );
  }

  Widget _buildCandidatesList(bool isArabic, bool isDark) {
    // 🆕 إذا كانت هناك نتائج بحث فارغة، نعرضها داخل الشاشة نفسها
    if (_filteredCandidates.isEmpty && _searchController.text.isNotEmpty) {
      return Column(
        children: [
          _buildHeader(isDark),
          _buildSearchBar(isArabic, isDark),
          Expanded(
            child: _buildEmptyStateWithinScreen(
              isDark,
              isArabic,
            ), // 🆕 حالة فارغة داخل الشاشة
          ),
        ],
      );
    }

    // إذا لم يكن هناك بحث أو توجد نتائج، نعرض القائمة العادية
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredCandidates.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeader(isDark);
        if (index == 1) return _buildSearchBar(isArabic, isDark);

        final candidate = _filteredCandidates[index - 2];
        return _CandidateCard(
          candidate: candidate,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CandidateDetailsScreen(candidate: candidate),
              ),
            );
          },
        );
      },
    );
  }

// 🆕 بناء واجهة الحالة الفارغة داخل الشاشة نفسها
  Widget _buildEmptyStateWithinScreen(bool isDark, bool isArabic) {
    return Center(
      child: SingleChildScrollView(
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
              AppLocalizations.of(context).translate('no_matching_results'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${AppLocalizations.of(context).translate('no_results_for')} "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)
                  .translate('check_spelling_or_try_others'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSuggestionChip(
                  isArabic ? 'مسح البحث' : 'Clear Search',
                  Icons.clear_all,
                  () {
                    _searchController.clear();
                    setState(() {
                      _filteredCandidates = _allCandidates;
                    });
                  },
                  isDark,
                ),
                _buildSuggestionChip(
                  isArabic ? 'عرض الكل' : 'Show All',
                  Icons.list,
                  () {
                    _searchController.clear();
                    setState(() {
                      _filteredCandidates = _allCandidates;
                    });
                  },
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                          ? '${_allCandidates.length} مرشح متاح في ${widget.province}'
                          : '${_allCandidates.length} candidates available in ${widget.province}',
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
      ),
    );
  }

// 🆕 بناء رقاقة اقتراح
  Widget _buildSuggestionChip(
    String text,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      onPressed: onTap,
      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final count = _allCandidates.length;
    final langCode = Localizations.localeOf(context).languageCode;
    final isArabic = langCode == 'ar' || langCode.startsWith('ar');
    final displayProvince =
        IraqiProvinces.displayName(widget.province.trim(), langCode);
    String getLogoPath() {
      final province = widget.province.trim();
      const logoPaths = {
        'بغداد': 'assets/images/candidates/Amer_abd_jbar.png',
        'كربلاء': 'assets/images/bdeel.png',
        'النجف': 'assets/images/bdeel.png',
        'القادسية': 'assets/images/bdeel.png',
        'ذي قار': 'assets/images/bdeel.png',
        'ميسان': 'assets/images/candidates/bassam.jpg',
        'المثنى': 'assets/images/candidates/bassam.jpg',
        'الأنبار': 'assets/images/candidates/bassam.jpg',
        'ديالى': 'assets/images/candidates/bassam.jpg',
        'نينوى': 'assets/images/candidates/bassam.jpg',
        'أربيل': 'assets/images/candidates/bassam.jpg',
        'دهوك': 'assets/images/candidates/bassam.jpg',
        'السليمانية': 'assets/images/candidates/bassam.jpg',
        'صلاح الدين': 'assets/images/candidates/bassam.jpg',
        'حلبجة': 'assets/images/candidates/bassam.jpg',
        'كركوك': 'assets/images/candidates/bassam.jpg',
      };
      return logoPaths[province] ?? 'assets/images/logo.png';
    }

    String getHeaderText() {
      final province = widget.province.trim();
      const specialHeaders = {
        'بغداد': 'جميع مرشحينا دخلو باسم تجمع الفاو زاخو لبغداد 🇮🇶',
        'النجف': 'المرشحة الوحيدة لدينا في النجف الاشرف المهندسة سارة الموسوي ضمن تحالف البديل ',
        'كربلاء':
            'مرشحنا الوحيد في كربلاء للخبير الوطني عامر عبد الجبار ضمن تحالف البديل',
        'القادسية':
            'مرشحنا الوحيد في القادسية للخبير الوطني عامر عبد الجبار ضمن تحالف البديل',
        'ذي قار':
            'مرشحنا الوحيد في ذي قار للخبير الوطني عامر عبد الجبار ضمن تحالف البديل',
        'ميسان':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها ميسان',
        'الأنبار':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها الانبار',
        'ديالى':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها ديالى',
        'المثنى':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها المثنى',
        'نينوى':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها نينوى',
        'أربيل':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها اربيل',
        'السليمانية':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها السليمانية',
        'دهوك':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها دهوك',
        'كركوك':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها كركوك',
        'صلاح الدين':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها صلاح الدين',
        'حلبجة':
            'مرشحنا الوحيد عن كوتا الصابئة المندائيين والمدعوم من الخبير الوطني عامر عبد الجبار في عشر محافظات من ضمنها حلبجة',
      };
      return specialHeaders[province] ??
          (isArabic
              ? 'جميعهم دخلو باسم ${AppLocalizations.of(context).translate('about_name')} وعددهم $count'
              : 'All of them joined under ${AppLocalizations.of(context).translate('about_name')} — total $count');
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]
            : const Color(0xFFF4F4F4), // 🎨 خلفية مناسبة
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : const Color(0xFF555555),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.grey[700]
                  : Colors.white, // 🎨 خلفية صورة مناسبة
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey.shade300,
              ),
            ),
            child: Image.asset(
              getLogoPath(),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('assets/images/logo.png'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).translate('candidates_in_province'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? Colors.white : const Color(0xFF222222), // 🎨 نص واضح
            ),
          ),
          const SizedBox(height: 4),
          Text(
            getHeaderText(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.grey[300]
                  : const Color(0xFF555555), // 🎨 نص ثانوي واضح
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context).translate('province')}: $displayProvince',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.grey[200]
                  : const Color(0xFF333333), // 🎨 نص واضح
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) => Center(
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
              _error ??
                  AppLocalizations.of(context).translate('unexpected_error'),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.red, // 🎨 نص خطأ واضح
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCandidates,
              child: Text(AppLocalizations.of(context).translate('retry')),
            ),
          ],
        ),
      );
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.isDark,
    required this.onTap,
  });
  final CandidateModel candidate;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLanguage = languageProvider.languageCode;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isDark ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[800] : Colors.white, // 🎨 خلفية بطاقة مناسبة
      child: ListTile(
        leading: _buildCandidateAvatar(),
        title: Text(
          candidate.getName(currentLanguage),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87, // 🎨 نص واضح
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              candidate.getNickname(currentLanguage),
              style: TextStyle(
                color: isDark
                    ? Colors.grey[300]
                    : Colors.grey[700], // 🎨 نص ثانوي واضح
              ),
            ),
            const SizedBox(height: 4),
            Text(
              candidate.getPosition(currentLanguage),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              candidate.listName ??
                  AppLocalizations.of(context).translate('about_name'),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.black54, // 🎨 نص واضح
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color:
              isDark ? Colors.grey[400] : Colors.grey[600], // 🎨 أيقونة مناسبة
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCandidateAvatar() {
    final logoPath =
        (candidate.listLogo != null && candidate.listLogo!.isNotEmpty)
            ? candidate.listLogo!
            : 'assets/images/logo.png';
    return CircleAvatar(
      radius: 28,
      backgroundImage: AssetImage(logoPath),
    );
  }
}
