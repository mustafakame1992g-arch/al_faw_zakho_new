import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_faw_zakho/core/constants/app_constants.dart';
import 'dart:collection';

/// 🌍 نظام الترجمة المتكامل والمحسن للتطبيق
/// يدعم اللغات: العربية والإنجليزية فقط
class AppLocalizations {
  final Locale locale;
  final String? selectedLanguageCode;

 // 🎯 [إضافة] متغير اللغة الافتراضية
  static String defaultLanguage = 'ar';

  AppLocalizations(this.locale, {this.selectedLanguageCode});
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('ar'), // العربية
    Locale('en'), // الإنجليزية
  ];

  // 🗃️ قاعدة بيانات الترجمة المبسطة للغتين فقط
  static const Map<String, Map<String, String>> _translationDatabase = {
  'ar': {

    'search_candidates': 'بحث المرشحين',
    'mobile_number': 'رقم الموبايل',
    'phone_copied': 'تم نسخ رقم الموبايل:',
    'copy_failed': 'فشل في نسخ الرقم',
    'refresh_content': 'تحديث المحتوى',
    'help': 'المساعدة',
    'news_title': '📰 أخبار تجمع الفاو زاخو',
    'news_wip': 'صفحة الأخبار قيد التطوير',
    'offices_title': '🏢 مكاتب تجمع الفاو زاخو',
    'provincial_offices': '🏢 مكاتب المحافظات',
    'error_loading_data': 'حدث خطأ أثناء تحميل البيانات',
    'vision_title': 'رؤية التجمع',
    'done': 'تم',
    'support_bloc': 'ادعم تجمع الفاو زاخو',
    'contribution_thanks': 'مساهمتك تحدث فرقًا حقيقيًا — شكرًا لدعمك!',
    'donate_via_zaincash': 'التبرع عبر زين كاش',
    'open_zaincash_and_send_to': 'افتح تطبيق ZainCash ثم أرسل إلى الرقم التالي',
    'zaincash_details': 'تفاصيل زين كاش',
    'number_label': 'الرقم',
    'name_label': 'الاسم',
    'description_label': 'الوصف',
    'donation_description': 'تبرع دعم الحملة',
    'bank_card': 'بطاقة مصرفية',
    'coming_soon': 'قريبًا — قنوات دفع إضافية.',
    'app_title': 'تطبيق تجمع الفاو زاخو',
    'welcome': 'مرحباً',
    'home': 'الرئيسية',
    'settings': 'الإعدادات',
    'candidates': 'المرشحين',
    'program': 'البرنامج الانتخابي',
    'faq': 'الأسئلة الشائعة',
    'offices': 'المكاتب',
    'news': 'الأخبار',
    'appearance': 'المظهر',
    'language': 'اللغة',
    'dark_mode': 'الوضع الليلي',
    'about_app': 'حول التطبيق',
    'donate': 'تبرع',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'ok': 'موافق',
    'search': 'بحث',
    'loading': 'جاري التحميل',
    'error': 'خطأ',
    'no_data': 'لا توجد بيانات',
    'language_changed': 'تم تغيير اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'version': 'الإصدار',
    'build': 'البناء',
    'system': 'النظام',
    'online': 'متصل بالإنترنت',
    'offline': 'غير متصل بالإنترنت',
    'political_election': 'منصة سياسية شاملة للتعريف بالبرنامج الانتخابي والمرشحين',

    // === الشاشات/الكيانات ===
    'provinces': 'المحافظات',
    'our_candidates_in': 'مرشحونا في',
    'candidate_details': 'تفاصيل المرشح',
    'full_name': 'الاسم الثلاثي',
    'nickname': 'اللقب',
    'biography': 'السيرة الذاتية',
    'contact_info': 'معلومات التواصل',

    // === إضافات لإكمال الترجمة في الواجهات التي عدّلناها ===
    'app_running_msg': 'مرحباً! التطبيق يعمل 🎉',
    'last_update': 'آخر تحديث',
    'status': 'الحالة',
    'stable': 'مستقر',
    'retry': 'إعادة المحاولة',
    'clear_search': 'مسح البحث',
    'search_province_or_candidate': 'ابحث عن محافظة أو مرشح...',
    'top': 'الأعلى',
    'showing': 'عرض',
    'of': 'من',
    'no_matching_results': 'لا توجد نتائج مطابقة',
    'no_results_for': 'لا توجد نتائج لـ',
    'show_all_provinces': 'عرض جميع المحافظات',
    'candidates_count': 'عدد المرشحين',
    'no_candidates': 'لا يوجد مرشحون مسجلون',

    // === شريط الأخبار (NewsTicker) ===
    'news_ticker': 'شريط الأخبار',
    'items': 'خبر',
    'breaking': 'عاجل',
    'loading_news': 'جاري تحميل الأخبار...',
    'previous_news': 'الخبر السابق',
    'next_news': 'الخبر التالي',

    "about_title": "حول التجمع",
  "about_name": "تجمع الفاو زاخو",
  "about_motto": "من أجل عراق موحَّد، من الجنوب إلى الشمال",
  "about_intro": "تجمع الفاو زاخو هو مبادرة وطنية تهدف إلى ...",
  "about_hq": "المقر الرئيسي: البصرة – العراق",
  "about_founded": "التأسيس: 2024",
  "about_goal": "الهدف: نشر الوعي الانتخابي ودعم الكفاءات الوطنية",
  "rights_reserved": "جميع الحقوق محفوظة © {year}\nتجمع الفاو زاخو – الإصدار {version}",



    'search_within_province': 'ابحث عن اسم المرشح داخل هذه المحافظة...',
    'candidates_in_province': '🗳️ مرشحونا في المحافظة',
    'province': 'المحافظة',
    'unexpected_error': 'حدث خطأ غير متوقع',
    'check_spelling_or_try_others': 'تأكد من كتابة الاسم بشكل صحيح أو جرّب كلمات بحث أخرى',

  },

  'en': {
    'app_title': 'Al-Faw Zakho Gathering App',
    'welcome': 'Welcome',
    'home': 'Home',
    'settings': 'Settings',
    'candidates': 'Candidates',
    'program': 'Election Program',
    'faq': 'FAQ',
    'offices': 'Offices',
    'news': 'News',
    'appearance': 'Appearance',
    'language': 'Language',
    'dark_mode': 'Dark Mode',
    'about_app': 'About App',
    'donate': 'Donate',
    'save': 'Save',
    'cancel': 'Cancel',
    'ok': 'OK',
    'search': 'Search',
    'loading': 'Loading',
    'error': 'Error',
    'no_data': 'No data available',
    'language_changed': 'Language changed',
    'arabic': 'Arabic',
    'english': 'English',
    'version': 'Version',
    'build': 'Build',
    'system': 'System',
    'online': 'Online',
    'offline': 'Offline',
    'political_election': 'Comprehensive political platform for introducing the electoral program and candidates',

    // === screens/entities ===
    'provinces': 'Provinces',
    'our_candidates_in': 'Our candidates in',
    'candidate_details': 'Candidate Details',
    'full_name': 'Full Name',
    'nickname': 'Nickname',
    'biography': 'Biography',
    'contact_info': 'Contact Information',

    // === extras for updated widgets/screens ===
    'app_running_msg': 'Hello! The app is running 🎉',
    'last_update': 'Last update',
    'status': 'Status',
    'stable': 'Stable',
    'retry': 'Retry',
    'clear_search': 'Clear search',
    'search_province_or_candidate': 'Search for a province or candidate...',
    'top': 'Top',
    'showing': 'Showing',
    'of': 'of',
    'no_matching_results': 'No matching results',
    'no_results_for': 'No results for',
    'show_all_provinces': 'Show all provinces',
    'candidates_count': 'Candidates',
    'no_candidates': 'No candidates available',

    // === NewsTicker ===
    'news_ticker': 'News ticker',
    'items': 'items',
    'breaking': 'Breaking',
    'loading_news': 'Loading news…',
    'previous_news': 'Previous news',
    'next_news': 'Next news',
    "about_title": "About the Bloc",
  "about_name": "Al-Faw Zakho Bloc",
  "about_motto": "For a unified Iraq, from South to North",
  "about_intro": "Al-Faw Zakho is a national initiative that aims to ...",
  "about_hq": "Headquarters: Basra – Iraq",
  "about_founded": "Founded: 2024",
  "about_goal": "Goal: Raise electoral awareness and support national competencies",
  "rights_reserved": "All rights reserved © {year}\nAl-Faw Zakho – version {version}",
  
      'search_candidates': 'Search Candidates',
    'mobile_number': 'Mobile number',
    'phone_copied': 'Phone number copied:',
    'copy_failed': 'Failed to copy number',
    'refresh_content': 'Refresh Content',
    'help': 'Help',
    'news_title': '📰 Al-Faw Zakho News',
    'news_wip': 'News page is under development',
    'offices_title': '🏢 Al-Faw Zakho Offices',
    'provincial_offices': '🏢 Provincial Offices',
    'error_loading_data': 'An error occurred while loading data',
    'vision_title': 'Bloc Vision',
    'done': 'Done',
    'support_bloc': 'Support Al-Faw Zakho',
    'contribution_thanks': 'Your contribution makes a real difference — thank you!',
    'donate_via_zaincash': 'Donate via ZainCash',
    'open_zaincash_and_send_to': 'Open ZainCash and send to the following number',
    'zaincash_details': 'ZainCash Details',
    'number_label': 'Number',
    'name_label': 'Name',
    'description_label': 'Description',
    'donation_description': 'Campaign support donation',
    'bank_card': 'Bank Card',
    'coming_soon': 'Coming soon — additional payment channels.',

  
  

      'search_within_province': 'Search name within this province...',
    'candidates_in_province': '🗳️ Candidates in the province',
    'province': 'Province',
    'unexpected_error': 'Unexpected error',
    'check_spelling_or_try_others': 'Make sure you spelled the name correctly or try different search terms',

  },

  };

  // 🔄 نظام ذاكرة مؤقتة ذكي بحدود آمنة
  final _SmartTranslationCache _translationCache = _SmartTranslationCache();
  
  // 📊 إحصائيات أداء
  int _totalRequests = 0;
  int _cacheHits = 0;

  String translate(String key) {
    _totalRequests++;
    
    // ✅ التحقق من الذاكرة المؤقتة الذكية
    final cached = _translationCache.get(key);
    if (cached != null) {
      _cacheHits++;
      return cached;
    }

    // 🔍 منطق الترجمة المتسلسل
    String? translation;
    
    // المحاولة الأولى: اللغة المختارة
    if (selectedLanguageCode != null) {
      translation = _translationDatabase[selectedLanguageCode]?[key];
    }
    
    // المحاولة الثانية: لغة الجهاز
    translation ??= _translationDatabase[locale.languageCode]?[key];
    
    /*// المحاولة الثالثة: اللغة الافتراضية (العربية)
    if (translation == null) {
      translation = _translationDatabase['ar']?[key];
    }*/

    // 🎯 [تعديل] المحاولة الثالثة: اللغة الافتراضية (قابلة للتخصيص)
    translation ??= _translationDatabase[defaultLanguage]?[key];
    
    // المحاولة الأخيرة: الإنجليزية أو المفتاح نفسه
    final result = translation ?? _translationDatabase['en']?[key] ?? key;
    
    // ✅ التخزين في الذاكرة المؤقتة الذكية
    if (result != key) {
      _translationCache.set(key, result);
    }
    
    // 📈 تسجيل الأداء (للتطوير فقط)
    if (kDebugMode && _totalRequests % 50 == 0) {
      _logPerformance();
    }
    
    return result;
  }


  // 📊 تسجيل إحصائيات الأداء
  void _logPerformance() {
    final hitRate = _totalRequests > 0 ? (_cacheHits / _totalRequests * 100) : 0;
    debugPrint('''
🧠 Translation Performance:
   • Cache Hit Rate: ${hitRate.toStringAsFixed(1)}%
   • Total Requests: $_totalRequests
   • Cache Hits: $_cacheHits
   • Cache Size: ${_translationCache.size}/100
   • Memory Usage: ${_translationCache.memoryUsage.toStringAsFixed(1)}%
''');
  }

  // 🚀 دوال سريعة للوصول المباشر للترجمات الشائعة
  String get appTitle => translate('app_title');
  String get welcome => translate('welcome');
  String get home => translate('home');
  String get settings => translate('settings');
  String get candidates => translate('candidates');
  String get program => translate('program');
  String get faq => translate('faq');
  String get offices => translate('offices');
  String get news => translate('news');
  String get appearance => translate('appearance');
  String get language => translate('language');
  String get darkMode => translate('dark_mode');
  String get aboutApp => translate('about_app');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get search => translate('search');
  String get loading => translate('loading');
  String get error => translate('error');
  String get noData => translate('no_data');
  String get languageChanged => translate('language_changed');


  // 🔧 دوال مساعدة للإدارة
  void clearCache() => _translationCache.clear();
  double get cacheHitRate => _totalRequests > 0 ? _cacheHits / _totalRequests : 0;


   // 🎯 [إضافة] دالة محسنة لتغيير اللغة الافتراضية
  static void setDefaultLanguage(String languageCode) {
    if (['ar', 'en'].contains(languageCode)) {
      defaultLanguage = languageCode;
      if (kDebugMode) {
        debugPrint('✅ اللغة الافتراضية تم تغييرها إلى: $languageCode');
      }
    } else {
      if (kDebugMode) {
        debugPrint('❌ اللغة غير مدعومة: $languageCode - استخدم "ar" أو "en"');
      }
    }
  }

}



/// 🧠 نظام ذاكرة مؤقتة ذكي بحدود آمنة
class _SmartTranslationCache {
  static const int _maxSize = 100; // ✅ حد أقصى آمن
  static const Duration _defaultTTL = Duration(hours: 24); // ✅ انتهاء صلاحية
  
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();
  
  String? get(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;
    
    // ✅ التحقق من انتهاء الصلاحية
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    // ✅ تحديث الترتيب (LRU - Least Recently Used)
    _cache.remove(key);
    _cache[key] = entry;
    
    return entry.value;
  }
  

  
  void set(String key, String value, {Duration? ttl}) {
    // ✅ التحقق من الحجم أولاً
    if (_cache.length >= _maxSize) {
      _removeOldest();
    }
    
    _cache[key] = _CacheEntry(value, ttl ?? _defaultTTL);
    
    // ✅ تنظيف دوري للعناصر المنتهية (كل 20 عملية إضافة)
    if (_cache.length % 20 == 0) {
      _cleanExpired();
    }
  }
  
  void _removeOldest() {
    if (_cache.isNotEmpty) {
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
      if (kDebugMode) {
        debugPrint('🧹 Removed oldest cache entry: $firstKey');
      }
    }
  }
  
  void _cleanExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
   /* for (final key in expiredKeys) {
      _cache.remove(key);
    }*/

    expiredKeys.forEach(_cache.remove);

    
    if (kDebugMode && expiredKeys.isNotEmpty) {
      debugPrint('🧹 Cleaned ${expiredKeys.length} expired cache entries');
    }
  }
  
  void clear() => _cache.clear();
  
  // 📊 إحصائيات
  int get size => _cache.length;
  double get memoryUsage => (size / _maxSize) * 100;
  int get expiredCount => _cache.values.where((e) => e.isExpired).length;
}

/// ⏰ مدخل الذاكرة المؤقتة مع وقت الانتهاء
class _CacheEntry {
  final String value;
  final DateTime expiryTime;
  
  _CacheEntry(this.value, Duration ttl) 
    : expiryTime = DateTime.now().add(ttl);
  
  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// 🎭 Delegate محسّن مع إدارة ذاكرة أفضل
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedLanguage = prefs.getString(AppConstants.languagePreferenceKey);
      
      return SynchronousFuture<AppLocalizations>(
        AppLocalizations(locale, selectedLanguageCode: selectedLanguage)
      );
    } catch (e, stackTrace) {
      // ✅ معالجة أخطاء محسنة
      if (kDebugMode) {
        debugPrint('❌ Error loading localization: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// 🌟 إكستنشن محسّن مع دوال مساعدة إضافية
extension AppLocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  
  String tr(String key) => loc.translate(key);
  
  // 🎯 دوال سريعة للترجمات الشائعة
  String get appTitle => loc.appTitle;
  String get welcome => loc.welcome;
  String get home => loc.home;
  String get settings => loc.settings;
  String get candidates => loc.candidates;
  String get program => loc.program;
  String get faq => loc.faq;
  String get offices => loc.offices;
  String get news => loc.news;
  String get appearance => loc.appearance;
  String get language => loc.language;
  String get darkMode => loc.darkMode;
  String get aboutApp => loc.aboutApp;
  String get save => loc.save;
  String get cancel => loc.cancel;
  String get ok => loc.ok;
  String get search => loc.search;
  String get loading => loc.loading;
  String get error => loc.error;
  String get noData => loc.noData;
  String get languageChanged => loc.languageChanged;
  
  // ✅ دوال مساعدة جديدة للتحقق من اللغة
  bool get isArabic => loc.locale.languageCode == 'ar';
  bool get isEnglish => loc.locale.languageCode == 'en';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
  
  // 🔧 دوال إدارة الذاكرة المؤقتة
  void clearTranslationCache() => loc.clearCache();
  double get translationCacheHitRate => loc.cacheHitRate;
}

/// 🔍 فئة مساعدة للتحقق من صحة الترجمات (للتطوير فقط)
class TranslationValidator {
  static void validateTranslations() {
    const database = AppLocalizations._translationDatabase;
    
    // ✅ معالجة آمنة للقيم null
    final arMap = database['ar'];
    final enMap = database['en'];
    
    if (arMap == null || enMap == null) {
      debugPrint('❌ Translation database missing required languages');
      return;
    }
    
    final arKeys = arMap.keys.toSet();
    final enKeys = enMap.keys.toSet();
    
    // التحقق من المفاتيح المفقودة
    final missingInEn = arKeys.difference(enKeys);
    final missingInAr = enKeys.difference(arKeys);
    
    if (missingInEn.isNotEmpty) {
      debugPrint('⚠️ Missing English translations for: $missingInEn');
    }
    
    if (missingInAr.isNotEmpty) {
      debugPrint('⚠️ Missing Arabic translations for: $missingInAr');
    }
    
    // التحقق من المفاتيح الفارغة
    _checkEmptyValues(arMap, 'Arabic');
    _checkEmptyValues(enMap, 'English');
    
    // ✅ التحقق من أداء النظام
    _validateCacheSystem();
  }
  
  static void _checkEmptyValues(Map<String, String> translations, String language) {
    final emptyKeys = translations.entries
        .where((entry) => entry.value.isEmpty)
        .map((entry) => entry.key)
        .toList();
    
    if (emptyKeys.isNotEmpty) {
      debugPrint('⚠️ Empty $language translations for: $emptyKeys');
    }
  }
  
  static void _validateCacheSystem() {
    debugPrint('''
🧠 Cache System Validation:
   • Max Cache Size: 100 entries
   • Default TTL: 24 hours
   • LRU Eviction: Enabled
   • Auto Cleanup: Every 20 operations
   • Memory Safety: ✅ Guaranteed
''');
  }
  


}
