import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:al_faw_zakho/data/local/local_database.dart';
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';
import 'package:al_faw_zakho/core/errors/global_error_handler.dart';
// استيراد الملفات الجديدة التي أنشأتها
import 'package:al_faw_zakho/data/models/data_load_result.dart';
import 'package:al_faw_zakho/core/errors/data_validation_exception.dart';
import 'package:al_faw_zakho/data/models/processed_data.dart';
import 'package:al_faw_zakho/presentation/screens/error/error_screen.dart'; // تأكد من وجود هذا الملف

/// ⚡ خدمة تحميل البيانات الافتراضية - النسخة المحسنة
class DefaultDataService {
  static const _timeoutSeconds = 10;
  static const _assetPaths = {
    'candidates': 'assets/data/candidates.json',
    'faqs': 'assets/data/faqs.json',
    'news': 'assets/data/news.json',
  };

  /// ✅ تحميل البيانات الافتراضية مع إدارة كاملة للأخطاء
  Future<DataLoadResult> loadDefaultData(BuildContext context) async {
    developer.log('[BOOTSTRAP] Starting offline data initialization...',
        name: 'DATA');

    final stopwatch = Stopwatch()..start();
    DataLoadResult result;

    try {
      // 1. 🧹 تنظيف البيانات القديمة بشكل متوازي
      await _clearExistingData();

      // 2. ⚡ تحميل متوازي لجميع الملفات مع timeout
      final loadedData = await _loadAllAssetsInParallel();

      // 3. 🔍 فك الترميز والتحقق من صحة البيانات
      final processedData = await _processAndValidateData(loadedData);

      // 4. 💾 حفظ البيانات بشكل متوازي
      await _saveAllData(processedData);

      // 5. 🕒 تحديث وقت التعديل
      await _updateLastModifiedTime();

      final elapsedMs = stopwatch.elapsedMilliseconds;
      developer.log(
        '[BOOTSTRAP] Default data loaded successfully ✅ ($elapsedMs ms)',
        name: 'PERF',
      );

      result = DataLoadResult.success(
        //elapsedMs: elapsedMs,
        elapsedMs: stopwatch.elapsedMilliseconds,
        candidatesCount: processedData.candidates.length,
        faqsCount: processedData.faqs.length,
        newsCount: processedData.news.length,
      );
    } on TimeoutException catch (e, stack) {
      result = _handleTimeoutError(e, stack);
    } on FormatException catch (e, stack) {
      result = _handleFormatError(e, stack);
    } on DataValidationException catch (e, stack) {
      result = _handleValidationError(e, stack);
    } catch (e, stack) {
      result = _handleGenericError(e, stack);
    } finally {
      stopwatch.stop();
    }

    // 6. 📊 تسجيل نتائج التحميل
    _logDataLoadResult(result);
    return result;
  }

  /// 🧹 مسح البيانات القديمة بشكل متوازي
  Future<void> _clearExistingData() async {
    developer.log('[BOOTSTRAP] Clearing existing data...', name: 'DATA');

    await Future.wait([
      LocalDatabase.clearCandidates(),
      LocalDatabase.clearFAQs(),
      LocalDatabase.clearNews(),
    ], eagerError: true);
  }

  /// ⚡ تحميل متوازي لجميع الملفات
  Future<Map<String, String>> _loadAllAssetsInParallel() async {
    final loadFutures = _assetPaths.map((key, path) => MapEntry(
        key,
        rootBundle.loadString(path).timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw TimeoutException('Timeout loading $key'))));

    final results = await Future.wait(loadFutures.values, eagerError: true);

    return Map.fromIterables(loadFutures.keys, results);
  }

  /// 🔍 معالجة والتحقق من صحة البيانات
  Future<ProcessedData> _processAndValidateData(
      Map<String, String> rawData) async {
    // فك الترميز بشكل متوازي
    final decodeResults = await Future.wait([
      _decodeJsonWithValidation(rawData['candidates']!, 'candidates'),
      _decodeJsonWithValidation(rawData['faqs']!, 'faqs'),
      _decodeJsonWithValidation(rawData['news']!, 'news'),
    ]);

    final candidatesJson = decodeResults[0] as List;
    final faqsJson = decodeResults[1] as List;
    final newsJson = decodeResults[2] as List;

    // التحقق من عدم الفراغ
    _validateNonEmptyData(candidatesJson, faqsJson, newsJson);

    // التحويل إلى موديلات
    final candidates = _processCandidates(candidatesJson);
    final faqs = _processFaqs(faqsJson);
    final news = _processNews(newsJson);

    // فحص جودة متقدم
    _performQualityChecks(candidates, faqs, news);

    return ProcessedData(
      candidates: candidates,
      faqs: faqs,
      news: news,
    );
  }

  /// 🔧 فك ترميز JSON مع التحقق من الصحة
  static Future<dynamic> _decodeJsonWithValidation(
      String jsonString, String dataType) async {
    try {
      return jsonDecode(jsonString);
    } on FormatException catch (e) {
      throw FormatException('تنسيق JSON غير صحيح في $dataType: ${e.message}');
    }
  }

  /// ✅ التحقق من أن البيانات غير فارغة
  static void _validateNonEmptyData(List candidates, List faqs, List news) {
    if (candidates.isEmpty) {
      throw DataValidationException('candidates', 'قائمة المرشحين فارغة');
    }
    if (faqs.isEmpty) {
      throw DataValidationException('faqs', 'قائمة الأسئلة الشائعة فارغة');
    }
    if (news.isEmpty) {
      throw DataValidationException('news', 'قائمة الأخبار فارغة');
    }
  }

  /// 👥 معالجة بيانات المرشحين
  static List<CandidateModel> _processCandidates(List candidatesJson) {
    return candidatesJson
        .map((e) => CandidateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// ❓ معالجة الأسئلة الشائعة
  static List<FaqModel> _processFaqs(List faqsJson) {
    return faqsJson
        .map((e) => FaqModel.fromJson(Map<String, dynamic>.from(e)))
        .where((faq) =>
            (faq.questionAr.isNotEmpty == true) ||
            (faq.questionEn.isNotEmpty == true))
        .toList();
  }

  /// 📰 معالجة الأخبار
  static List<NewsModel> _processNews(List newsJson) {
    return newsJson
        .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e)))
        .where((news) =>
            news.titleAr.isNotEmpty ||
            news.titleEn.isNotEmpty) // ✅ تحقق من وجود عنوان عربي أو إنجليزي
        .toList();
  }

  /// 🔎 فحص جودة متقدم للبيانات - النسخة النهائية المصححة
  static void _performQualityChecks(List<CandidateModel> candidates,
      List<FaqModel> faqs, List<NewsModel> news) {
    developer.log('[BOOTSTRAP] Performing quality checks...',
        name: 'VALIDATION');

    // 1. فحص المرشحين
    for (final candidate in candidates) {
      if (candidate.nameAr.isEmpty && candidate.nameEn.isEmpty) {
        throw DataValidationException('candidates',
            'المرشح ${candidate.id} لا يحتوي على اسم عربي أو إنجليزي');
      }
    }

    // 2. فحص الأسئلة الشائعة
    for (final faq in faqs) {
      if (faq.questionAr.isEmpty == true) {
        throw DataValidationException(
            'faqs', 'يوجد سؤال بدون نص في الأسئلة الشائعة');
      }
    }

    // 3. فحص الأخبار - ✅ التصحيح هنا
    for (final newsItem in news) {
      // التحقق من وجود عنوان
      if (newsItem.titleAr.isEmpty && newsItem.titleEn.isEmpty) {
        throw DataValidationException(
            'news', 'خبر ${newsItem.id} لا يحتوي على عنوان عربي أو إنجليزي');
      }

      // تحقق إضافي من المحتوى
      if (newsItem.contentAr.isEmpty && newsItem.contentEn.isEmpty) {
        developer.log(
            '[BOOTSTRAP] Warning: News item ${newsItem.id} has no content in both languages',
            name: 'VALIDATION');
      }

      // فحص التواريخ - ✅ الآن داخل الـ loop الصحيح
      final now = DateTime.now();
      if (newsItem.publishDate.isAfter(now.add(const Duration(days: 1)))) {
        developer.log(
            '[BOOTSTRAP] Warning: News item ${newsItem.id} has future date (${newsItem.publishDate})',
            name: 'VALIDATION');
      }

      // فحص إضافي للصورة إن أردت
      if (newsItem.imagePath.isEmpty) {
        developer.log('[BOOTSTRAP] Info: News item ${newsItem.id} has no image',
            name: 'VALIDATION');
      }
    }

    developer.log('[BOOTSTRAP] Quality checks completed successfully',
        name: 'VALIDATION');
  }

  /// 💾 حفظ جميع البيانات بشكل متوازي
  Future<void> _saveAllData(ProcessedData data) async {
    await Future.wait([
      LocalDatabase.saveCandidates(data.candidates),
      LocalDatabase.saveFAQs(data.faqs),
      LocalDatabase.saveNews(data.news),
    ], eagerError: true);
  }

  /// 🕒 تحديث وقت آخر تعديل
  static Future<void> _updateLastModifiedTime() async {
    await LocalDatabase.saveAppData(
        'last_data_update', DateTime.now().toIso8601String());
  }

  /// ⏰ معالجة أخطاء المهلة
  DataLoadResult _handleTimeoutError(TimeoutException e, StackTrace stack) {
    developer.log('[BOOTSTRAP] Timeout while loading data ❌',
        name: 'ERROR', error: e, stackTrace: stack);

    GlobalErrorHandler.capture(
      e,
      stack,
      hint: 'Offline bootstrap timeout',
    );

    return DataLoadResult.failure(
      errorType: DataLoadErrorType.timeout,
      message: 'استغرقت عملية تحميل البيانات وقتاً طويلاً',
      details: 'تحقق من حجم الملفات وسرعة الجهاز',
    );
  }

  /// 🏗️ معالجة أخطاء التنسيق
  DataLoadResult _handleFormatError(FormatException e, StackTrace stack) {
    developer.log('[BOOTSTRAP] JSON format error ❌',
        name: 'ERROR', error: e, stackTrace: stack);

    GlobalErrorHandler.capture(e, stack, hint: 'JSON format error');

    return DataLoadResult.failure(
      errorType: DataLoadErrorType.format,
      message: 'تنسيق البيانات غير صحيح',
      details: 'قد تكون ملفات البيانات تالفة أو غير متوافقة',
    );
  }

  /// ✅ معالجة أخطاء التحقق من الصحة
  DataLoadResult _handleValidationError(
      DataValidationException e, StackTrace stack) {
    developer.log('[BOOTSTRAP] Data validation failed ❌',
        name: 'ERROR', error: e, stackTrace: stack);

    GlobalErrorHandler.capture(e, stack, hint: 'Data validation failed');

    return DataLoadResult.failure(
      errorType: DataLoadErrorType.validation,
      message: 'بيانات غير صالحة',
      details: '${e.dataType}: ${e.message}',
    );
  }

  /// ❌ معالجة الأخطاء العامة
  DataLoadResult _handleGenericError(Object e, StackTrace stack) {
    developer.log('[BOOTSTRAP] Unexpected error: $e ❌',
        name: 'ERROR', error: e, stackTrace: stack);

    GlobalErrorHandler.capture(e, stack, hint: 'Offline bootstrap failure');

    return DataLoadResult.failure(
      errorType: DataLoadErrorType.generic,
      message: 'حدث خطأ غير متوقع أثناء تحميل البيانات',
      details: e.toString(),
    );
  }

  /// 📊 تسجيل نتائج التحميل
  void _logDataLoadResult(DataLoadResult result) {
    if (result.isSuccess) {
      developer.log(
          '[BOOTSTRAP] Data load completed: '
          '${result.candidatesCount} candidates, '
          '${result.faqsCount} FAQs, '
          '${result.newsCount} news articles',
          name: 'SUCCESS');
    } else {
      developer.log(
          '[BOOTSTRAP] Data load failed: ${result.errorType} - ${result.message}',
          name: 'FAILURE');
    }
  }
}

/// 🎯 استخدام الخدمة في الـ UI
Future<void> loadDefaultDataWithUI(BuildContext context) async {
  final result = await DefaultDataService().loadDefaultData(context);

  if (!result.isSuccess) {
    // ignore: use_build_context_synchronously
    _showErrorScreen(context, result);
  }
}

/// 🖥️ عرض شاشة الخطأ المناسبة
void _showErrorScreen(BuildContext context, DataLoadResult result) {
  final errorConfig = _getErrorConfig(result.errorType!);

  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => ErrorScreen(
        title: errorConfig.title,
        message: '${result.message}\n${result.details ?? ''}',
        ctaLabel: errorConfig.ctaLabel,
        onRetry: () => loadDefaultDataWithUI(context),
        showRetry: errorConfig.showRetry,
      ),
    ),
  );
}

/// ⚙️ تكوين رسائل الخطأ بناءً على النوع
ErrorConfig _getErrorConfig(DataLoadErrorType errorType) {
  switch (errorType) {
    case DataLoadErrorType.timeout:
      return ErrorConfig(
        title: 'مهلة التحميل',
        ctaLabel: 'إعادة المحاولة',
        showRetry: true,
      );
    case DataLoadErrorType.format:
      return ErrorConfig(
        title: 'خطأ في التنسيق',
        ctaLabel: 'إعادة التحميل',
        showRetry: true,
      );
    case DataLoadErrorType.validation:
      return ErrorConfig(
        title: 'بيانات غير صالحة',
        ctaLabel: 'فحص الملفات',
        showRetry: false,
      );
    case DataLoadErrorType.generic:
      return ErrorConfig(
        title: 'خطأ غير متوقع',
        ctaLabel: 'إعادة المحاولة',
        showRetry: true,
      );
  }
}
