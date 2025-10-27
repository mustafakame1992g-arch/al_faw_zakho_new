// data_load_result.dart

/// 🎯 أنواع أخطاء تحميل البيانات
enum DataLoadErrorType {
  timeout, // انتهاء المهلة
  format, // خطأ في تنسيق البيانات
  validation, // خطأ في التحقق من الصحة
  generic, // خطأ عام
}

/// 📊 نموذج لنتائج تحميل البيانات
class DataLoadResult {
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
  }) =>
      DataLoadResult._(
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
  }) =>
      DataLoadResult._(
        isSuccess: false,
        errorType: errorType,
        message: message,
        details: details,
      );
  final bool isSuccess;
  final DataLoadErrorType? errorType;
  final String? message;
  final String? details;
  final int? elapsedMs;
  final int? candidatesCount;
  final int? faqsCount;
  final int? newsCount;
}
