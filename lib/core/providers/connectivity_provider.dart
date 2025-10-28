import 'dart:async';
import 'dart:async' show StreamSubscription, Timer, unawaited;

import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/core/services/performance_tracker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 🌐 [ConnectivityProvider] - مدير حالة الاتصال بالإنترنت المتقدم
///
/// 🎯 **الوظيفة**: مراقبة حالة الاتصال وتحديث الواجهة تلقائياً
/// ⚡ **الإصدار**: 3.0 (محسّن للأداء والموثوقية)
///
/// ✨ **المميزات المحسنة**:
/// • مراقبة ذكية مع تجنب التحديثات غير الضرورية
/// • نظام Fallback متقدم مع exponential backoff
/// • إدارة دورة الحياة بشكل آمن
/// • تحسين استهلاك البطارية
/// • دعم الاختبارات Unit Testing
class ConnectivityProvider with ChangeNotifier {
  // الحالة الداخلية
  bool _isOnline = true;
  bool _isInitialized = false;
  int _retryCount = 0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;

  // الثوابت
  static const int _maxRetryAttempts = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _statusUpdateCooldown = Duration(milliseconds: 500);
  DateTime? _lastStatusUpdate;

  // Getters
  bool get isOnline => _isOnline;
  bool get isInitialized => _isInitialized;
  bool get isMonitoringActive => _connectivitySubscription != null;

  /// ✅ فحص الاتصال مع تحسين الأداء
  Future<bool> checkConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final result = _getPrimaryConnectivityResult(results);
      return _updateConnectivityStatus(result, forceNotify: false);
    } catch (e) {
      debugPrint('❌ Error checking connection: $e');
      return _handleConnectionError(e);
    }
  }

  /// 🚀 تهيئة المدير مع تحسين إدارة الموارد
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('ℹ️ ConnectivityProvider already initialized');
      return;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // إلغاء أي عمليات سابقة
      await _cleanup();

      // الحصول على الحالة الأولية
      final initialResults = await Connectivity().checkConnectivity();
      final initialResult = _getPrimaryConnectivityResult(initialResults);
      _updateConnectivityStatus(initialResult, forceNotify: false);

      // بدء المراقبة - ✅ تحسين الاستماع
      _connectivitySubscription = Connectivity()
          .onConnectivityChanged
          .distinct() // تجنب التكرارات غير الضرورية
          .listen(_handleConnectivityChange);

      _isInitialized = true;
      _retryCount = 0;

      AnalyticsService.trackInitialization(
        'ConnectivityProvider',
        success: true,
      );

      debugPrint('✅ ConnectivityProvider initialized successfully');
    } catch (e, stackTrace) {
      _handleInitializationError(e, stackTrace, stopwatch.elapsedMilliseconds);
    } finally {
      stopwatch.stop();
      PerformanceTracker.track('ConnectivityProvider_Init', stopwatch.elapsed);
    }
  }

  /// 🔄 معالجة تغييرات الاتصال مع منع التحديثات السريعة
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final result = _getPrimaryConnectivityResult(results);

    // منع التحديثات المتكررة جداً
    final now = DateTime.now();
    if (_lastStatusUpdate != null &&
        now.difference(_lastStatusUpdate!) < _statusUpdateCooldown) {
      return;
    }

    _updateConnectivityStatus(result);
    _lastStatusUpdate = now;
  }

  /// 📊 تحديث حالة الاتصال مع التحسين
  bool _updateConnectivityStatus(
    ConnectivityResult result, {
    bool forceNotify = true,
  }) {
    final newStatus = result != ConnectivityResult.none;

    // تحديث فقط إذا تغيرت الحالة أو إذا كان إجباري
    if (_isOnline != newStatus || forceNotify) {
      final oldStatus = _isOnline;
      _isOnline = newStatus;

      // تسجيل التحليل فقط عند التغيير الفعلي
      if (oldStatus != newStatus) {
        AnalyticsService.trackEvent(
          'connectivity_changed',
          parameters: {
            'old_status': oldStatus ? 'online' : 'offline',
            'new_status': newStatus ? 'online' : 'offline',
            'connection_type': result.toString(),
            'retry_count': _retryCount,
          },
          category: 'connectivity',
        );

        debugPrint(
          '🌐 Connectivity changed: ${oldStatus ? 'Online' : 'Offline'} → ${newStatus ? 'Online' : 'Offline'} (${result.toString()})',
        );
      }

      notifyListeners();
    }

    return _isOnline;
  }

  /// 🛡️ معالجة أخطاء التهيئة مع exponential backoff
  void _handleInitializationError(
    dynamic error,
    StackTrace stackTrace,
    int elapsedMs,
  ) {
    _retryCount++;

    if (_retryCount <= _maxRetryAttempts) {
      final retryDelay =
          _initialRetryDelay * _retryCount; // exponential backoff
      debugPrint(
        '🔄 Retrying in ${retryDelay.inSeconds}s (attempt $_retryCount/$_maxRetryAttempts)',
      );

       // ✅ الإصلاح: استخدام Future.microtask بدلاً من استدعاء init مباشرة
      _retryTimer?.cancel();
_retryTimer = Timer(retryDelay, () {
  unawaited(init()); // ✅ جدولة مع توضيح fire-and-forget
});
 // لا تنادِ init() مباشرة

      
      // ❌ إزالة السطر الذي كان يسبب المشكلة:
      // init(); // هذا كان السطر 194 المسبب للخطأ
    } else {
      // Fallback إلى وضع الاتصال افتراضي
      _activateFallbackMode(error, elapsedMs);
    }

    AnalyticsService.trackError('ConnectivityProvider_Init', error, stackTrace);

    AnalyticsService.trackInitialization(
      'ConnectivityProvider',
      success: false,
      error: error.toString(),
    );
  }

  /// 🆘 تفعيل وضع Fallback الآمن
  void _activateFallbackMode(dynamic error, int elapsedMs) {
    _isOnline = true; // افترض اتصال للسماح بالتجربة
    _isInitialized = true;

    AnalyticsService.trackEvent(
      'connectivity_fallback_activated',
      parameters: {
        'retry_attempts': _retryCount,
        'error': error.toString(),
      },
    );

    debugPrint(
      '🛡️ Fallback activated after $_retryCount attempts - Assuming online',
    );
    notifyListeners();
  }

  Future<void> _cleanup() async {
  final sub = _connectivitySubscription;
  _connectivitySubscription = null;
  if (sub != null) {
    await sub.cancel(); // ✅ لا تتركها بدون await
  }

  _retryTimer?.cancel();
  _retryTimer = null;

  _retryCount = 0;
  _lastStatusUpdate = null;
}

  /// 🔄 إعادة التعيين للمساعدة في الاسترداد
  Future<void> reset() async {
    await _cleanup();
    _isInitialized = false;
    _isOnline = true;
    notifyListeners();
    await init();
  }

  /// 🎯 الحصول على نتيجة الاتصال الأساسية
  ConnectivityResult _getPrimaryConnectivityResult(
    List<ConnectivityResult> results,
  ) {
    if (results.isEmpty) return ConnectivityResult.none;

    // إعطاء الأولوية للاتصالات الأفضل
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }
    if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    if (results.contains(ConnectivityResult.vpn)) return ConnectivityResult.vpn;
    if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityResult.bluetooth;
    }

    return results.first;
  }

  /// ❌ معالجة أخطاء الاتصال
  bool _handleConnectionError(dynamic error) {
    debugPrint('❌ Connection check failed: $error');

    // في حالة الخطأ، افترض عدم الاتصال للسلامة
    final oldStatus = _isOnline;
    _isOnline = false;

    if (oldStatus != _isOnline) {
      notifyListeners();
    }

    return _isOnline;
  }

 @override
void dispose() {
  // ✅ ألغِ الاشتراك بشكل صريح في dispose — يرضي lint "cancel_subscriptions"
  final sub = _connectivitySubscription;
  _connectivitySubscription = null;
  if (sub != null) {
    unawaited(sub.cancel()); // لا نقدر نعمل await داخل dispose، فاستخدم unawaited
  }

  _retryTimer?.cancel();
  _retryTimer = null;

  super.dispose();
}

  /// 🧪 دعم الاختبارات
  @visibleForTesting
  void simulateConnectivityChange(ConnectivityResult result) {
    _updateConnectivityStatus(result);
  }
}
