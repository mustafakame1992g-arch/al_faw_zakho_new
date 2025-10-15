// default_data_service.dart

// 🎯 أنواع أخطاء تحميل البيانات
import 'package:al_faw_zakho/data/models/candidate_model.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/data/models/news_model.dart';

enum DataLoadErrorType {
  timeout, format, validation, generic,
}

// 📊 نموذج لنتائج تحميل البيانات
class DataLoadResult {
  final bool isSuccess;
  final DataLoadErrorType? errorType;
  final String? message;
  final String? details;
  final int? elapsedMs;
  final int? candidatesCount;
  final int? faqsCount;
  final int? newsCount;

  DataLoadResult._({
    required this.isSuccess,
    this.errorType,
    this.message,
    this.details,
    this.elapsedMs,
    this.candidatesCount,
    this.faqsCount,
    this.newsCount,
  });

  factory DataLoadResult.success({
    required int elapsedMs,
    required int candidatesCount,
    required int faqsCount,
    required int newsCount,
  }) => DataLoadResult._(
    isSuccess: true,
    elapsedMs: elapsedMs,
    candidatesCount: candidatesCount,
    faqsCount: faqsCount,
    newsCount: newsCount,
  );

  factory DataLoadResult.failure({
    required DataLoadErrorType errorType,
    required String message,
    String? details,
  }) => DataLoadResult._(
    isSuccess: false,
    errorType: errorType,
    message: message,
    details: details,
  );
}

// ❌ استثناء مخصص لأخطاء التحقق من الصحة
class DataValidationException implements Exception {
  final String dataType;
  final String message;

  DataValidationException(this.dataType, this.message);

  @override
  String toString() => 'DataValidationException ($dataType): $message';
}

// 📦 نموذج للبيانات المعالجة
class ProcessedData {
  final List<CandidateModel> candidates;
  final List<FaqModel> faqs;
  final List<NewsModel> news;

  ProcessedData({
    required this.candidates,
    required this.faqs,
    required this.news,
  });
}

// ⚡ الخدمة الرئيسية
class DefaultDataService {
  // ... كود الخدمة الذي لديك ...
}
