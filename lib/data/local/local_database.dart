// lib/data/local/local_database.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:al_faw_zakho/core/cache/prefs_manager.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/core/services/performance_tracker.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';
import 'package:al_faw_zakho/data/models/office_model.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// 🗄️ قاعدة البيانات المحلية - النسخة المحسنة مع Type Safety
class LocalDatabase {
  // ============================
  //    🔧 التهيئة والإعداد
  // ============================

  // الصناديق المحددة النوع
  static late final Box<String> _appBox;
  static late final Box<List<Map<String, dynamic>>> _candidatesBox;
  static late final Box<List<Map<String, dynamic>>> _faqBox;
  static late final Box<List<Map<String, dynamic>>> _newsBox;
  static late final Box<List<Map<String, dynamic>>> _officesBox;

  static bool _isInitialized = false;
  static Completer<void>? _initCompleter;

  // مفاتيح التخزين
  static const String _candidatesKey = 'all_candidates';
  static const String _officesKey = 'all_offices';
  static const String _newsKey = 'all_news';
  static const String _faqsKey = 'all_faqs';

  // إعدادات النسق والأمان
  static const int _schemaVersion = 4; // ⬆️ زيادة بسبب تغيير النوع
  static const int _maxFallbackSize = 1024 * 1024; // 1MB
  static const int _timeoutSeconds = 10;
  static const int _maxNewsItems = 25;

  // أنظمة الطوارئ
  static bool _useFallbackStorage = false;
  static bool _fallbackInitialized = false;

  // ============================
  //    🎯 الواجهة العامة
  // ============================

  /// 🚀 تهيئة قاعدة البيانات مع Type Safety
  static Future<void> init() async {
    final Stopwatch sw = Stopwatch()..start();

    if (_isInitialized) {
      PerformanceTracker.track('LocalDatabase_Init_Cached', sw.elapsed);
      return;
    }

    _initCompleter ??= Completer<void>();
    if (_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    try {
      // 1️⃣ تهيئة PrefsManager أولاً
      await PrefsManager.init();

      // 2️⃣ تهيئة Hive
      await Hive.initFlutter();

      // 3️⃣ التحقق من ترقية النسق
      final int localVersion = PrefsManager.getInt('db_schema_version') ?? 0;
      if (localVersion < _schemaVersion) {
        await _hardReset();
        await PrefsManager.saveInt('db_schema_version', _schemaVersion);
      }

      // 4️⃣ فتح الصناديق بنوعية آمنة
      await _initializeHiveWithTypeSafety();

      // 5️⃣ أنظمة الطوارئ والبيانات الأولية
      await _initializeFallbackSystem();
      await _loadFAQsFromAssetsIfNeeded();
      await _seedIfEmpty();

      _initCompleter!.complete();

      AnalyticsService.trackEvent(
        'LocalDatabase_Initialized_TypeSafe',
        parameters: {
          'box_count': 5,
          'schema_version': _schemaVersion,
          'fallback_enabled': _fallbackInitialized,
        },
      );

      developer.log(
        '✅ LocalDatabase initialized with Type Safety (v$_schemaVersion)',
        name: 'CACHE',
      );
    } catch (e, stack) {
      developer.log(
        '❌ Database init failed: $e',
        name: 'CACHE',
        error: e,
        stackTrace: stack,
      );

      await _emergencyFallbackInitialization(e);
      _initCompleter!.completeError(e);
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Init', sw.elapsed);
    }

    return _initCompleter!.future;
  }

  // ============================
  //    💾 عمليات الحفظ
  // ============================

  /// 💾 حفظ المرشحين
  static Future<void> saveCandidates(List<CandidateModel> candidates) async {
    final List<Map<String, dynamic>> data = candidates
        .map((candidate) => candidate.toJson())
        .toList(growable: false);

    await _saveList<CandidateModel>(
      _candidatesBox,
      _candidatesKey,
      data,
      'Candidates',
    );
  }

  /// 💾 حفظ الأسئلة الشائعة
  static Future<void> saveFAQs(List<FaqModel> faqs) async {
    final List<Map<String, dynamic>> data =
        faqs.map((faq) => faq.toJson()).toList(growable: false);

    await _saveList<FaqModel>(_faqBox, _faqsKey, data, 'FAQs');
  }

  /// 💾 حفظ الأخبار مع التشذيب التلقائي
  static Future<void> saveNews(List<NewsModel> newsList) async {
    final List<Map<String, dynamic>> data =
        newsList.map((news) => news.toJson()).toList(growable: false);

    await _saveList<NewsModel>(_newsBox, _newsKey, data, 'News');
    await _pruneOldNewsKeepLatest();
  }

  /// 💾 حفظ بيانات التطبيق العامة
  static Future<void> saveAppData(String key, String value) async {
    await _ensureInitialized();
    await _appBox.put(key, value);
  }

  // ============================
  //    📥 عمليات القراءة
  // ============================

  /// 📥 جلب المرشحين
  static List<CandidateModel> getCandidates() {
    final List<Map<String, dynamic>> rawList =
        _getList<CandidateModel>(_candidatesBox, _candidatesKey, 'Candidates');

    final List<CandidateModel> candidates = <CandidateModel>[];
    int fixedCount = 0;

    for (final Map<String, dynamic> item in rawList) {
      try {
        // إصلاح البيانات القديمة
        final Map<String, dynamic> fixedItem = Map<String, dynamic>.from(item)
          ..['province'] ??= 'غير محدد'
          ..['fullNameAr'] ??=
              '${item['nameAr'] ?? ''} ${item['nicknameAr'] ?? ''}'.trim();

        candidates.add(CandidateModel.fromJson(fixedItem));
        fixedCount++;
      } catch (e) {
        developer.log('⚠️ تجاهل سجل مرشح تالف: $e', name: 'CACHE');
      }
    }

    if (fixedCount > 0) {
      developer.log('♻️ تم إصلاح $fixedCount من سجلات المرشحين', name: 'CACHE');
      saveCandidates(candidates);
    }

    return candidates;
  }

  /// 📥 جلب الأسئلة الشائعة
  static List<FaqModel> getFAQs() {
    final List<Map<String, dynamic>> rawList =
        _getList<FaqModel>(_faqBox, _faqsKey, 'FAQs');

    final List<FaqModel> faqs = rawList
        .map((Map<String, dynamic> item) => FaqModel.fromJson(item))
        .toList(growable: false);

    // الترتيب حسب الأهمية والتاريخ
    faqs.sort((FaqModel a, FaqModel b) {
      final int byImportance = b.importance.compareTo(a.importance);
      return byImportance != 0
          ? byImportance
          : b.createdAt.compareTo(a.createdAt);
    });

    return faqs;
  }

  /// 📥 جلب الأخبار
  static Future<List<NewsModel>> getNews() async {
    final List<Map<String, dynamic>> rawList =
        _getList<NewsModel>(_newsBox, _newsKey, 'News');

    final List<NewsModel> newsList = <NewsModel>[];
    bool hasCorrections = false;
    int fixedCount = 0;

    for (final Map<String, dynamic> item in rawList) {
      try {
        final Map<String, dynamic> fixedItem = _fixNewsItem(item);
        if (fixedItem != item) {
          hasCorrections = true;
          fixedCount++;
        }
        newsList.add(NewsModel.fromJson(fixedItem));
      } catch (e) {
        developer.log('⚠️ تجاهل سجل خبر تالف: $e', name: 'CACHE');
      }
    }

    if (hasCorrections) {
      developer.log('♻️ تم إصلاح $fixedCount من سجلات الأخبار', name: 'CACHE');
      await saveNews(newsList);
    }

    return newsList;
  }

  /// 📥 جلب المكاتب
  static List<OfficeModel> getOffices() {
    final List<Map<String, dynamic>> rawList =
        _getList<OfficeModel>(_officesBox, _officesKey, 'Offices');

    return rawList
        .map((Map<String, dynamic> item) => OfficeModel.fromJson(item))
        .toList(growable: false);
  }

  /// 📥 جلب بيانات التطبيق
  static String? getAppData(String key) {
    if (!_isInitialized) return null;
    return _appBox.get(key);
  }

  // ============================
  //    🧹 عمليات التنظيف
  // ============================

  static Future<void> clearCandidates() async => await _candidatesBox.clear();
  static Future<void> clearFAQs() async => await _faqBox.clear();
  static Future<void> clearNews() async => await _newsBox.clear();
  static Future<void> clearOffices() async => await _officesBox.clear();

  /// 🧹 تنظيف كامل
  static Future<void> clearAll() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      if (_isInitialized && !_useFallbackStorage) {
        await Future.wait(
          <Future<void>>[
            _appBox.clear(),
            _candidatesBox.clear(),
            _faqBox.clear(),
            _newsBox.clear(),
            _officesBox.clear(),
          ],
          eagerError: true,
        );
      }

      if (_fallbackInitialized) {
        const List<String> keys = <String>[
          _candidatesKey,
          _faqsKey,
          _newsKey,
          _officesKey,
          'mock_data_generated',
          'mock_data_timestamp',
        ];

        await Future.wait(
          keys.map((String key) => PrefsManager.remove(key)),
          eagerError: true,
        );
      }

      AnalyticsService.trackEvent('Cache_Cleared_All');
      developer.log('🗑️ All cache data cleared', name: 'CACHE');
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Clear_All', sw.elapsed);
    }
  }

  // ============================
  //    ⚙️ دوال مساعدة داخلية
  // ============================

  /// 🔧 تهيئة Hive مع Type Safety
  static Future<void> _initializeHiveWithTypeSafety() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      final String dir = (await getApplicationDocumentsDirectory()).path;
      await Hive.initFlutter(dir);

      // تسجيل المحولات
      Hive.registerAdapter(OfficeModelAdapter());
      Hive.registerAdapter(CandidateModelAdapter());
      Hive.registerAdapter(NewsModelAdapter());
      Hive.registerAdapter(FaqModelAdapter());

      // إصلاح البيانات القديمة
      await _migrateAndRepairNewsBox();

      // فتح الصناديق بنوعية آمنة
      final List<Box<dynamic>> boxes = await _openBoxesWithTypeSafety();

      _appBox = boxes[0] as Box<String>;
      _candidatesBox = boxes[1] as Box<List<Map<String, dynamic>>>;
      _faqBox = boxes[2] as Box<List<Map<String, dynamic>>>;
      _newsBox = boxes[3] as Box<List<Map<String, dynamic>>>;
      _officesBox = boxes[4] as Box<List<Map<String, dynamic>>>;

      _isInitialized = true;
      _useFallbackStorage = false;

      AnalyticsService.trackEvent('Hive_TypeSafe_Initialization_Success');
      developer.log('✅ Hive initialized with Type Safety', name: 'CACHE');
    } catch (e, stack) {
      developer.log(
        '❌ Hive init failed: $e',
        name: 'CACHE',
        error: e,
        stackTrace: stack,
      );
      await _handleInitializationFallback(e);
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Hive_Init', sw.elapsed);
    }
  }

  /// ⚡ فتح الصناديق بنوعية آمنة
  static Future<List<Box<dynamic>>> _openBoxesWithTypeSafety() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      final List<Future<Box<dynamic>>> boxFutures = <Future<Box<dynamic>>>[
        Hive.openBox<String>('app_data').then((Box<String> box) => box),
        Hive.openBox<List<Map<String, dynamic>>>('candidates')
            .then((Box<List<Map<String, dynamic>>> box) => box),
        Hive.openBox<List<Map<String, dynamic>>>('faqs')
            .then((Box<List<Map<String, dynamic>>> box) => box),
        Hive.openBox<List<Map<String, dynamic>>>('news')
            .then((Box<List<Map<String, dynamic>>> box) => box),
        Hive.openBox<List<Map<String, dynamic>>>('offices')
            .then((Box<List<Map<String, dynamic>>> box) => box),
      ];

      final List<Box<dynamic>> results = await Future.wait(boxFutures)
          .timeout(const Duration(seconds: _timeoutSeconds));

      AnalyticsService.trackEvent('Boxes_Opened_TypeSafe');
      return results;
    } on TimeoutException {
      developer.log('⚠️ Parallel open timed out', name: 'CACHE');
      return await _fallbackSequentialInit();
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Boxes_Open', sw.elapsed);
    }
  }

  /// 🐌 الفتح التسلسلي كبديل
  static Future<List<Box<dynamic>>> _fallbackSequentialInit() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      final List<Box<dynamic>> boxes = <Box<dynamic>>[
        await Hive.openBox<String>('app_data'),
        await Hive.openBox<List<Map<String, dynamic>>>('candidates'),
        await Hive.openBox<List<Map<String, dynamic>>>('faqs'),
        await Hive.openBox<List<Map<String, dynamic>>>('news'),
        await Hive.openBox<List<Map<String, dynamic>>>('offices'),
      ];

      AnalyticsService.trackEvent('Boxes_Opened_Sequential');
      return boxes;
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Sequential_Fallback', sw.elapsed);
    }
  }

  /// 💾 حفظ عام مع Type Safety
  static Future<void> _saveList<T>(
    Box<List<Map<String, dynamic>>> box,
    String key,
    List<Map<String, dynamic>> data,
    String label,
  ) async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      await _ensureInitialized();

      if (!_useFallbackStorage) {
        try {
          await box.put(key, data);
          await _saveToSharedPrefsFallback(key, data);
        } catch (e) {
          await _saveToSharedPrefsFallback(key, data);
          _useFallbackStorage = true;
        }
      } else {
        await _saveToSharedPrefsFallback(key, data);
      }

      AnalyticsService.trackEvent('${label}_Saved');
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Save_$label', sw.elapsed);
    }
  }

  /// 📥 قراءة عامة مع Type Safety
  static List<Map<String, dynamic>> _getList<T>(
    Box<List<Map<String, dynamic>>> box,
    String key,
    String label,
  ) {
    final Stopwatch sw = Stopwatch()..start();
    try {
      if (!_isInitialized) return <Map<String, dynamic>>[];

      List<Map<String, dynamic>> result;
      if (!_useFallbackStorage) {
        try {
          result = box.get(key, defaultValue: <Map<String, dynamic>>[])!;
        } catch (e) {
          result = _getFromSharedPrefsFallback(key) ?? <Map<String, dynamic>>[];
          _useFallbackStorage = true;
        }
      } else {
        result = _getFromSharedPrefsFallback(key) ?? <Map<String, dynamic>>[];
      }

      AnalyticsService.trackEvent('${label}_Retrieved');
      return result;
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Get_$label', sw.elapsed);
    }
  }

  /// 🔧 إصلاح عنصر الأخبار
  static Map<String, dynamic> _fixNewsItem(Map<String, dynamic> item) {
    final Map<String, dynamic> fixed = Map<String, dynamic>.from(item);

    // إصلاح تاريخ النشر
    final dynamic publishDate = fixed['publishDate'] ?? fixed['publish_date'];
    if (publishDate is int) {
      fixed['publish_date'] =
          DateTime.fromMillisecondsSinceEpoch(publishDate).toIso8601String();
    } else if (publishDate is DateTime) {
      fixed['publish_date'] = publishDate.toIso8601String();
    } else if (publishDate is! String || (publishDate).isEmpty) {
      fixed['publish_date'] = DateTime.now().toIso8601String();
    }

    // توحيد المفاتيح
    final Map<String, String> keyMappings = <String, String>{
      'titleAr': 'title_ar',
      'titleEn': 'title_en',
      'contentAr': 'content_ar',
      'contentEn': 'content_en',
      'imagePath': 'image_url',
    };

    for (final MapEntry<String, String> entry in keyMappings.entries) {
      if (fixed.containsKey(entry.key)) {
        fixed[entry.value] = fixed.remove(entry.key);
      }
    }

    return fixed;
  }

  /// ✂️ تشذيب الأخبار القديمة
  static Future<void> _pruneOldNewsKeepLatest() async {
    final List<Map<String, dynamic>> raw =
        _getList<NewsModel>(_newsBox, _newsKey, 'News');

    if (raw.length <= _maxNewsItems) return;

    final List<NewsModel> newsList = raw
        .map((Map<String, dynamic> item) => NewsModel.fromJson(item))
        .toList()
      ..sort(
        (NewsModel a, NewsModel b) => b.publishDate.compareTo(a.publishDate),
      );

    final List<NewsModel> keep =
        newsList.take(_maxNewsItems).toList(growable: false);
    await saveNews(keep);

    developer.log(
      '✂️ تشذيب الأخبار: ${newsList.length} → $_maxNewsItems',
      name: 'CACHE',
    );
  }

  // ============================
  //    🚨 أنظمة الطوارئ
  // ============================

  static Future<void> _initializeFallbackSystem() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      // اختبار نظام الطوارئ
      final Map<String, dynamic> probe = <String, dynamic>{
        't': DateTime.now().millisecondsSinceEpoch,
      };
      await PrefsManager.saveString('fallback_test', json.encode(probe));
      final String? ok = PrefsManager.getString('fallback_test');
      _fallbackInitialized = ok != null;

      if (_fallbackInitialized) {
        AnalyticsService.trackEvent('Fallback_System_Initialized');
        developer.log('✅ Fallback system ready', name: 'FALLBACK');
      }
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Init', sw.elapsed);
    }
  }

  static Future<void> _handleInitializationFallback(Object error) async {
    developer.log('🔥 Hive init failed, switching to fallback', name: 'CACHE');
    try {
      await _initializeFallbackSystem();
      _isInitialized = true;
      _useFallbackStorage = true;
      AnalyticsService.trackEvent('Fallback_Storage_Activated');
    } catch (e) {
      await _cleanAndRetry();
    }
  }

  static Future<void> _emergencyFallbackInitialization(dynamic error) async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      await _initializeFallbackSystem();
      if (_fallbackInitialized) {
        _useFallbackStorage = true;
        _isInitialized = true;
        AnalyticsService.trackEvent('Emergency_Fallback_Activated');
        developer.log('🚨 Emergency fallback activated', name: 'FALLBACK');
      }
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Emergency_Fallback', sw.elapsed);
    }
  }

  // ============================
  //    📦 أنظمة البيانات الأولية
  // ============================

  /// 🌱 تحميل البيانات الأولية من الـ Assets
  static Future<void> _seedIfEmpty() async {
    try {
      final bool needCandidates = _candidatesBox.get(_candidatesKey) == null;
      final bool needOffices = _officesBox.get(_officesKey) == null;
      final bool needNews = _newsBox.get(_newsKey) == null;
      final bool needFaqs = _faqBox.get(_faqsKey) == null;

      if (!(needCandidates || needOffices || needFaqs || needNews)) {
        developer.log('✅ جميع الصناديق تحتوي بيانات', name: 'SEED');
        return;
      }

      developer.log('📦 بدء تحميل البيانات الأولية', name: 'SEED');

      // تحميل البيانات المطلوبة فقط
      final List<Future<void>> loadTasks = <Future<void>>[];

      if (needCandidates) {
        loadTasks.add(_loadAndSaveCandidates());
      }
      if (needOffices) {
        loadTasks.add(_loadAndSaveOffices());
      }
      if (needFaqs) {
        loadTasks.add(_loadAndSaveFAQs());
      }
      if (needNews) {
        loadTasks.add(_loadAndSaveNews());
      }

      await Future.wait(loadTasks, eagerError: true);
      developer.log('✅ تم تحميل البيانات الأولية بنجاح', name: 'SEED');
    } catch (e, stack) {
      developer.log(
        '❌ فشل تحميل البيانات الأولية: $e',
        name: 'SEED',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static Future<void> _loadAndSaveCandidates() async {
    final list = await _loadJson('assets/data/candidates.json');
    if (list.isNotEmpty) {
      final candidates = list
          .whereType<Map<String, dynamic>>() // ✅ نوع صريح
          .map(CandidateModel.fromJson) // ✅ بدون cast زائد
          .toList(growable: false);
      await saveCandidates(candidates);
    }
  }

  static Future<void> _loadAndSaveFAQs() async {
    final list = await _loadJson('assets/data/faqs.json');
    if (list.isNotEmpty) {
      final faqs = list
          .whereType<Map<String, dynamic>>() // ✅
          .map(FaqModel.fromJson) // ✅
          .toList(growable: false);
      await saveFAQs(faqs);
    }
  }

  static Future<void> _loadAndSaveNews() async {
    final list = await _loadJson('assets/data/news.json');
    if (list.isNotEmpty) {
      final news = list
          .whereType<Map<String, dynamic>>() // ✅
          .map(NewsModel.fromJson) // ✅
          .toList(growable: false);
      await saveNews(news);
    }
  }

  static Future<void> _loadAndSaveOffices() async {
    final list = await _loadJson('assets/data/offices.json');
    if (list.isNotEmpty) {
      final offices = list
          .whereType<Map<String, dynamic>>() // ✅
          .toList(growable: false);
      await _saveList<OfficeModel>(
        _officesBox,
        _officesKey,
        offices,
        'Offices',
      );
    }
  }

  /// 📋 تحميل JSON من Assets
  static Future<List<dynamic>> _loadJson(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      final dynamic data = json.decode(jsonString);
      return data is List ? data : <dynamic>[];
    } catch (e) {
      developer.log('⚠️ فشل تحميل $path: $e', name: 'SEED');
      return <dynamic>[];
    }
  }

  /// 📥 تحميل الأسئلة الشائعة من Assets عند الحاجة
  static Future<void> _loadFAQsFromAssetsIfNeeded() async {
    final sw = Stopwatch()..start();
    try {
      if (!_faqBox.isOpen) return;

      if (_faqBox.isEmpty) {
        final jsonString = await rootBundle.loadString('assets/data/faqs.json');
        final decoded = json.decode(jsonString) as List<dynamic>;

        final faqs = decoded
            .whereType<Map<String, dynamic>>() // ✅ المهم هنا
            .map(FaqModel.fromJson) // ✅
            .toList(growable: false);

        await saveFAQs(faqs);
        developer.log('✅ تم تحميل ${faqs.length} سؤال شائع', name: 'LOCAL_DB');
      }
    } catch (e, stack) {
      developer.log(
        '❌ فشل تحميل الأسئلة الشائعة: $e',
        name: 'LOCAL_DB',
        error: e,
        stackTrace: stack,
      );
    } finally {
      sw.stop();
      PerformanceTracker.track(
        'LocalDatabase_Load_FAQs_From_Assets',
        sw.elapsed,
      );
    }
  }

  // ============================
  //    🛠️ أدوات الصيانة
  // ============================

  /// 🧨 إعادة ضبط كاملة
  static Future<void> _hardReset() async {
    const List<String> names = <String>[
      'app_data',
      'candidates',
      'offices',
      'faqs',
      'news',
    ];

    for (final String name in names) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).close(); // ✅ حدّد النوع
      }

      await Hive.deleteBoxFromDisk(name);
    }
    developer.log('🧨 Hard reset: جميع الصناديق محذوفة', name: 'CACHE');
  }

  /// 🩺 إصلاح صندوق الأخبار
  static Future<void> _migrateAndRepairNewsBox() async {
    try {
      if (!await Hive.boxExists('news')) return;

      final Box<dynamic> tempBox =
          await Hive.openBox('news', crashRecovery: true);
      final dynamic rawData = tempBox.get(_newsKey);

      if (rawData is! List) {
        await tempBox.close();
        return;
      }

      final List<Map<String, dynamic>> fixedList = <Map<String, dynamic>>[];
      int correctedCount = 0;

      for (final dynamic item in rawData) {
        if (item is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item);
          fixedList.add(_fixNewsItem(map));
          correctedCount++;
        }
      }

      await tempBox.close();
      await Hive.deleteBoxFromDisk('news');

      final Box<List<Map<String, dynamic>>> newBox =
          await Hive.openBox<List<Map<String, dynamic>>>('news');
      await newBox.put(_newsKey, fixedList);
      await newBox.close();

      developer.log(
        '✅ تم إصلاح صندوق الأخبار ($correctedCount عنصر)',
        name: 'MIGRATION',
      );
    } catch (e, stack) {
      developer.log(
        '❌ فشل إصلاح الأخبار: $e',
        name: 'MIGRATION',
        error: e,
        stackTrace: stack,
      );
    }
  }

  // ============================
  //    🔄 دوال الطوارئ
  // ============================

  static Future<void> _saveToSharedPrefsFallback(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      if (!_fallbackInitialized) throw Exception('Fallback not initialized');

      final String encoded = json.encode(data);
      if (encoded.length > _maxFallbackSize) {
        throw Exception('Data too large for fallback');
      }

      await PrefsManager.saveString(key, encoded);
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Save', sw.elapsed);
    }
  }

  static List<Map<String, dynamic>>? _getFromSharedPrefsFallback(String key) {
    final Stopwatch sw = Stopwatch()..start();
    try {
      if (!_fallbackInitialized) return null;

      final String? encoded = PrefsManager.getString(key);
      if (encoded == null) return null;

      final dynamic decoded = json.decode(encoded);
      return decoded is List ? decoded.cast<Map<String, dynamic>>() : null;
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Get', sw.elapsed);
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  static Future<void> _cleanAndRetry() async {
    try {
      await Hive.close();
      await _hardReset();
    } catch (e) {
      developer.log('⚠️ فشل التنظيف: $e', name: 'CACHE');
    }

    _isInitialized = false;
    _initCompleter = null;
    await init();
  }

  // ============================
  //    📊 الجetters والإحصائيات
  // ============================

  static Map<String, dynamic> getStorageStatus() {
    return <String, dynamic>{
      'hive_initialized': _isInitialized,
      'fallback_initialized': _fallbackInitialized,
      'using_fallback': _useFallbackStorage,
      'schema_version': _schemaVersion,
      'storage_type': _useFallbackStorage ? 'shared_preferences' : 'hive',
    };
  }

  /// 🔒 إغلاق قاعدة البيانات
  static Future<void> close() async {
    final Stopwatch sw = Stopwatch()..start();
    try {
      if (_isInitialized) {
        await Hive.close();
        _isInitialized = false;
        _initCompleter = null;
        _useFallbackStorage = false;
        AnalyticsService.trackEvent('Database_Closed');
        developer.log('🔒 Database closed', name: 'CACHE');
      }
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Close', sw.elapsed);
    }
  }
}
