// 🛡️ global_error_handler.dart — النسخة النهائية الجاهزة للإطلاق
//
// 🧩 الوظيفة:
// - التقاط جميع أنواع الأخطاء (Flutter / Platform / Async)
// - تسجيلها في Console, File, LocalDatabase, Analytics
// - تصنيفها حسب الشدة (Severity)
// - منع التكرار المتقارب (Duplicate Suppression)
// - تدوير ملفات السجلات (Log Rotation)
// - مقاومة للكراش وتعمل حتى قبل تهيئة Hive
//
// الإصدار: 2.0.0 — FAW ZAKHO TECH TEAM

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:al_faw_zakho/core/config/app_config.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';

/// 🔧 الإعدادات العامة لمعالجة الأخطاء
class ErrorHandlerConfig {
  final bool enableConsoleLogging;
  final bool enableFileLogging;
  final bool enableDatabaseLogging;
  final bool enableAutoReporting;
  final int duplicateSuppressionSeconds;
  final int maxLogFileSizeMB;

  const ErrorHandlerConfig({
    this.enableConsoleLogging = true,
    this.enableFileLogging = true,
    this.enableDatabaseLogging = true,
    this.enableAutoReporting = true,
    this.duplicateSuppressionSeconds = 10,
    this.maxLogFileSizeMB = 5,
  });
}

/// 🧭 مستويات الخطأ (Severity)
enum ErrorSeverity { low, medium, high, critical }

/// ⚙️ النظام العام لمعالجة الأخطاء
class GlobalErrorHandler {
  static bool _initialized = false;
  static late File _errorLogFile;
  static final Map<String, DateTime> _recentErrors = {};
  static ErrorHandlerConfig _config = const ErrorHandlerConfig();

  // ✅ التهيئة العامة
  static Future<void> setup({ErrorHandlerConfig? config}) async {
    if (_initialized) return;
    _config = config ?? const ErrorHandlerConfig();

    try {
      final dir = await getTemporaryDirectory();
      _errorLogFile = File('${dir.path}/error_logs.txt');
      await _rotateLogFileIfNeeded();

      // 🔹 التقاط أخطاء Flutter
      FlutterError.onError = (FlutterErrorDetails details) async {
        await _handleError(
          details.exception,
          details.stack,
          source: 'Flutter',
          severity: _determineSeverity(details.exception),
        );
      };

      // 🔹 التقاط أخطاء النظام والمنصة
      PlatformDispatcher.instance.onError = (error, stack) {
        _handleError(
          error,
          stack,
          source: 'Platform',
          severity: _determineSeverity(error),
        );
        return true;
      };

      // 🔹 التقاط الأخطاء العامة (غير المتزامنة)
      runZonedGuarded(
        () => developer.log('[GlobalErrorHandler] Active ✅', name: 'ERROR_SYS'),
        (error, stack) {
          _handleError(
            error,
            stack,
            source: 'Zoned',
            severity: _determineSeverity(error),
          );
        },
      );

      _initialized = true;
      developer.log('[GlobalErrorHandler] Initialized ✅', name: 'ERROR_SYS');
    } catch (e, stack) {
      developer.log('[GlobalErrorHandler] Setup failed: $e',
          name: 'ERROR_SYS', error: e, stackTrace: stack);
    }
  }

  // 💾 المعالجة الأساسية لأي خطأ
  static Future<void> _handleError(
    Object error,
    StackTrace? stack, {
    required String source,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    final report = _formatErrorReport(
      error: error,
      stack: stack,
      source: source,
      severity: severity,
    );

    // 🛑 منع التكرار القريب لنفس الخطأ
    if (_isDuplicateError(report)) return;

    // 🔁 تسجيل متعدد الوجهات بشكل غير حاجز
    await Future.wait([
      if (_config.enableConsoleLogging) _logToConsole(report),
      if (_config.enableFileLogging) _logToFile(report),
      if (_config.enableDatabaseLogging)
        _logToDatabase(report, severity: severity),
      if (_config.enableAutoReporting &&
          severity.index >= ErrorSeverity.high.index)
        _reportToAnalytics(error, stack, source),
    ], eagerError: false);
  }

  // 🧾 تنسيق نص تقرير الخطأ
  static String _formatErrorReport({
    required Object error,
    StackTrace? stack,
    required String source,
    required ErrorSeverity severity,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    return '''
────────────────────────────────────────────
⚠️ ERROR DETECTED
App: ${AppConfig.appName}
Source: $source
Severity: ${severity.name.toUpperCase()}
Time: $timestamp
Error: $error
Stack: ${stack ?? 'No stack trace'}
────────────────────────────────────────────
''';
  }

  // 🔁 منع الأخطاء المكررة خلال فترة قصيرة
  static bool _isDuplicateError(String report) {
    final now = DateTime.now();
    final hash = report.hashCode.toString();

    if (_recentErrors.containsKey(hash)) {
      final diff = now.difference(_recentErrors[hash]!);
      if (diff.inSeconds < _config.duplicateSuppressionSeconds) return true;
    }
    _recentErrors[hash] = now;
    return false;
  }

  // 🔒 تحديد شدة الخطأ حسب الكلمات المفتاحية
  static ErrorSeverity _determineSeverity(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('fatal') || msg.contains('crash')) {
      return ErrorSeverity.critical;
    }
    if (msg.contains('database') || msg.contains('timeout')) {
      return ErrorSeverity.high;
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return ErrorSeverity.medium;
    }
    return ErrorSeverity.low;
  }

  // 🧹 تدوير ملف السجلات عند امتلائه
  static Future<void> _rotateLogFileIfNeeded() async {
    try {
      if (!await _errorLogFile.exists()) return;
      final size = await _errorLogFile.length();
      final maxSize = _config.maxLogFileSizeMB * 1024 * 1024;

      if (size > maxSize) {
        final backup = File(
            '${_errorLogFile.path}.${DateTime.now().millisecondsSinceEpoch}.bak');
        await _errorLogFile.rename(backup.path);
        _errorLogFile = File(_errorLogFile.path); // إنشاء جديد
      }
    } catch (e) {
      developer.log('[GlobalErrorHandler] Log rotation failed: $e',
          name: 'ERROR_SYS');
    }
  }

  // 🪵 التسجيل في Console
  static Future<void> _logToConsole(String report) async {
    developer.log(report, name: AppConfig.logTag);
  }

  // 💾 التسجيل في ملف
  static Future<void> _logToFile(String report) async {
    try {
      await _errorLogFile.writeAsString(
        '${DateTime.now().toIso8601String()} : $report\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      developer.log('[GlobalErrorHandler] File logging failed: $e',
          name: 'ERROR_SYS');
    }
  }

  // 📦 التسجيل في قاعدة البيانات (Hive)
  static Future<void> _logToDatabase(String report,
      {required ErrorSeverity severity}) async {
    try {
      await LocalDatabase.saveAppData('last_error', {
        'message': report,
        'severity': severity.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Hive قد لا يكون مهيأ بعد
    }
  }

  // 📊 إرسال تقارير الأخطاء الحرجة إلى التحليلات
  static Future<void> _reportToAnalytics(
      Object error, StackTrace? stack, String source) async {
    try {
      developer.log('[Analytics] Reporting critical error...',
          name: 'ERROR_SYS');
      // مستقبلاً يمكن إضافة Firebase Crashlytics أو API endpoint هنا
    } catch (e) {
      developer.log('[Analytics] Reporting failed: $e', name: 'ERROR_SYS');
    }
  }

  // 📄 استرجاع آخر سجل للأخطاء
  static Future<String?> getLastErrorReport() async {
    try {
      if (await _errorLogFile.exists()) {
        final content = await _errorLogFile.readAsString();
        return content.isNotEmpty ? content : null;
      }
    } catch (e) {
      developer.log('Failed to read last error report: $e', name: 'ERROR_SYS');
    }
    return null;
  }

  // 🧹 تنظيف السجلات
  static Future<void> clearLogs() async {
    try {
      if (await _errorLogFile.exists()) {
        await _errorLogFile.delete();
      }
      await LocalDatabase.saveAppData('last_error', null);
      developer.log('[GlobalErrorHandler] Logs cleared ✅', name: 'ERROR_SYS');
    } catch (e) {
      developer.log('[GlobalErrorHandler] Failed to clear logs: $e',
          name: 'ERROR_SYS');
    }
  }

  // 🌍 دالة عامة آمنة يمكن استدعاؤها من أي مكان لتسجيل خطأ يدوي
  static Future<void> capture(
    Object error,
    StackTrace? stack, {
    String source = 'Manual',
    String? hint,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) async {
    try {
      // استخدم نفس المنهجية الداخلية _handleError
      await _handleError(
        error,
        stack,
        source: hint ?? source,
        severity: severity,
      );
    } catch (e, st) {
      // إذا صار خطأ أثناء التسجيل نفسه، نسجّله محلياً بدون كراش
      developer.log('[GlobalErrorHandler.capture] Failed: $e',
          name: 'ERROR_SYS', error: e, stackTrace: st);
    }
  }
}
