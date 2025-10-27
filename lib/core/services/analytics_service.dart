import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final List<AnalyticsEvent> _eventBuffer = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    _isInitialized = true;
    _flushEventBuffer();
    debugPrint('✅ AnalyticsService initialized');
  }

  static void trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
    String? error,
    String? category,
  }) {
    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      error: error,
      category: category,
      timestamp: DateTime.now(),
    );

    if (!_isInitialized) {
      _eventBuffer.add(event);
      debugPrint('📦 Analytics event buffered: $eventName');
      return;
    }

    _sendEvent(event);
  }

// إضافة دوال جديدة للـ Analytics Service
  static void trackScreenPerformance(String screenName, Duration loadTime) {
    trackEvent(
      'screen_performance',
      parameters: {
        'screen': screenName,
        'load_time_ms': loadTime.inMilliseconds,
        'performance_rating': loadTime.inMilliseconds < 1000
            ? 'excellent'
            : loadTime.inMilliseconds < 3000
                ? 'good'
                : 'slow'
      },
      category: 'performance',
    );
  }

  // 🗃️ تتبع تحميل البيانات
  static void trackDataLoad(String dataType, int itemCount, String source) {
    trackEvent(
      'data_loaded',
      parameters: {
        'data_type': dataType,
        'item_count': itemCount,
        'source': source,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      category: 'data',
    );
  }

  // 👆 تتبع تفاعل المستخدم
  static void trackUserInteraction(String interactionType, String element) {
    trackEvent(
      'user_interaction',
      parameters: {
        'interaction_type': interactionType,
        'element': element,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      category: 'interaction',
    );
  }

  // ⚙️ تتبع تهيئة المكونات
  static void trackInitialization(String componentName,
      {bool success = true, String? error}) {
    trackEvent(
      'component_initialized',
      parameters: {
        'component': componentName,
        'success': success,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      error: error,
      category: 'initialization',
    );
  }

  // 🚨 تتبع الأخطاء
  static void trackError(
      String operation, dynamic error, StackTrace stackTrace) {
    trackEvent(
      'operation_error',
      parameters: {
        'operation': operation,
        'error_type': error.runtimeType.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      error: error.toString(),
      category: 'errors',
    );

    // في بيئة الإنتاج، يمكن إرسال StackTrace لخدمة تتبع الأخطاء
    if (kDebugMode) {
      debugPrint('🚨 ERROR: $operation - $error');
      debugPrint('📋 StackTrace: $stackTrace');
    }
  }

  // 📤 إرسال الحدث (محاكاة)
  static void _sendEvent(AnalyticsEvent event) {
    // محاكاة إرسال البيانات (يمكن استبدالها بـ Firebase Analytics أو أي خدمة)
    final message = StringBuffer();
    message.write('📊 ANALYTICS: ${event.name}');

    if (event.category != null) {
      message.write(' [${event.category}]');
    }

    if (event.parameters.isNotEmpty) {
      message.write(' - ${event.parameters}');
    }

    if (event.error != null) {
      message.write(' - ERROR: ${event.error}');
    }

    debugPrint(message.toString());
  }

  // 🧹 إرسال الأحداث المؤجلة بعد التهيئة
  static void _flushEventBuffer() {
    _eventBuffer.forEach(_sendEvent);
    _eventBuffer.clear();
  }
}

/// 🧾 نموذج الحدث التحليلي
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final String? error;
  final String? category;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    required this.parameters,
    this.error,
    this.category,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'AnalyticsEvent{name: $name, parameters: $parameters, error: $error, category: $category}';
  }
}
