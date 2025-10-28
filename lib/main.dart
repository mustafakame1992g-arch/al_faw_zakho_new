// 🎯 main.dart — النسخة النهائية الجاهزة للإطلاق (Release Clean)
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

// 🔥 أضف هذا الاستيراد في الأعلى
import 'dart:async' show unawaited;
import 'package:al_faw_zakho/core/errors/global_error_handler.dart';
import 'package:al_faw_zakho/core/live/live_data_updater.dart';
// 🧩 Core
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/core/navigation/navigation_service.dart';
import 'package:al_faw_zakho/core/network/api_client.dart';
import 'package:al_faw_zakho/core/perf/memory_manager.dart';
import 'package:al_faw_zakho/core/providers/app_provider.dart';
import 'package:al_faw_zakho/core/providers/connectivity_provider.dart';
import 'package:al_faw_zakho/core/providers/language_provider.dart';
import 'package:al_faw_zakho/core/providers/theme_provider.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
// 🧱 Data
import 'package:al_faw_zakho/data/models/candidate_model.dart';
// أضِف
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/presentation/screens/about/about_screen.dart';
import 'package:al_faw_zakho/presentation/screens/donate/donate_screen.dart';
// 🎨 UI
import 'package:al_faw_zakho/presentation/screens/home/home_screen.dart';
import 'package:al_faw_zakho/presentation/screens/offices/offices_main_screen.dart';
import 'package:al_faw_zakho/presentation/themes/app_theme.dart';
import 'package:al_faw_zakho/presentation/widgets/error_screen.dart';
import 'package:al_faw_zakho/presentation/widgets/loading_screen.dart';
// flutter:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
// طرف ثالث / مشروعك:
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.init();

  // ✅ تفعيل النظام العام للأخطاء
  await GlobalErrorHandler.setup(
    config: const ErrorHandlerConfig(
      enableConsoleLogging: true,
      enableFileLogging: true,
      enableDatabaseLogging: true,
      enableAutoReporting: true,
      duplicateSuppressionSeconds: 10,
      maxLogFileSizeMB: 5,
    ),
  );

  final themeProvider = ThemeProvider();
  await themeProvider.init(); // تحميل الثيم المحفوظ من SharedPreferences

  // ✅ تهيئة مزود اللغة (الحل الحقيقي)
  final languageProvider = LanguageProvider();
  await languageProvider.init();

  await _initializeCoreServices();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
      ],
      child: const FoundationApp(),
    ),
  );
}

/// 🧠 تهيئة أساسية متوازية لجميع الخدمات
Future<void> _initializeCoreServices() async {
  final stopwatch = Stopwatch()..start();
  developer.log(
    '[MAIN] 🚀 Starting ultra-optimized core initialization...',
    name: 'BOOT',
  );

  try {
    // ============================================================
    // 🧱 المرحلة 1: تهيئة Hive بأمان — مع كشف مبكر لأي تلف في صناديق البيانات
    // ============================================================
    await _initializeHiveWithRetry();


// NOTE: seeding يحصل داخل LocalDatabase.init() تلقائياً عند الحاجة
await Future<void>.delayed(const Duration(milliseconds: 150));
    // ============================================================
    // 🧩 المرحلة 2: تحميل النظام الأساسي للبيانات الحقيقية
    // ============================================================
    await _initializeRealDataSystem();

    // ============================================================
    // 💾 المرحلة 3: تهيئة إدارة الذاكرة والأداء
    // ============================================================
    await MemoryManager.initialize(enableMonitoring: true);

    // ============================================================
    // 📊 المرحلة 4: تشغيل التحليلات والبيانات الأساسية بالتوازي
    // ============================================================
    await Future.wait([
      _initializeAnalytics(),
      _preloadEssentialData(),
    ]);

    // ✅ فحص مباشر لعدد المكاتب بعد التهيئة
final offices = LocalDatabase.getOffices();
    developer.log(
      '📦 DEBUG: Offices in Hive after init = ${offices.length}',
      name: 'DEBUG',
    );
    for (final o in offices) {
      developer.log('➡️ ${o.province} | ${o.nameAr}', name: 'DEBUG');
    }

    developer.log(
      '[MAIN] ✅ Core services fully initialized in ${stopwatch.elapsedMilliseconds}ms',
      name: 'BOOT',
    );
  } catch (e, stack) {
    developer.log(
      '[MAIN] ❌ Core initialization failed: $e',
      name: 'ERROR',
      error: e,
      stackTrace: stack,
    );

    // 🚨 fallback احتياطي شامل لتأمين الإقلاع حتى لو فشل Hive
await LocalDatabase.init(); // LocalDatabase يدير fallback داخلياً

    rethrow;
  } finally {
    stopwatch.stop();
    developer.log(
      '[MAIN] 🕒 Total initialization time: ${stopwatch.elapsedMilliseconds}ms',
      name: 'BOOT',
    );
  }
}

/// 🧱 تهيئة Hive مع إعادة المحاولة
Future<void> _initializeHiveWithRetry() async {
  const maxAttempts = 3;

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await Hive.initFlutter();
      await LocalDatabase.init();

      developer.log(
        '[MAIN] Hive initialized ✅ (attempt $attempt)',
        name: 'BOOT',
      );
      return;
    } catch (e, stack) {
      developer.log(
        '[MAIN] Hive init failed (attempt $attempt): $e',
        name: 'WARNING',
        error: e,
        stackTrace: stack,
      );

      if (attempt == maxAttempts) {
        developer.log(
          '[MAIN] Hive init failed after $maxAttempts attempts',
          name: 'ERROR',
        );
        rethrow;
      }

      // ✅ انتظار متزايد بين المحاولات
await Future<void>.delayed(Duration(seconds: attempt * 2));
    }
  }
}

/// 🔍 تهيئة نظام البيانات الحقيقية (Hive + Adapter)
Future<void> _initializeRealDataSystem() async {
  try {
    // ✅ نظام مركزي لتسجيل جميع الـ Adapters
    final adapters = {
      3: CandidateModelAdapter(),
    };

    for (final entry in adapters.entries) {
      if (!Hive.isAdapterRegistered(entry.key)) {
        Hive.registerAdapter(entry.value);
      }
    }

    developer.log(
      '[MAIN] Real data system initialized ✅ (${adapters.length} adapters)',
      name: 'BOOT',
    );
  } catch (e, stack) {
    developer.log(
      '[MAIN] Real data system init failed: $e',
      name: 'ERROR',
      error: e,
      stackTrace: stack,
    );
  }
}

/// 📊 تهيئة Analytics
Future<void> _initializeAnalytics() async {
  try {
    AnalyticsService.initialize();
    developer.log('[MAIN] Analytics initialized ✅', name: 'BOOT');
  } catch (e) {
    developer.log('[MAIN] Analytics init failed: $e', name: 'WARNING');
  }
}

/// 🚀 تحميل مسبق للبيانات الأساسية (نسخة متينة واحترافية)
Future<void> _preloadEssentialData() async {
  try {
    // ✅ تحميل الشعار والأصول الأساسية مسبقاً بدون الحاجة إلى BuildContext
    final imageProvider = const AssetImage('assets/images/logo.png');
    final completer = Completer<void>();

    final stream = imageProvider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        completer.complete();
      },
      onError: (Object error, StackTrace? stackTrace) {
        developer.log(
          '[MAIN] Failed to preload logo: $error',
          name: 'ERROR',
          error: error,
          stackTrace: stackTrace,
        );
        completer.completeError(error, stackTrace);
      },
    );

    stream.addListener(listener);

    // ⏱️ تحديد مهلة أمان في حال تأخّر التحميل
    await completer.future.timeout(const Duration(seconds: 5));

    stream.removeListener(listener);

    developer.log('[MAIN] Essential assets preloaded ✅', name: 'BOOT');
  } catch (e, stack) {
    developer.log(
      '[MAIN] Preload warning: $e',
      name: 'INFO',
      error: e,
      stackTrace: stack,
    );
  }
}

// 🏛 التطبيق الجذري
class FoundationApp extends StatelessWidget {
  const FoundationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        // ✅ لا نعيد إنشاء ThemeProvider أو LanguageProvider هنا
        ChangeNotifierProxyProvider<ApiClient, AppProvider>(
          create: (_) => AppProvider(),
          update: (_, apiClient, appProvider) =>
              appProvider!..setApiClient(apiClient),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

// 🔹 التطبيق الفعلي
class _AppRoot extends StatefulWidget {
  const _AppRoot();
  @override
  State<_AppRoot> createState() => __AppRootState();
}

class __AppRootState extends State<_AppRoot> {
  bool _isInitializing = true;
  String? _errorMessage;
  double _progress = 0.0;
  late Stopwatch _initStopwatch;

  @override
  void initState() {
    super.initState();
    _initStopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  Future<void> _initializeApp() async {
    final stopwatch = Stopwatch()..start();
    developer.log('[_AppRoot] Starting initialization...', name: 'INIT');

    try {
      await _executeInitializationPhases();

      developer.log(
        '[_AppRoot] Initialization done ✅ in ${stopwatch.elapsedMilliseconds}ms',
        name: 'INIT',
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _progress = 1.0;
        });
      }
    } catch (e, stack) {
      developer.log(
        '[_AppRoot] Initialization failed: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'فشل في تهيئة التطبيق: ${e.toString()}';
        });
      }
    } finally {
      _initStopwatch.stop();
    }
  }

  Future<void> _executeInitializationPhases() async {
    bool? connected;

    final phases = [
      _Phase('Core Providers', _initializeCoreProviders),
      _Phase('Connectivity Check', () async {
        connected = await _checkConnectivity();
      }),
      _Phase('Data Loading', _loadRealAppData),
      _Phase('Data Validation', _validateRealData),
      _Phase('Final Setup', () => _finalizeInitialization(connected ?? false)),
    ];

    for (int i = 0; i < phases.length; i++) {
      final shouldContinue =
          await _executePhaseWithTimeout(phases[i], i + 1, phases.length);

      if (!shouldContinue) break;
    }
  }

  // ✅ إضافة الدوال الناقصة
  Future<void> _initializeCoreProviders() async {
    // تهيئة البروفايدرز الأساسية
await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  Future<bool> _executePhaseWithTimeout(
    _Phase phase,
    int current,
    int total,
  ) async {
    _updateProgress(current, total, '${phase.name}...');

    try {
      await phase.task().timeout(
            Duration(seconds: _getPhaseTimeout(phase.name)),
          );
      developer.log('✅ [INIT] ${phase.name} completed', name: 'PROGRESS');
      return true;
    } catch (e) {
      return await _handlePhaseError(phase.name, e);
    }
  }

  Future<bool> _handlePhaseError(String phaseName, Object error) async {
    developer.log('❌ [INIT] $phaseName failed: $error', name: 'ERROR');
    // يمكن إضافة منطق التعافي هنا
    return false; // أو true إذا أردنا الاستمرار رغم الخطأ
  }

  int _getPhaseTimeout(String phaseName) {
    const timeouts = {
      'Core Providers': 15,
      'Connectivity Check': 10,
      'Data Loading': 30,
      'Data Validation': 20,
      'Final Setup': 25,
    };
    return timeouts[phaseName] ?? 15;
  }

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityProvider =
          Provider.of<ConnectivityProvider>(context, listen: false);
      final result = await connectivityProvider.checkConnection();

      developer.log(
        '[_AppRoot] Connectivity check result: $result',
        name: 'DEBUG',
      );

      return result;
    } catch (e, stackTrace) {
      developer.log(
        '[_AppRoot] Connectivity check failed: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// 📦 تحميل البيانات من Hive مع التعامل مع السيناريوهات المختلفة
  Future<void> _loadRealAppData() async {
    try {
      final candidates = LocalDatabase.getCandidates();
      final faqs = LocalDatabase.getFAQs();

      developer.log(
        '[REAL_DATA] Loaded ${candidates.length} candidates, ${faqs.length} FAQs',
        name: 'DATA',
      );

      if (candidates.isEmpty || faqs.isEmpty) {
        developer.log(
          '[REAL_DATA] Empty data detected (candidates: ${candidates.length}, FAQs: ${faqs.length}), loading default data...',
          name: 'WARNING',
        );
        await _loadDefaultData();
      }
    } catch (e, stack) {
      developer.log(
        '[REAL_DATA] Critical load failure: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );
      await _loadDefaultData();
    }
  }

  /// 🔒 تحقق محسن من سلامة البيانات
  Future<void> _validateRealData() async {
    try {
      // ✅ جلب البيانات من LocalDatabase
      final rawCandidates = LocalDatabase.getCandidates();
      final candidates = rawCandidates.cast<CandidateModel>().toList();
      final faqs = LocalDatabase.getFAQs();

      developer.log(
        '[VALIDATION] Starting validation - Candidates: ${candidates.length}, FAQs: ${faqs.length}',
        name: 'DEBUG',
      );

      if (candidates.isEmpty) {
        developer.log('[VALIDATION] Empty candidates list', name: 'WARNING');
        throw Exception('لا توجد بيانات للمرشحين');
      }

      if (faqs.isEmpty) {
        developer.log('[VALIDATION] Empty FAQs list', name: 'WARNING');
        throw Exception('لا توجد أسئلة شائعة');
      }

      _validateDataQuality(candidates, faqs);

      developer.log(
        '[VALIDATION] Validation passed ✅ (${candidates.length} candidates, ${faqs.length} FAQs)',
        name: 'DATA',
      );
    } catch (e, stack) {
      developer.log(
        '[VALIDATION] Critical validation failure: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );
      await _loadDefaultData();
      rethrow;
    }
  }

  void _validateDataQuality(
    List<CandidateModel> candidates,
    List<dynamic> faqs,
  ) {
    if (candidates.isEmpty || faqs.isEmpty) {
      throw Exception('البيانات فارغة لا يمكن التحقق من الجودة');
    }

    // ✅ التحقق من جودة بيانات المرشحين
    for (final candidate in candidates) {
      if (candidate.nameAr.isEmpty && candidate.nameEn.isEmpty) {
        throw Exception(
          'بيانات مرشح غير مكتملة: الاسم مفقود للمرشح ${candidate.id}',
        );
      }
    }

    // ✅ التحقق من التكرارات
    final nonNullIds = candidates.map((c) => c.id).toList();
    final uniqueIds = nonNullIds.toSet();

    if (uniqueIds.length != nonNullIds.length) {
      final duplicates = _findDuplicates(nonNullIds);
      throw Exception('يوجد تكرار في معرفات المرشحين: $duplicates');
    }

    // ✅ التحقق من جودة بيانات FAQs
    for (final faq in faqs) {
      final question = faq['question']?.toString();
      final answer = faq['answer']?.toString();

      if (question?.isEmpty ?? true) {
        throw Exception('سؤال FAQ فارغ أو غير موجود');
      }

      if (answer?.isEmpty ?? true) {
        throw Exception('إجابة FAQ فارغة أو غير موجودة');
      }
    }
  }

  List<dynamic> _findDuplicates(List<dynamic> list) {
    final duplicates = <dynamic>[];
    final seen = <dynamic>{};

    for (final item in list) {
      if (seen.contains(item)) {
        duplicates.add(item);
      } else {
        seen.add(item);
      }
    }

    return duplicates;
  }

  /// 🗃️ تحميل البيانات الافتراضية من JSON
  Future<void> _loadDefaultData() async {
    try {
      developer.log(
        '[DEFAULT_DATA] Loading default data from assets...',
        name: 'DATA',
      );

      await LocalDatabase.clearCandidates();
      await LocalDatabase.clearFAQs();

      final stopwatch = Stopwatch()..start();

      final jsonString = await rootBundle
          .loadString('assets/data/default_data.json')
          .timeout(const Duration(seconds: 10));



final Map<String, dynamic> jsonData =
    jsonDecode(jsonString) as Map<String, dynamic>;

final List<CandidateModel> candidatesList = (jsonData['candidates'] as List)
    .whereType<Map>()
    .map((m) => CandidateModel.fromJson(m.cast<String, dynamic>()))
    .toList(growable: false);

if (candidatesList.isEmpty) {
  throw Exception('قائمة المرشحين فارغة في البيانات الافتراضية');
}
await LocalDatabase.saveCandidates(candidatesList);

final List<FaqModel> faqsList = (jsonData['faqs'] as List)
    .whereType<Map>()
    .map((m) => FaqModel.fromJson(m.cast<String, dynamic>()))
    .toList(growable: false);

if (faqsList.isEmpty) {
  throw Exception('قائمة الأسئلة الشائعة فارغة في البيانات الافتراضية');
}
await LocalDatabase.saveFAQs(faqsList);



      developer.log(
        '[DEFAULT_DATA] Saved ${faqsList.length} FAQs ✅',
        name: 'DATA',
      );

      await LocalDatabase.saveAppData(
        'last_data_update',
        DateTime.now().toString(),
      );

      developer.log(
        '[DEFAULT_DATA] Default data loaded successfully in ${stopwatch.elapsedMilliseconds}ms ✅',
        name: 'PERF',
      );
    } on TimeoutException {
      developer.log(
        '[DEFAULT_DATA] Timeout while loading default data',
        name: 'ERROR',
      );
      throw Exception('استغرقت عملية تحميل البيانات وقتاً طويلاً');
    } catch (e, stack) {
      developer.log(
        '[DEFAULT_DATA] Failed to load default data: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );
      throw Exception('فشل في تحميل البيانات الافتراضية');
    }
  }

  /// 🧩 المرحلة النهائية المحسنة
  Future<void> _finalizeInitialization(bool connected) async {
    try {
      // ✅ بدء التحديثات الحية
      if (connected) {
        try {
          await LiveDataUpdater.start().timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              developer.log('[INIT] Live updater timeout', name: 'WARNING');
            },
          );
          developer.log(
            '[INIT] Live data updater started successfully ✅',
            name: 'BOOT',
          );
        } catch (e, stack) {
          developer.log(
            '[INIT] Live updater failed: $e',
            name: 'WARNING',
            error: e,
            stackTrace: stack,
          );
        }
      }

      // ✅ تحسينات الأداء الأساسية
      try {
        await MemoryManager.tuneImageCacheForLowEnd(lowEnd: true);
        developer.log('[INIT] Memory tuning applied ✅', name: 'BOOT');
      } catch (e, stack) {
        developer.log(
          '[INIT] Memory tuning failed: $e',
          name: 'WARNING',
          error: e,
          stackTrace: stack,
        );
      }

      // ✅ تحسينات إضافية
      try {
        await _optimizePerformance();
        developer.log(
          '[INIT] Performance optimizations applied ✅',
          name: 'BOOT',
        );
      } catch (e, stack) {
        developer.log(
          '[INIT] Performance optimization failed: $e',
          name: 'WARNING',
          error: e,
          stackTrace: stack,
        );
      }

      developer.log(
        '[INIT] Finalization complete (online: $connected) ✅',
        name: 'BOOT',
      );
    } catch (e, stack) {
      developer.log(
        '[INIT] Unexpected finalization error: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _optimizePerformance() async {
    final stopwatch = Stopwatch()..start();
    final memoryStatus = MemoryManager.getMemoryStatus();

    try {
      // 🎯 تحديد إذا كان الجهاز ضعيف الأداء
      final bool isLowEndDevice =
          memoryStatus.isCacheNearlyFull || _isLowEndDevice(memoryStatus);

      // ⚙️ ضبط الذاكرة حسب قوة الجهاز
      await MemoryManager.tuneImageCacheForLowEnd(lowEnd: isLowEndDevice);

      // 📊 تسجيل الإعدادات
      final imageCache = PaintingBinding.instance.imageCache;
      developer.log(
        '[PERF] Image cache: ${imageCache.currentSize}/${imageCache.maximumSize} images, '
        '${memoryStatus.cacheUsagePercent.toStringAsFixed(1)}% used '
        '(lowEnd: $isLowEndDevice)',
        name: 'DEBUG',
      );

      // 🖥️ تكوين واجهة النظام للتحسين
await _configureSystemUI(isLowEndDevice);

      // 🧹 جدولة تنظيف الذاكرة
      _scheduleAdaptiveMemoryCleanup(isLowEndDevice);

      developer.log(
        '[PERF] Performance optimizations applied in ${stopwatch.elapsedMilliseconds}ms '
        '(lowEnd: $isLowEndDevice, cache: ${memoryStatus.cacheUsagePercent.toStringAsFixed(1)}%)',
        name: 'BOOT',
      );
    } catch (e, stack) {
      developer.log(
        '[PERF] Performance optimization failed after ${stopwatch.elapsedMilliseconds}ms: $e',
        name: 'WARNING',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 📱 تحديد إذا كان الجهاز ضعيف الأداء
  bool _isLowEndDevice(MemoryStatus status) {
    // منطق بسيط لتحديد الأجهزة الضعيفة
    return status.maxCacheBytes <= (30 << 20); // 30MB أو أقل
  }

  /// 🖥️ تكوين واجهة النظام مع تحسينات للأجهزة الضعيفة
  Future<void> _configureSystemUI(bool isLowEndDevice) async {
  try {
    if (isLowEndDevice) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }


      developer.log(
        '[PERF] System UI configured for ${isLowEndDevice ? 'low-end' : 'high-end'} device',
        name: 'DEBUG',
      );
    } catch (e, stack) {
      developer.log(
        '[PERF] System UI configuration failed: $e',
        name: 'INFO',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 🧹 تنظيف ذكي يتكيف مع نوع الجهاز
  void _scheduleAdaptiveMemoryCleanup(bool isLowEndDevice) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final result = await MemoryManager.cleanup(
          aggressive: isLowEndDevice, // تنظيف مكثف للأجهزة الضعيفة
          priority: isLowEndDevice
              ? CleanupPriority.aggressive
              : CleanupPriority.standard,
        );

        developer.log(
          '[PERF] ${isLowEndDevice ? 'Aggressive' : 'Standard'} memory cleanup: $result',
          name: 'DEBUG',
        );
      } catch (e) {
        developer.log('[PERF] Memory cleanup failed: $e', name: 'INFO');
      }
    });
  }

  void _updateProgress(int current, int total, String phaseDescription) {
    if (mounted) {
      setState(() => _progress = current / total);
    }
    developer.log(
      '[_AppRoot] Phase $current/$total: $phaseDescription',
      name: 'PROGRESS',
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ بناء MaterialApp مباشرة بدون copyWith
    if (_isInitializing) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: LoadingScreen(progress: _progress),
      );
    }

    if (_errorMessage != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: ErrorScreen(error: _errorMessage!, onRetry: _retry),
      );
    }

    return _buildMainApp();
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
        _progress = 0.0;
        _initStopwatch
          ..reset()
          ..start();
      });
unawaited(Future<void>.delayed(const Duration(milliseconds: 50), _initializeApp));
    }
  }

  Widget _buildMainApp() {
    return Consumer3<ThemeProvider, LanguageProvider, AppProvider>(
      builder: (context, theme, language, app, _) {
        final bool isArabic = language.locale.languageCode == 'ar';

        // ✅ استخدام Directionality لتحديد اتجاه النص
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: MultiProvider(
            providers: [
              Provider<INavigationService>(
                create: (_) => NavigationService(),
              ),
            ],
            child: MaterialApp(
              onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
              debugShowCheckedModeBanner: false,
              locale: language.locale,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: theme.themeMode,

              // ✅ إضافة routes هنا
              routes: {
                NavigationService.homeRoute: (_) => const HomeScreen(),
                NavigationService.officesRoute: (_) => const OfficesScreen(),
                NavigationService.donateRoute: (_) => const DonateScreen(),
                NavigationService.aboutRoute: (_) => const AboutScreen(),
              },

              //home: const HomeScreen(),
            ),
          ),
        );
      },
    );
  }
}

// ✅ إضافة كلاس _Phase المفقود
class _Phase {
  _Phase(this.name, this.task);
  final String name;
  final Future<void> Function() task;
}

//جديد يوم الخميس 9/10
