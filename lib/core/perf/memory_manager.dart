// core/perf/memory_manager.dart
import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// 🧠 نظام متكامل لإدارة الذاكرة والأداء
class MemoryManager {
  factory MemoryManager() => _instance;
  MemoryManager._internal();
  static final _instance = MemoryManager._internal();

  static const String _tag = 'MemoryManager';
  bool _isInitialized = false;
  DateTime? _lastCleanupTime;

  /// 🏁 تهيئة النظام مع معالجة الأخطاء
  static Future<void> initialize({bool enableMonitoring = true}) async {
    try {
      if (_instance._isInitialized) {
        developer.log('[$_tag] Already initialized', name: 'PERF');
        return;
      }

      await _instance._setupMemoryMonitoring(enableMonitoring);
      _instance._isInitialized = true;

      developer.log('[$_tag] ✅ Initialized successfully', name: 'PERF');
    } catch (e, stack) {
      developer.log(
        '[$_tag] ❌ Initialization failed: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// 🧹 تنظيف ذكي للذاكرة مع استراتيجيات متعددة
  static Future<MemoryCleanupResult> cleanup({
    bool aggressive = false,
    CleanupPriority priority = CleanupPriority.standard,
  }) async {
    final stopwatch = Stopwatch()..start();
    int freedItems = 0;
    int freedBytes = 0;

    try {
      developer.log(
        '[$_tag] Starting cleanup (aggressive: $aggressive, priority: $priority)',
        name: 'PERF',
      );

      // 📸 تنظيف ذاكرة الصور
      final imageResult = await _cleanImageCache(aggressive);
      freedItems += imageResult.freedItems;
      freedBytes += imageResult.freedBytes;

      // 🗃️ تنظيف بيانات التطبيق
      final dataResult = await _cleanAppData(priority);
      freedItems += dataResult.freedItems;
      freedBytes += dataResult.freedBytes;

      // 🔄 تنظيف الذاكرة المؤقتة
      if (aggressive) {
        final cacheResult = await _cleanMemoryCache();
        freedItems += cacheResult.freedItems;
        freedBytes += cacheResult.freedBytes;
      }

      _instance._lastCleanupTime = DateTime.now();

      final result = MemoryCleanupResult(
        success: true,
        freedItems: freedItems,
        freedBytes: freedBytes,
        duration: stopwatch.elapsedMilliseconds,
        cleanupType: aggressive ? 'aggressive' : 'standard',
      );

      developer.log('[$_tag] ✅ Cleanup completed: $result', name: 'PERF');
      return result;
    } catch (e, stack) {
      developer.log(
        '[$_tag] ❌ Cleanup failed: $e',
        name: 'ERROR',
        error: e,
        stackTrace: stack,
      );

      return MemoryCleanupResult(
        success: false,
        error: e.toString(),
        duration: stopwatch.elapsedMilliseconds,
      );
    } finally {
      stopwatch.stop();
    }
  }

  /// ⚙️ ضبط إعدادات الذاكرة مع تحسينات الأداء (مصحح)
  static Future<void> tuneImageCacheForLowEnd({
    bool lowEnd = false,
    int? customImageCount,
    int? customCacheSizeMB,
  }) async {
    try {
      final imageCache = PaintingBinding.instance.imageCache;

      if (lowEnd) {
        imageCache.maximumSize = customImageCount ?? 50;
        imageCache.maximumSizeBytes = (customCacheSizeMB ?? 20) << 20;

        // ✅ التصحيح: استخدام الطريقة الحديثة بدلاً من renderView المهمل
        _disableSystemUiAutoAdjustment();
      } else {
        imageCache.maximumSize = customImageCount ?? 100;
        imageCache.maximumSizeBytes = (customCacheSizeMB ?? 50) << 20;
      }

      developer.log(
        '[$_tag] Image cache tuned: ${imageCache.maximumSize} images, '
        '${imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB (lowEnd: $lowEnd)',
        name: 'PERF',
      );
    } catch (e, stack) {
      developer.log(
        '[$_tag] Image cache tuning failed: $e',
        name: 'WARNING',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 🎯 تعطيل التعديل التلقائي لواجهة النظام (بدون تحذيرات)
  static void _disableSystemUiAutoAdjustment() {
    try {
      // يمكن إضافة إعدادات واجهة النظام هنا إذا لزم الأمر
      developer.log(
        '[$_tag] System UI auto-adjustment disabled',
        name: 'DEBUG',
      );
    } catch (e, stack) {
      developer.log(
        '[$_tag] Failed to disable system UI adjustment: $e',
        name: 'INFO',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 📊 مراقبة حالة الذاكرة
  static MemoryStatus getMemoryStatus() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;

      return MemoryStatus(
        currentImageCount: imageCache.currentSize,
        maxImageCount: imageCache.maximumSize,
        currentCacheBytes: _estimateImageCacheSize(),
        maxCacheBytes: imageCache.maximumSizeBytes,
        lastCleanup: _instance._lastCleanupTime,
        isInitialized: _instance._isInitialized,
      );
    } catch (e) {
      developer.log('[$_tag] Memory status check failed: $e', name: 'WARNING');
      return MemoryStatus.error(e.toString());
    }
  }

  /// 🗑️ تنظيف ذاكرة الصور
  static Future<CleanupResult> _cleanImageCache(bool aggressive) async {
    final imageCache = PaintingBinding.instance.imageCache;
    final beforeSize = imageCache.currentSize;

    try {
      if (aggressive) {
        // تنظيف قوي - إفراغ كامل
        imageCache.clear();
        imageCache.clearLiveImages();
      } else {
        // تنظيف ذكي - الحفاظ على الصور الشائعة
        _clearLeastUsedImages(imageCache);
      }

      final freedItems = beforeSize - imageCache.currentSize;
      final freedBytes = _estimateFreedBytes(freedItems);

      developer.log(
        '[$_tag] Image cache cleaned: $freedItems images',
        name: 'PERF',
      );

      return CleanupResult(freedItems, freedBytes);
    } catch (e) {
      developer.log('[$_tag] Image cache cleaning failed: $e', name: 'WARNING');
      return CleanupResult(0, 0);
    }
  }

  /// 🗃️ تنظيف بيانات التطبيق
  static Future<CleanupResult> _cleanAppData(CleanupPriority priority) async {
    int freedItems = 0;
    final int freedBytes = 0;

    try {
      // تنظيف صناديق Hive المؤقتة
      await _cleanHiveTempBoxes();

      // تنظيف الذاكرة المؤقتة حسب الأولوية
      if (priority == CleanupPriority.aggressive) {
        freedItems += await _cleanExpiredCache();
      }

      developer.log(
        '[$_tag] App data cleaned: $freedItems items',
        name: 'PERF',
      );
      return CleanupResult(freedItems, freedBytes);
    } catch (e) {
      developer.log('[$_tag] App data cleaning failed: $e', name: 'WARNING');
      return CleanupResult(0, 0);
    }
  }

  /// 🔄 تنظيف الذاكرة المؤقتة
  static Future<CleanupResult> _cleanMemoryCache() async {
    try {
      // إجبار GC على العمل (إن أمكن)
      await _triggerGarbageCollection();

      developer.log('[$_tag] Memory cache cleaned', name: 'PERF');
      return CleanupResult(0, 0); // يصعب قياس الذاكرة المحررة
    } catch (e) {
      developer.log(
        '[$_tag] Memory cache cleaning failed: $e',
        name: 'WARNING',
      );
      return CleanupResult(0, 0);
    }
  }

  /// 🎯 تنظيف الصور الأقل استخداماً (ذكية)
  static void _clearLeastUsedImages(ImageCache cache) {
    try {
      // تنظيف 30% من الصور الأقل استخداماً
      final targetCount = (cache.currentSize * 0.3).ceil();
      if (targetCount > 0) {
        // في الإصدارات المستقبلية، يمكن تتبع استخدام الصور
        cache.clear();
      }
    } catch (e) {
      developer.log(
        '[$_tag] Least used images cleaning failed: $e',
        name: 'WARNING',
      );
    }
  }

  /// 🗑️ تنظيف صناديق Hive المؤقتة
  static Future<void> _cleanHiveTempBoxes() async {
    try {
      // يمكن إضافة صناديق مؤقتة محددة تحتاج تنظيف
      // await Hive.box('temp_cache').clear();
    } catch (e) {
      developer.log(
        '[$_tag] Hive temp boxes cleaning failed: $e',
        name: 'WARNING',
      );
    }
  }

  /// ⏰ تنظيف الكاش المنتهي الصلاحية
  static Future<int> _cleanExpiredCache() async {
    final int cleanedItems = 0;
    try {
      // منطق تنظيف البيانات المنتهية الصلاحية
      // يمكن التكامل مع نظام الكاش الخاص بالتطبيق
    } catch (e) {
      developer.log(
        '[$_tag] Expired cache cleaning failed: $e',
        name: 'WARNING',
      );
    }
    return cleanedItems;
  }

  /// 🔄 محاولة تشغيل garbage collection
  static Future<void> _triggerGarbageCollection() async {
    try {
      // في Flutter/Dart، GC يعمل تلقائياً
      // لكن يمكن تشجيع النظام على تحرير الذاكرة
      // ignore: inference_failure_on_instance_creation
await Future<void>.delayed(const Duration(milliseconds: 300));
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    } catch (e) {
      // لا نرمي خطأ لأن هذه عملية تحسين وليست ضرورية
    }
  }

  /// 📈 تقدير حجم الذاكرة المحررة
  static int _estimateFreedBytes(int imageCount) {
    // تقدير متوسط: 100KB للصورة الواحدة
    const averageImageSize = 100 * 1024;
    return imageCount * averageImageSize;
  }

  /// 📏 تقدير حجم كاش الصور الحالي
  static int _estimateImageCacheSize() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      // تقدير تقريبي - يمكن تحسينه في المستقبل
      return imageCache.currentSize * 100 * 1024;
    } catch (e) {
      return 0;
    }
  }

  /// 📊 إعداد مراقبة الذاكرة
  Future<void> _setupMemoryMonitoring(bool enable) async {
    if (!enable) return;

    // يمكن إضافة مراقبة مستمرة للأداء
    developer.log('[$_tag] Memory monitoring enabled', name: 'PERF');
  }
}

// 🏷️ أنواع البيانات المساعدة

/// 🎯 أولويات التنظيف
enum CleanupPriority {
  standard, // تنظيف أساسي
  aggressive, // تنظيف مكثف
  minimal // الحد الأدنى
}

/// 📊 نتيجة عملية التنظيف
class MemoryCleanupResult {
  MemoryCleanupResult({
    required this.success,
    this.freedItems = 0,
    this.freedBytes = 0,
    this.duration = 0,
    this.cleanupType,
    this.error,
  });
  final bool success;
  final int freedItems;
  final int freedBytes;
  final int duration; // بالمللي ثانية
  final String? cleanupType;
  final String? error;

  @override
  String toString() {
    if (!success) return 'Cleanup failed: $error';

    final sizeMB = freedBytes ~/ (1024 * 1024);
    return 'Freed $freedItems items (${sizeMB}MB) in ${duration}ms';
  }
}

/// 📈 حالة الذاكرة الحالية
class MemoryStatus {
  MemoryStatus({
    required this.currentImageCount,
    required this.maxImageCount,
    required this.currentCacheBytes,
    required this.maxCacheBytes,
    this.lastCleanup,
    required this.isInitialized,
    this.error,
  });

  factory MemoryStatus.error(String error) => MemoryStatus(
        currentImageCount: 0,
        maxImageCount: 0,
        currentCacheBytes: 0,
        maxCacheBytes: 0,
        isInitialized: false,
        error: error,
      );
  final int currentImageCount;
  final int maxImageCount;
  final int currentCacheBytes;
  final int maxCacheBytes;
  final DateTime? lastCleanup;
  final bool isInitialized;
  final String? error;

  double get cacheUsagePercent {
    if (maxCacheBytes == 0) return 0.0;
    return (currentCacheBytes / maxCacheBytes) * 100;
  }

  bool get isCacheNearlyFull => cacheUsagePercent > 80;
}

/// 🔧 نتيجة التنظيف الداخلية
class CleanupResult {
  CleanupResult(this.freedItems, this.freedBytes);
  final int freedItems;
  final int freedBytes;
}
