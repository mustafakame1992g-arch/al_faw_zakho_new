// 📘 app_config.dart — إعدادات التطبيق المركزية
// هذا الملف هو المرجع العام للثوابت العامة، التوقيتات، ومسارات البيانات.
// الهدف: توحيد القيم حتى لا تتكرر داخل الملفات الأخرى.

import 'package:flutter/foundation.dart';

class AppConfig {
  // --------------------------------------------------
  // 🔧 إعدادات عامة
  // --------------------------------------------------
  static const String appName = 'تجمع الفاو زاخو';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String developer = 'FAW ZAKHO TECH TEAM';
  static const bool enableMaterial3 = true;

  // --------------------------------------------------
  // 🌐 إعدادات الشبكة / API (للمستقبل)
  // --------------------------------------------------
  static const String baseUrl = 'https://api.fawzakho.org';
  static const Duration apiTimeout = Duration(seconds: 20);

  // --------------------------------------------------
  // 🕒 إعدادات التهيئة (Initialization Phases)
  // --------------------------------------------------
  // المدة القصوى المسموح بها لكل مرحلة من مراحل التهيئة
  static const Map<String, int> phaseTimeouts = {
    'Core Providers': 15, // ثوانٍ
    'Connectivity Check': 10,
    'Data Loading': 30,
    'Data Validation': 20,
    'Final Setup': 25,
  };

  // --------------------------------------------------
  // ⚙️ إعدادات الأداء
  // --------------------------------------------------
  static const int imageCacheMaxCount = 100; // عدد الصور في الكاش
  static const int imageCacheMaxBytes = 50 << 20; // 50MB
  static const bool useLowEndMode = true; // تفعيل نمط الأجهزة الضعيفة
  static const bool enablePrecache = true; // تحميل مسبق للأصول

  // --------------------------------------------------
  // 📦 إعدادات البيانات المحلية
  // --------------------------------------------------
  static const String hiveCandidatesBox = 'candidates';
  static const String hiveFaqsBox = 'faqs';
  static const String hiveNewsBox = 'news';
  static const String hiveOfficesBox = 'offices';
  static const String hiveMetaBox = 'meta_box';

  // --------------------------------------------------
  // 🧩 ملفات JSON الثابتة داخل الأصول
  // --------------------------------------------------
  static const String defaultDataFile = 'assets/data/default_data.json';
  static const String candidatesFile = 'assets/data/candidates.json';
  static const String faqsFile = 'assets/data/faqs.json';
  static const String newsFile = 'assets/data/news.json';
  static const String officesFile = 'assets/data/offices.json';
  static const String metaFile = 'assets/data/meta.json';

  // --------------------------------------------------
  // 🛡️ إعدادات الأمان (للمستقبل)
  // --------------------------------------------------
  static const bool enableDataChecksum = true; // للتحقق من سلامة البيانات
  static const String encryptionKey =
      'FawZakho_2025_Key'; // مفتاح تشفير افتراضي

  // --------------------------------------------------
  // 🪵 إعدادات السجلات (Logs)
  // --------------------------------------------------
  static const bool enableDebugLogs = kDebugMode; // فعالة في التطوير فقط
  static const int maxLogLength = 2000; // الطول الأقصى لرسالة log
  static const String logTag = 'FAW_APP_LOG';

  // --------------------------------------------------
  // 💬 إعدادات الواجهة (UI / UX)
  // --------------------------------------------------
  static const Duration splashDuration = Duration(seconds: 3);
  static const bool enableAnimations = true;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const String defaultFontArabic = 'Tajawal';
  static const String defaultFontEnglish = 'Roboto';

  // --------------------------------------------------
  // 🔔 إعدادات الإعلانات (للمستقبل)
  // --------------------------------------------------
  static const bool enableAds = false;
  static const String adBannerId = 'ca-app-pub-xxxxxx';
  static const String adInterstitialId = 'ca-app-pub-yyyyyy';

  // --------------------------------------------------
  // 📅 إعدادات النسخ الاحتياطي والمزامنة
  // --------------------------------------------------
  static const Duration backupInterval = Duration(days: 7);
  static const Duration autoSyncInterval = Duration(hours: 12);
  static const bool enableAutoRecovery = true;

  // --------------------------------------------------
  // 🧠 إعدادات الذكاء الاصطناعي (اختياري)
  // --------------------------------------------------
  static const bool enableSmartRecommendations = false;
}
