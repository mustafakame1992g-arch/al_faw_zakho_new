// lib/data/local/local_database.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:al_faw_zakho/data/repositories/faq_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/core/services/performance_tracker.dart';
import 'package:al_faw_zakho/core/cache/prefs_manager.dart';

// النماذج + الـ Adapters
import 'package:al_faw_zakho/data/models/office_model.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';


class LocalDatabase {
  // الصناديق
  static late Box _appBox;
  static late Box _candidatesBox;
  static late Box _faqBox;
  static late Box _newsBox;
  static late Box _officesBox;

  static bool _isInitialized = false;
  static Completer<void>? _initCompleter;

  // مفاتيح التخزين داخل الصناديق
  static const String _candidatesKey = 'all_candidates';
  static const String _officesKey   = 'all_offices';
  static const String _newsKey      = 'all_news';
  static const String _faqsKey      = 'all_faqs';

  // Fallback (SharedPreferences) flags
  static bool _useFallbackStorage = false;
  static bool _fallbackInitialized = false;
  static const int _maxFallbackSize = 1024 * 1024; // 1MB per key

  // إدارة النسخة (Schema) – عند رفعها، نعمل حذف قاسٍ للصناديق القديمة
  static const int _schemaVersion = 3;

  // Getters
  static Box get appBox        => _appBox;
  static Box get candidatesBox => _candidatesBox;
  static Box get faqBox        => _faqBox;
  static Box get newsBox       => _newsBox;
  static Box get officesBox    => _officesBox;
  static bool get useFallbackStorage => _useFallbackStorage;

// أمثلة مساعدة لفتح الصناديق إن لم تكن موجودة لديك بنفس الأسماء
static const _appDataBoxName = 'app_data';
static const _candidatesBoxName = 'candidates';
static const _faqBoxName = 'faqs';

static Future<Box> _openAppData() async => await Hive.openBox(_appDataBoxName);
static Future<Box> _openCandidates() async => await Hive.openBox(_candidatesBoxName);
static Future<Box> _openFaqs() async => await Hive.openBox(_faqBoxName);
static Future<Box> _openNews() async => await Hive.openBox('news');
static Future<Box> _openOffices() async => await Hive.openBox('offices');


/// يعيد ضبط الأخبار ويزرعها من assets/data/news.json (قراءة واحدة نظيفة)
/// إعادة ملء الأخبار من assets/data/news.json بأمان
static Future<void> ensureFreshNewsFromAssets() async {
  await _ensureInitialized(); // 👈 لا شيء قبل التهيئة

  // 1) نظّف المخزون القديم
  try {
    if (!Hive.isBoxOpen('news')) {
      await Hive.openBox('news');
    }
    await Hive.box('news').clear();
  } catch (_) {}
  await PrefsManager.remove(_newsKey);
  debugPrint('🧹 [NEWS] Cleared Hive + fallback for $_newsKey');

  // 2) اقرأ من الأصول واحفظ
  try {
    final raw = await rootBundle.loadString('assets/data/news.json');
    final List<dynamic> arr = jsonDecode(raw) as List<dynamic>;
    if (arr.isEmpty) {
      debugPrint('⚠️ [NEWS] assets/data/news.json is empty.');
      return;
    }

    final items = arr
        .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // 👈 هذا يستدعي _saveList ويطبق حدّ 25 عبر pruneOldNewsKeepLatest
    await saveNews(items);

    debugPrint('✅ [NEWS] Seeded ${items.length} items from assets under $_newsKey');
  } catch (e) {
    debugPrint('❌ [NEWS] ensureFreshNewsFromAssets failed: $e');
  }
}


/// تنظيف الأخبار من Hive و SharedPreferences بشكل آمن
static Future<void> clearNewsEverywhere() async {
  await _ensureInitialized(); // 👈 يضمن أن init() تم

  try {
    if (!Hive.isBoxOpen('news')) {
      await Hive.openBox('news');
    }
    await Hive.box('news').clear();
  } catch (e) {
    debugPrint('clearNewsEverywhere hive error: $e');
  }

  await PrefsManager.remove(_newsKey);
  debugPrint('🧹 Cleared news from Hive and fallback.');
}


// 🧩 نظام إصلاح ذكي ومحترف لصندوق الأخبار — يعمل تلقائياً فقط عند اكتشاف خلل
static Future<void> migrateAndRepairNewsBox() async {
  try {
    developer.log('🩺 Checking integrity of news box...', name: 'MIGRATION');

    if (!await Hive.boxExists('news')) {
      developer.log('ℹ️ No existing news box found — nothing to migrate', name: 'MIGRATION');
      return;
    }

    // نفتح الصندوق مؤقتاً بشكل آمن بدون Adapter
    final tempBox = await Hive.openBox('news', crashRecovery: true);
    final dynamic rawData = tempBox.get(_newsKey);

    if (rawData == null || rawData is! List) {
      developer.log('ℹ️ Empty or invalid news data — skipping repair', name: 'MIGRATION');
      await tempBox.close();
      return;
    }

    final fixedList = <Map<String, dynamic>>[];
    int correctedCount = 0;

    for (final item in rawData) {
      if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final publishDate = map['publishDate'] ?? map['publish_date'];

        // 🧠 تصحيح ذكي لجميع الصيغ الممكنة
        if (publishDate is int) {
          map['publish_date'] = DateTime.fromMillisecondsSinceEpoch(publishDate).toIso8601String();
          correctedCount++;
        } else if (publishDate is DateTime) {
          map['publish_date'] = publishDate.toIso8601String();
          correctedCount++;
        } else if (publishDate is! String || publishDate.toString().isEmpty) {
          map['publish_date'] = DateTime.now().toIso8601String();
          correctedCount++;
        }

        // تصحيح مفاتيح التسمية (من camelCase إلى snake_case)
        if (map.containsKey('titleAr')) {
          map['title_ar'] = map.remove('titleAr');
          correctedCount++;
        }
        if (map.containsKey('titleEn')) {
          map['title_en'] = map.remove('titleEn');
          correctedCount++;
        }
        if (map.containsKey('contentAr')) {
          map['content_ar'] = map.remove('contentAr');
          correctedCount++;
        }
        if (map.containsKey('contentEn')) {
          map['content_en'] = map.remove('contentEn');
          correctedCount++;
        }
        if (map.containsKey('imagePath')) {
          map['image_url'] = map.remove('imagePath');
          correctedCount++;
        }

        fixedList.add(map);
      }
    }

    // إغلاق القديم
    await tempBox.close();
    await Hive.deleteBoxFromDisk('news');

    // إعادة بناء الصندوق بصيغة سليمة
    final newBox = await Hive.openBox('news');
    await newBox.put(_newsKey, fixedList);
    await newBox.close();

    developer.log(
      '✅ News box migrated successfully ($correctedCount field fixes applied)',
      name: 'MIGRATION',
    );
  } catch (e, stack) {
    developer.log('❌ Migration failed: $e', name: 'MIGRATION', error: e, stackTrace: stack);
  }

  
}





// حفظ قيمة عامة في app_data (مثلاً last_update)
static Future<void> saveAppData(String key, dynamic value) async {
  final box = await _openAppData();
  await box.put(key, value);
}


// مسح المرشحين بالكامل
static Future<void> clearCandidates() async {
  final box = await _openCandidates();
  await box.clear();
}

static Future<void> clearNews() async {
  final box = await _openNews();
  await box.clear();
}


static Future<void> clearOffices() async {
  final box = await _openOffices();
  await box.clear();
}


// مسح الأسئلة الشائعة بالكامل
static Future<void> clearFAQs() async {
  final box = await _openFaqs();
  await box.clear();
}



  static dynamic getAppData(String key) {
    if (!_isInitialized) return null;
    return _appBox.get(key);
  }

  

  // ============================
  //      Public API
  // ============================
  static Future<void> init() async {
    final sw = Stopwatch()..start();

    if (_isInitialized) {
      PerformanceTracker.track('LocalDatabase_Init_Cached', sw.elapsed);
      return;
    }

    _initCompleter ??= Completer<void>();
    if (_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    try {
      // ضروري قبل أي استخدام للـ PrefsManager       // 1️⃣ تهيئة PrefsManager أولًا
      await PrefsManager.init();
      // 2️⃣ تأكد من تهيئة Hive قبل أي عملية حذف أو فتح
    await Hive.initFlutter(); // ← هذا السطر هو المفتاح لحل الخطأ

      // ترقية السكيمة: حذف الصناديق القديمة إذا تغيرت النسخة
      final localVersion = PrefsManager.getInt('db_schema_version') ?? 0;
      if (localVersion < _schemaVersion) {
        await hardReset(); // حذف الصناديق من القرص
        await PrefsManager.saveInt('db_schema_version', _schemaVersion);
      }

    // 4️⃣ الآن افتح الصناديق كلها
      await _initializeHiveWithImprovements(); // يفتح الصناديق
        // 5️⃣ تهيئة الأسئلة الشائعة + Fallback + Seed
      await loadFAQsFromAssetsIfNeeded(); // ✅ إضافة هنا
      await _initializeFallbackSystem();       // يجهّز الـ SharedPrefs كـ Fallback
      // لو الصناديق فاضية أول تشغيل، إملها من AdvancedMockService
      await _seedIfEmpty();

      _initCompleter!.complete();

      AnalyticsService.trackEvent('LocalDatabase_Initialized_Parallel', parameters: {
        'box_count': 5,
        'method': 'parallel',
        'fallback_enabled': _fallbackInitialized,
      });

      developer.log('✅ LocalDatabase initialized: 5 boxes, fallback=$_fallbackInitialized',
          name: 'CACHE');
    } catch (e) {
      AnalyticsService.trackEvent('LocalDatabase_Init_Failed',
          parameters: {'error': e.toString(), 'method': 'parallel'});

      // محاولة طوارئ لاستخدام fallback فقط
      await _emergencyFallbackInitialization(e);
      _initCompleter!.completeError(e);
      rethrow;
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Init', sw.elapsed);
    }

    return _initCompleter!.future;
  }

  /// حذف قاسٍ لكل الصناديق (للاستخدام عند تغيير السكيمة)
  static Future<void> hardReset() async {
    final names = ['app_data', 'candidates', 'offices', 'faqs', 'news'];

    
    for (final n in names) {
      if (Hive.isBoxOpen(n)) await Hive.box(n).close();
      await Hive.deleteBoxFromDisk(n);
    }
    developer.log('🧨 Hard reset: boxes deleted from disk', name: 'CACHE');
  }

  static Future<void> clearAll() async {
    final sw = Stopwatch()..start();
    try {
      if (_isInitialized && !_useFallbackStorage) {
        await _appBox.clear();
        await _candidatesBox.clear();
        await _faqBox.clear();
        await _newsBox.clear();
        await _officesBox.clear();
      }
      if (_fallbackInitialized) {
        final keys = [
          _candidatesKey, _faqsKey, _newsKey, _officesKey,
          'mock_data_generated', 'mock_data_timestamp'
        ];
        for (final k in keys) {
          await PrefsManager.remove(k);
        }
      }
      AnalyticsService.trackEvent('Cache_Cleared_All');
      developer.log('🗑️ All cache data cleared', name: 'CACHE');
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Clear_All', sw.elapsed);
    }
  }

  static Future<void> close() async {
    final sw = Stopwatch()..start();
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

  // واجهة موحّدة للحفظ/الجلب مع fallback
  static Future<void> saveCandidates(List<dynamic> v) async => _saveList(_candidatesBox, _candidatesKey, v, 'Candidates');
  

// 📥 جلب المرشحين وتحويلهم إلى CandidateModel بشكل آمن
static List<CandidateModel> getCandidates() {
  final rawList = _getList(_candidatesBox, _candidatesKey, 'Candidates');
  if (rawList.isEmpty) return [];

  final List<CandidateModel> candidates = [];
  int fixedCount = 0;

  for (final e in rawList) {
    try {
      // لو العنصر فعلاً كائن CandidateModel
      if (e is CandidateModel) {
        candidates.add(e);
      } 
      // لو العنصر Map (كما في fallback أو JSON)
      else if (e is Map) {
        final map = Map<String, dynamic>.from(e);

        // إصلاحات هيكلية ذكية (لضمان وجود province و fullNameAr)
        map['province'] ??= 'غير محدد';
        map['fullNameAr'] ??= '${map['nameAr'] ?? ''} ${map['nicknameAr'] ?? ''}'.trim();

        candidates.add(CandidateModel.fromJson(map));
        fixedCount++;
      }
    } catch (err) {
      developer.log('⚠️ تجاهل سجل مرشح تالف: $err', name: 'CACHE');
    }
  }

  if (fixedCount > 0) {
    developer.log('♻️ تم إصلاح وتحويل $fixedCount من سجلات المرشحين القديمة', name: 'CACHE');
    saveCandidates(candidates.map((c) => c.toJson()).toList());
  }

  AnalyticsService.trackEvent('Candidates_Retrieved', parameters: {
    'count': candidates.length,
    'storage_type': _useFallbackStorage ? 'fallback' : 'hive',
  });

  developer.log('✅ تم تحميل ${candidates.length} مرشح بنجاح', name: 'CACHE');
  return candidates;
}


  static Future<void> saveFAQs(List<dynamic> v) async => _saveList(_faqBox, _faqsKey, v, 'FAQs');
  static List<dynamic>  getFAQs() => _getList(_faqBox, _faqsKey, 'FAQs');



// 💾 حفظ الأخبار
// 💾 حفظ الأخبار
static Future<void> saveNews(List<NewsModel> newsList) async {
  final jsonList = newsList.map((n) => n.toJson()).toList();
  await _saveList(_newsBox, _newsKey, jsonList, 'News');
  await pruneOldNewsKeepLatest(); // ← مهم: تشذيب بعد كل حفظ   ← مهم: تطبيق سقف 25 بعد كل حفظ
}





// يحافظ على أحدث 25 خبر داخل القائمة المخزّنة تحت المفتاح _newsKey
static const int kMaxNewsItems = 25;

static Future<void> pruneOldNewsKeepLatest() async {
  // اقرأ القائمة الخام المخزّنة تحت المفتاح all_news
  final raw = _getList(_newsBox, _newsKey, 'News');
  if (raw.isEmpty) return;

  // حوّل إلى نماذج ثم فرز: الأحدث أولاً
  final list = raw
      .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e)))
      .toList()
    ..sort((a, b) => b.publishDate.compareTo(a.publishDate));

  // لو القائمة ≤ 25 ما نحتاج أي حذف
  if (list.length <= kMaxNewsItems) return;

  // احتفظ بأحدث 25 ثم احفظ القائمة من جديد تحت نفس المفتاح
  final keep = list.take(kMaxNewsItems).toList();
  await _saveList(
    _newsBox,
    _newsKey,
    keep.map((n) => n.toJson()).toList(),
    'News',
  );

  debugPrint('[PRUNE] Kept $kMaxNewsItems, removed ${list.length - kMaxNewsItems}.');
}



/// يعيد حتى [limit] عناصر للشريط: العاجل أولاً ثم الأحدث
static Future<List<NewsModel>> getTopTickerNews({int limit = 10}) async {
  final list = await getNews();
  if (list.isEmpty) return [];

  list.sort((a, b) {
    final breaking = (b.isBreaking ? 1 : 0).compareTo(a.isBreaking ? 1 : 0);
    return breaking != 0 ? breaking : b.publishDate.compareTo(a.publishDate);
  });

  return list.take(limit).toList();
}


// 📥 جلب الأخبار وتحويلها إلى NewsModel
static Future<List<NewsModel>> getNews() async {
  final rawList = _getList(_newsBox, _newsKey, 'News');
  if (rawList.isEmpty) return [];

  bool hasCorrections = false;
  int fixedCount = 0;

  try {
    final newsList = rawList.map((e) {
      final map = Map<String, dynamic>.from(e);

      var publishDate = map['publishDate'] ?? map['publish_date'];

      // 🧠 توحيد الصيغ الثلاث: int, DateTime, String
      if (publishDate is int) {
        publishDate =
            DateTime.fromMillisecondsSinceEpoch(publishDate).toIso8601String();
        map['publish_date'] = publishDate;
        hasCorrections = true;
        fixedCount++;
      } else if (publishDate is DateTime) {
        map['publish_date'] = publishDate.toIso8601String();
        hasCorrections = true;
        fixedCount++;
      } else if (publishDate is! String || publishDate.isEmpty) {
        map['publish_date'] = DateTime.now().toIso8601String();
        hasCorrections = true;
        fixedCount++;
      }

int dbgCount = 0; // ضعها أعلى الدالة كمتغيّر محلي قبل map(...)
rawList.map((e) {
  final map = Map<String, dynamic>.from(e);

  if (dbgCount < 5) {
    debugPrint('RAW KEYS: ${map.keys.toList()}');
    debugPrint('RAW titleAr=${map['titleAr']} | title_ar=${map['title_ar']} | title=${map['title']}');
    dbgCount++;
  }

  // ... (باقي كودك كما هو)
  return NewsModel.fromJson(map);
}).toList();

      return NewsModel.fromJson(map);
    }).toList();

    if (hasCorrections) {
      developer.log(
        '♻️ تم إصلاح $fixedCount من سجلات الأخبار القديمة (تصحيح نوع publish_date)',
        name: 'CACHE',
      );
      await saveNews(newsList);
    } else {
      developer.log('✅ جميع الأخبار بصيغة صحيحة ولا حاجة للإصلاح', name: 'CACHE');
    }

    return newsList;
  } catch (e, stack) {
    developer.log('⚠️ فشل قراءة الأخبار: $e',
        name: 'CACHE', error: e, stackTrace: stack);
    return [];
  }
}



static List<OfficeModel> getOffices() {
  final rawList = _getList(_officesBox, _officesKey, 'Offices');
  return rawList
      .map((e) => OfficeModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}


  /// تُستخدم إذا احتجت توليد الوهمي يدويًا
  static Future<void> generateMockData({
    int candidatesCount = 50,
    int officesCount    = 20,
    int faqsCount       = 30,
    int newsCount       = 25,
  }) async {
  }

  // ============================
  //     Internal helpers
  // ============================
// 🧩 تهيئة البيانات الحقيقية من ملفات JSON عند أول تشغيل فقط
static Future<void> _seedIfEmpty() async {
  
  try {
    final needCandidates = _candidatesBox.get(_candidatesKey) == null;
    final needOffices    = _officesBox.get(_officesKey)   == null;
    final needNews       = _newsBox.get(_newsKey)         == null;
    final needFaqs       = _faqBox.get(_faqsKey)          == null;

    // لا تعمل أي تحميل إن كانت الصناديق تحتوي بيانات بالفعل
    if (!(needCandidates || needOffices || needFaqs || needNews)) {
      developer.log('✅ جميع الصناديق تحتوي بيانات - لا حاجة للتهيئة', name: 'SEED');
      return;
    }

    developer.log('📦 بدء تهيئة البيانات الحقيقية من ملفات JSON', name: 'SEED');

    // -----------------------
    // تحميل الملفات من assets
    // -----------------------
    Future<List<dynamic>> loadJson(String path) async {
      try {
        final jsonString = await rootBundle.loadString(path);
        final data = json.decode(jsonString);
        if (data is List && data.isNotEmpty) {
          developer.log('✅ تم تحميل ${data.length} عنصر من $path', name: 'SEED');
          return data;
        }
      } catch (e) {
        developer.log('⚠️ فشل تحميل $path: $e', name: 'SEED');
      }
      return [];
    }

    // تحميل البيانات المطلوبة فعلاً فقط
    if (needCandidates) {
      final list = await loadJson('assets/data/candidates.json');
      if (list.isNotEmpty) await saveCandidates(list);
    }

    if (needOffices) {
      final list = await loadJson('assets/data/offices.json');
      if (list.isNotEmpty) await _saveList(_officesBox, _officesKey, list, 'Offices');
    }



if (needFaqs) {
      final list = await loadJson('assets/data/faqs.json');
      if (list.isNotEmpty) {
        await saveFAQs(list);
        developer.log('✅ تم حفظ ${list.length} من الأسئلة الشائعة في Hive', name: 'SEED');
      }
    }

    

    if (needNews) {
      final list = await loadJson('assets/data/news.json');
      if (list.isNotEmpty) {
        await saveNews(
        list.map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
      }
    }

    developer.log('✅ تم تهيئة قاعدة البيانات من الملفات الحقيقية بنجاح', name: 'SEED');
    AnalyticsService.trackEvent('Seed_RealData_Success');
  } catch (e, stack) {
    developer.log('❌ فشل تهيئة البيانات الحقيقية: $e', name: 'SEED', error: e, stackTrace: stack);
    AnalyticsService.trackEvent('Seed_RealData_Failed', parameters: {'error': e.toString()});
  }
}






  static Future<void> _initializeHiveWithImprovements() async {
    final sw = Stopwatch()..start();
    try {
      final dir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(dir.path);

      // تسجيل Adapters
      Hive.registerAdapter(OfficeModelAdapter());
      Hive.registerAdapter(CandidateModelAdapter());
      Hive.registerAdapter(NewsModelAdapter());
      Hive.registerAdapter(FaqModelAdapter());
// await Hive.deleteBoxFromDisk('news');
// developer.log('🧹 Deleted old news box (force reset)', name: 'MIGRATION');
await migrateAndRepairNewsBox();
      final boxes = await _openBoxesWithTimeout();

      _appBox        = boxes[0];
      _candidatesBox = boxes[1];
      _faqBox        = boxes[2];
      _newsBox       = boxes[3];
      _officesBox    = boxes[4];

      _isInitialized = true;
      _useFallbackStorage = false;

      AnalyticsService.trackEvent('Hive_Initialization_Success',
          parameters: {'duration_ms': sw.elapsedMilliseconds});
      developer.log('✅ Hive initialized', name: 'CACHE');
    } catch (e) {
      AnalyticsService.trackEvent('Hive_Initialization_Failed', parameters: {'error': e.toString()});
      await _handleInitializationFallback(e is Exception ? e : Exception(e.toString()));
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Hive_Init', sw.elapsed);
    }
  }

  static Future<List<Box>> _openBoxesWithTimeout() async {
    final sw = Stopwatch()..start();
    try {
      final results = await Future.wait([
        _openBoxWithRetry('app_data',   maxRetries: 2),
        _openBoxWithRetry('candidates', maxRetries: 2),
        _openBoxWithRetry('faqs',       maxRetries: 2),
        _openBoxWithRetry('news',       maxRetries: 2),
        _openBoxWithRetry('offices',    maxRetries: 2),
      ]).timeout(const Duration(seconds: 10));

      AnalyticsService.trackEvent('Boxes_Opened_Parallel', parameters: {
        'box_count': results.length,
        'duration_ms': sw.elapsedMilliseconds
      });

      return results;
    } on TimeoutException {
      AnalyticsService.trackEvent('Boxes_Open_Timeout', parameters: {'fallback_method': 'sequential'});
      developer.log('⚠️ Parallel open timed out. Fallback to sequential.', name: 'CACHE');
      return _fallbackSequentialInit();
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Boxes_Open', sw.elapsed);
    }
  }

  static Future<List<Box>> _fallbackSequentialInit() async {
    final sw = Stopwatch()..start();
    try {
      final appBox        = await _openBoxWithRetry('app_data',   maxRetries: 1);
      final candidatesBox = await _openBoxWithRetry('candidates', maxRetries: 1);
      final faqBox        = await _openBoxWithRetry('faqs',       maxRetries: 1);
      final newsBox       = await _openBoxWithRetry('news',       maxRetries: 1);
      final officesBox    = await _openBoxWithRetry('offices',    maxRetries: 1);

      AnalyticsService.trackEvent('Boxes_Opened_Sequential',
          parameters: {'box_count': 5, 'duration_ms': sw.elapsedMilliseconds});

      return [appBox, candidatesBox, faqBox, newsBox, officesBox];
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Sequential_Fallback', sw.elapsed);
    }
  }

  static Future<Box> _openBoxWithRetry(String name, {int maxRetries = 2}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final box = await Hive.openBox(name);
        AnalyticsService.trackEvent('Box_Open_Success', parameters: {
          'box_name': name,
          'attempt': attempt + 1,
        });
        return box;
      } catch (e) {
        if (attempt == maxRetries) {
          AnalyticsService.trackEvent('Box_Open_Failed', parameters: {
            'box_name': name,
            'attempts': maxRetries + 1,
            'error': e.toString(),
          });
          rethrow;
        }
        AnalyticsService.trackEvent('Box_Open_Retry',
            parameters: {'box_name': name, 'attempt': attempt + 1});
        await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
      }
    }
    throw Exception('Failed to open box: $name');
  }

  static Future<void> _initializeFallbackSystem() async {
    final sw = Stopwatch()..start();
    try {
      // PrefsManager.init() تم استدعاؤها مسبقًا في init()
      _fallbackInitialized = true;

      // اختبار بسيط
      final probe = {'t': DateTime.now().millisecondsSinceEpoch};
      await PrefsManager.saveString('fallback_test', json.encode(probe));
      final ok = PrefsManager.getString('fallback_test');
      _fallbackInitialized = ok != null;

      if (_fallbackInitialized) {
        AnalyticsService.trackEvent('Fallback_System_Initialized');
        developer.log('✅ Fallback system ready', name: 'FALLBACK');
      } else {
        AnalyticsService.trackEvent('Fallback_System_Failed', parameters: {'error': 'probe_failed'});
      }
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Init', sw.elapsed);
    }
  }



// ==========================================================
// 🧠 [New Feature] — Load FAQs automatically from assets
// ==========================================================

static Future<void> loadFAQsFromAssetsIfNeeded() async {
  // ⏱️ نبدأ ساعة الأداء
  final sw = Stopwatch()..start();

  try {
    // تأكد أن الصندوق مفتوح
    if (!_faqBox.isOpen) {
      _faqBox = await Hive.openBox('faqs');
    }

    // ✅ إذا كان الصندوق فارغ نحمل من الأصول
    if (_faqBox.isEmpty) {
      developer.log('📂 Hive FAQ box empty — loading from assets...', name: 'LocalDatabase');

      final String jsonString = await rootBundle.loadString('assets/data/faqs.json');
      final List<dynamic> decoded = json.decode(jsonString);

      final List<FaqModel> faqs = decoded
          .map((e) => FaqModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      await saveFAQs(faqs);

      developer.log(
        '✅ FAQs successfully loaded from assets/data/faqs.json (${faqs.length} items)',
        name: 'LocalDatabase',
      );
    } else {
      developer.log('ℹ️ Hive FAQ box already contains data — skipping asset load',
          name: 'LocalDatabase');
    }
  } catch (e, st) {
    developer.log('❌ Error loading FAQs from assets: $e',
        name: 'LocalDatabase', error: e, stackTrace: st);
  } finally {
    // ⏹️ إيقاف الساعة في جميع الحالات وتسجيل الزمن
    sw.stop();
    PerformanceTracker.track('LocalDatabase_Load_FAQs_From_Assets', sw.elapsed);
  }
}





  static Future<void> _initializeFallbackStorage() async {
    final sw = Stopwatch()..start();
    try {
      await _initializeFallbackSystem();
      if (_fallbackInitialized) {
        _useFallbackStorage = true;
        developer.log('📦 Fallback storage activated', name: 'FALLBACK');
      }
      AnalyticsService.trackEvent('Fallback_Storage_Init');
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Storage', sw.elapsed);
    }
  }

  static Future<void> _handleInitializationFallback(Exception error) async {
    developer.log('🔥 Hive init failed: $error', name: 'CACHE');
    AnalyticsService.trackEvent('Initialization_Fallback_Triggered',
        parameters: {'error': error.toString()});
    try {
      await _initializeFallbackStorage();
      _isInitialized = true;
      AnalyticsService.trackEvent('Fallback_Storage_Success');
      developer.log('✅ Fallback storage initialized', name: 'CACHE');
    } catch (fallbackError) {
      AnalyticsService.trackEvent('Fallback_Storage_Failed',
          parameters: {'error': fallbackError.toString()});
      await _cleanAndRetry();
    }
  }

  /// ✅ (NEW) دالة الطوارئ التي كانت ناقصة
  static Future<void> _emergencyFallbackInitialization(dynamic error) async {
    final sw = Stopwatch()..start();
    try {
      developer.log('🚨 Emergency Fallback Init', name: 'FALLBACK');
      await _initializeFallbackSystem();
      if (_fallbackInitialized) {
        _useFallbackStorage = true;
        _isInitialized = true;
        AnalyticsService.trackEvent('Emergency_Fallback_Activated',
            parameters: {'error': error.toString()});
        developer.log('✅ Emergency fallback activated', name: 'FALLBACK');
      }
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Emergency_Fallback', sw.elapsed);
    }
  }

  // 🌍 واجهة عامة يمكن استدعاؤها من main.dart
static Future<void> emergencyFallbackInitialization([dynamic error]) async {
  return await _emergencyFallbackInitialization(error);
}

  // ============================
  //   Generic save/get + fallback
  // ============================
  static Future<void> _saveList(Box box, String key, List<dynamic> data, String label) async {
    final sw = Stopwatch()..start();
    try {
      await _ensureInitialized();
      if (!_useFallbackStorage) {
        try {
          await box.put(key, data);
          await _saveToSharedPrefsFallback(key, data);
        } catch (_) {
          await _saveToSharedPrefsFallback(key, data);
          _useFallbackStorage = true;
        }
      } else {
        await _saveToSharedPrefsFallback(key, data);
      }
      AnalyticsService.trackEvent('${label}_Saved', parameters: {
        'count': data.length,
        'storage_type': _useFallbackStorage ? 'fallback' : 'hive',
      });
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Save_$label', sw.elapsed);
    }
  }

  static List<dynamic> _getList(Box box, String key, String label) {
    final sw = Stopwatch()..start();
    try {
      if (!_isInitialized) return [];
      dynamic out;
      if (!_useFallbackStorage) {
        try {
          out = box.get(key, defaultValue: []);
        } catch (_) {
          out = _getFromSharedPrefsFallback(key) ?? [];
          _useFallbackStorage = true;
        }
      } else {
        out = _getFromSharedPrefsFallback(key) ?? [];
      }
      AnalyticsService.trackEvent('${label}_Retrieved', parameters: {
        'count': (out as List).length,
        'storage_type': _useFallbackStorage ? 'fallback' : 'hive',
      });
      return out;
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Get_$label', sw.elapsed);
    }
  }

  // ✅ تحديث دعم FAQs - نظام متطور
  static Future<List<FaqModel>> getFAQsFromAssets() async {
    try {
      final repository = FAQRepositoryImpl();
      return await repository.getFAQs();
    } catch (e) {
      developer.log('❌ Failed to load FAQs from assets: $e', name: 'LocalDatabase');
      return [];
    }
  }

  // ✅ دعم للإصدار القديم مع تحسين
  static List<FaqModel> getFAQsTyped() {
    try {
      final raw = getFAQs();
      final List<FaqModel> out = [];
      
      for (final e in raw) {
        if (e is FaqModel) {
          out.add(e);
        } else if (e is Map) {
          try {
            out.add(FaqModel.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {
            // تجاهل السجل التالف
          }
        }
      }

      // ترتيب حسب الأهمية والتاريخ
      out.sort((a, b) {
        final byImp = (b.importance).compareTo(a.importance);
        if (byImp != 0) return byImp;
        return b.createdAt.compareTo(a.createdAt);
      });

      return out;
    } catch (e) {
      developer.log('❌ Error in getFAQsTyped: $e', name: 'LocalDatabase');
      return [];
    }
  }

  // ✅ تنظيف البيانات القديمة - نظام صيانة تلقائي
  static Future<void> clearOldCache() async {
    try {
      final boxes = [
        'faqs_cache',  // الصندوق الجديد للنظام المتطور
        'app_data', 
        'candidates',
        'faqs',
        'news',
        'offices'
      ];
      
      for (final box in boxes) {
        if (Hive.isBoxOpen(box)) {
          await Hive.box(box).clear();
          developer.log('🧹 Cleared box: $box', name: 'CACHE_MAINTENANCE');
        }
      }
      
      AnalyticsService.trackEvent('Cache_Maintenance_Completed');
    } catch (e) {
      developer.log('⚠️ Cache maintenance error: $e', name: 'CACHE_MAINTENANCE');
    }
  }

  // ✅ الحصول على إحصائيات التخزين
  static Map<String, dynamic> getStorageStatistics() {
    final stats = <String, dynamic>{
      'total_boxes': 0,
      'total_items': 0,
      'box_details': {},
    };

    try {
      final boxes = [_appBox, _candidatesBox, _faqBox, _newsBox, _officesBox];
      stats['total_boxes'] = boxes.length;

      for (final box in boxes) {
        if (box.isOpen) {
          final boxName = box.name;
          final itemCount = box.length;
          stats['total_items'] += itemCount;
          stats['box_details'][boxName] = {
            'item_count': itemCount,
            'keys': box.keys.toList(),
          };
        }
      }
    } catch (e) {
      developer.log('❌ Error getting storage stats: $e', name: 'LocalDatabase');
    }

    return stats;
  }
  // ============================
  //   SharedPrefs Fallback I/O
  // ============================
  static Future<void> _saveToSharedPrefsFallback(String key, dynamic data) async {
    final sw = Stopwatch()..start();
    try {
      if (!_fallbackInitialized) throw Exception('Fallback not initialized');
      final s = json.encode(data);
      if (s.length > _maxFallbackSize) {
        AnalyticsService.trackEvent('Fallback_Data_Too_Large',
            parameters: {'key': key, 'size': s.length});
        throw Exception('Data too large for fallback');
      }
      await PrefsManager.saveString(key, s);
      AnalyticsService.trackEvent('Fallback_Save_Success',
          parameters: {'key': key, 'data_size': s.length});
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Save', sw.elapsed);
    }
  }

  static dynamic _getFromSharedPrefsFallback(String key) {
    final sw = Stopwatch()..start();
    try {
      if (!_fallbackInitialized) return null;
      final s = PrefsManager.getString(key);
      if (s == null) return null;
      return json.decode(s);
    } finally {
      sw.stop();
      PerformanceTracker.track('LocalDatabase_Fallback_Get', sw.elapsed);
    }
  }

  // ============================
  //     Utilities
  // ============================
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  static Future<void> _cleanAndRetry() async {
    try {
      await Hive.close();
      await hardReset();
    } catch (_) {}
    _isInitialized = false;
    _initCompleter = null;
    await init();
  }

  static Map<String, dynamic> getStorageStatus() {
    return {
      'hive_initialized': _isInitialized,
      'fallback_initialized': _fallbackInitialized,
      'using_fallback': _useFallbackStorage,
      'boxes_ready': _isInitialized && !_useFallbackStorage,
      'storage_type': _useFallbackStorage ? 'shared_preferences' : 'hive',
    };
  }



         // ============================
// 🏢 OFFICES MANAGEMENT SYSTEM
// ============================

/// ✅ تحميل بيانات المكاتب من ملف JSON إلى Hive عند الحاجة فقط
static Future<void> bootstrapOfficesFromAssets({bool forceReload = false}) async {
  try {
    await _ensureInitialized();

    final box = await _openOffices();
    //final existing = box.get('all');
final existing = box.get(_officesKey) ?? box.get('all'); // دعم النسخة القديمة أيضًا

// ترحيل (هجرة) إن وجدنا بيانات على المفتاح القديم فقط
if (existing == null) {
  final legacy = box.get('all');
  if (legacy != null) {
    await box.put(_officesKey, legacy);
  }
}

    // لا نعيد التحميل إلا إذا كانت البيانات ناقصة أو طلب المستخدم فرض إعادة التحميل
    if (existing != null && !forceReload && (existing as List).isNotEmpty) {
      developer.log('ℹ️ Offices already exist in Hive — skipping reload',
          name: 'LocalDatabase');
      return;
    }

    developer.log('📦 Loading offices from assets/data/offices.json...',
        name: 'LocalDatabase');
    final jsonStr = await rootBundle.loadString('assets/data/offices.json');
    final Map<String, dynamic> root = jsonDecode(jsonStr);
    final provinces = root['provinces'] ?? {};

    final List<Map<String, dynamic>> allOffices = [];

    // جمع المكاتب المركزية فقط (يمكن توسعتها لاحقًا)
    provinces.forEach((provinceName, provData) {
      if (provData is Map<String, dynamic>) {
        final central = provData['central'];
        if (central is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(central);
          map['province'] = provinceName;
          allOffices.add(map);
        }
      }
    });

    await box.clear();
    //await box.put('all', allOffices);
await box.clear();
await box.put(_officesKey, allOffices);
// (اختياري لدعم إصدارات أقدم تقرأ 'all')
await box.put('all', allOffices);

    AnalyticsService.trackEvent('Offices_Loaded_From_Assets',
        parameters: {'count': allOffices.length});
    developer.log('✅ ${allOffices.length} offices loaded successfully',
        name: 'LocalDatabase');
  } catch (e, st) {
    developer.log('❌ Failed to bootstrap offices: $e',
        name: 'LocalDatabase', error: e, stackTrace: st);
  }
}

/// ✅ جلب جميع المكاتب من Hive أو fallback عند الحاجة
static Future<List<OfficeModel>> getAllOffices() async {
  await _ensureInitialized();

  dynamic raw;
  try {
    final box = await _openOffices();
    //raw = box.get('all');
    raw = box.get(_officesKey) ?? box.get('all');

  } catch (_) {
    raw = _getFromSharedPrefsFallback(_officesKey);
    
  }

  if (raw == null) return [];

  final offices = (raw as List)
      .map((e) => OfficeModel.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  AnalyticsService.trackEvent('Offices_Retrieved',
      parameters: {'count': offices.length});
  return offices;
}

/// ✅ جلب مكاتب محافظة معينة (مرنة مستقبلاً للمكاتب الفرعية)
static Future<List<OfficeModel>> getOfficesByProvince(String province) async {
  final offices = await getAllOffices();
  return offices.where((o) => o.province == province).toList();
}



 
}
