import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class UiUtils {
  static void showLanguageChangeSnackBar(
    BuildContext context,
    String newLanguage,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🌍 ${context.tr('language_changed')}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> restartApp(BuildContext context) async {
    // إعادة تشغيل التطبيق لتطبيق التغييرات
  }
}
