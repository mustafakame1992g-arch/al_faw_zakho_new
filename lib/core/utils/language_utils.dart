import 'package:intl/intl.dart';

class LanguageUtils {
  static bool isRTL(String languageCode) {
    return languageCode == 'ar';
  }

  static String getFontFamily(String languageCode) {
    return 'Tajawal'; // استخدام خط واحد للغتين
  }

  static TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.RTL : TextDirection.LTR;
  }
}
