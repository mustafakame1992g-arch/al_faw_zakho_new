// data_validation_exception.dart

/// استثناء مخصص لأخطاء التحقق من صحة البيانات.
class DataValidationException implements Exception {
  final String dataType; // نوع البيانات الذي فشل التحقق منه (مثل 'candidates', 'news')
  final String message; // الرسالة التوضيحية للخطأ

  DataValidationException(this.dataType, this.message);

  @override
  String toString() {
    return 'DataValidationException in $dataType: $message';
  }
}