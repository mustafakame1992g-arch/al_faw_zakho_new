import 'package:flutter/foundation.dart';
import 'package:al_faw_zakho/core/constants/app_constants.dart';

class PerformanceTracker {
  static final Map<String, Duration> _operationTimings = {};
  static final Map<String, int> _operationCounts = {};

  static void track(String operationName, Duration duration,
      {String? category}) {
    final key = category != null ? '$category::$operationName' : operationName;

    // تحديث الإحصائيات
    _operationTimings.update(key, (value) => value + duration,
        ifAbsent: () => duration);
    _operationCounts.update(key, (value) => value + 1, ifAbsent: () => 1);

    // التحذير من العمليات البطيئة
    if (duration > AppConstants.slowOperationThreshold) {
      debugPrint(
          '⚠️ PERFORMANCE WARNING: $key took ${duration.inMilliseconds}ms');
    } else {
      if (kDebugMode) {
        debugPrint('⚡ PERFORMANCE OK: $key took ${duration.inMilliseconds}ms');
      }
    }
  }

  static Duration getAverageTime(String operationName, {String? category}) {
    final key = category != null ? '$category::$operationName' : operationName;
    final total = _operationTimings[key] ?? Duration.zero;
    final count = _operationCounts[key] ?? 1;
    return Duration(microseconds: total.inMicroseconds ~/ count);
  }

  static void logPerformanceSummary() {
    if (_operationTimings.isEmpty) return;

    debugPrint('📊 PERFORMANCE SUMMARY:');
    _operationTimings.forEach((key, duration) {
      final count = _operationCounts[key] ?? 1;
      final average = Duration(microseconds: duration.inMicroseconds ~/ count);
      debugPrint(
          '   $key: ${duration.inMilliseconds}ms total, $average average ($count operations)');
    });
  }
}
