import 'package:flutter/material.dart';
class AppConstants {
  // إعدادات التطبيق العامة
  static const String appName = 'Foundation App';
  static const String defaultLanguage = 'ar';
  static const Locale defaultLocale = Locale('ar');
  static const ThemeMode defaultTheme = ThemeMode.system;
  
  // إعدادات الـ Fallback
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration slowOperationThreshold = Duration(milliseconds: 100);
  
  // مفاتيح التخزين
  static const String themePreferenceKey = 'theme_mode';
  static const String languagePreferenceKey = 'language_code';
}