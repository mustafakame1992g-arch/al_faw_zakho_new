// data_validation_exception.dart

/// استثناء مخصص لأخطاء التحقق من صحة البيانات.
class DataValidationException implements Exception {
  // الرسالة التوضيحية للخطأ

  DataValidationException(this.dataType, this.message);
  final String
      dataType; // نوع البيانات الذي فشل التحقق منه (مثل 'candidates', 'news')
  final String message;

  @override
  String toString() {
    return 'DataValidationException in $dataType: $message';
  }
}
