// lib/core/cache/prefs_manager.dart

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// 🎯 مدير مفضلات التطبيق - واجهة موحدة للـ SharedPreferences
class PrefsManager {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  static Completer<void>? _initCompleter;

  // ✅ مفاتيح التخزين الشائعة
  static const String keyLanguage = 'app_language';
  static const String keyThemeMode = 'app_theme_mode';
  static const String keyFirstLaunch = 'app_first_launch';
  static const String keyUserToken = 'user_auth_token';
  static const String keyLastSync = 'last_data_sync';

  /// 🚀 تهيئة PrefsManager
  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    _initCompleter ??= Completer<void>();
    if (!_initCompleter!.isCompleted) {
      try {
        _prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
        _initCompleter!.complete();
        
        developer.log('✅ PrefsManager initialized successfully', name: 'PREFS');
      } catch (e) {
        developer.log('❌ PrefsManager initialization failed: $e', 
            name: 'PREFS', level: 1000);
        _initCompleter!.completeError(e);
        rethrow;
      }
    }

    return _initCompleter!.future;
  }

  /// 🔒 التأكد من التهيئة قبل الاستخدام
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // 📥 دوال الحفظ
  static Future<bool> saveString(String key, String value) async {
    try {
      await _ensureInitialized();
      final result = await _prefs!.setString(key, value);
      developer.log('💾 Saved string to prefs: $key', name: 'PREFS', level: 600);
      return result;
    } catch (e) {
      developer.log('❌ Failed to save string: $key - $e', 
          name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Future<bool> saveInt(String key, int value) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setInt(key, value);
    } catch (e) {
      developer.log('❌ Failed to save int: $key - $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Future<bool> saveBool(String key, bool value) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      developer.log('❌ Failed to save bool: $key - $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Future<bool> saveDouble(String key, double value) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      developer.log('❌ Failed to save double: $key - $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Future<bool> saveStringList(String key, List<String> value) async {
    try {
      await _ensureInitialized();
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      developer.log('❌ Failed to save string list: $key - $e', 
          name: 'PREFS', level: 1000);
      return false;
    }
  }

  // 📤 دوال الاسترجاع
  static String? getString(String key) {
    try {
      if (!_isInitialized) return null;
      return _prefs!.getString(key);
    } catch (e) {
      developer.log('❌ Failed to get string: $key - $e', name: 'PREFS', level: 1000);
      return null;
    }
  }

  static int? getInt(String key) {
    try {
      if (!_isInitialized) return null;
      return _prefs!.getInt(key);
    } catch (e) {
      developer.log('❌ Failed to get int: $key - $e', name: 'PREFS', level: 1000);
      return null;
    }
  }

  static bool? getBool(String key) {
    try {
      if (!_isInitialized) return null;
      return _prefs!.getBool(key);
    } catch (e) {
      developer.log('❌ Failed to get bool: $key - $e', name: 'PREFS', level: 1000);
      return null;
    }
  }

  static bool getBoolWithDefault(String key, bool defaultValue) {
    return getBool(key) ?? defaultValue;
  }

  static double? getDouble(String key) {
    try {
      if (!_isInitialized) return null;
      return _prefs!.getDouble(key);
    } catch (e) {
      developer.log('❌ Failed to get double: $key - $e', name: 'PREFS', level: 1000);
      return null;
    }
  }

  static List<String>? getStringList(String key) {
    try {
      if (!_isInitialized) return null;
      return _prefs!.getStringList(key);
    } catch (e) {
      developer.log('❌ Failed to get string list: $key - $e', 
          name: 'PREFS', level: 1000);
      return null;
    }
  }

  // 🗑️ دوال الحذف
  static Future<bool> remove(String key) async {
    try {
      await _ensureInitialized();
      final result = await _prefs!.remove(key);
      developer.log('🧹 Removed key from prefs: $key', name: 'PREFS', level: 600);
      return result;
    } catch (e) {
      developer.log('❌ Failed to remove: $key - $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Future<bool> clearAll() async {
    try {
      await _ensureInitialized();
      final result = await _prefs!.clear();
      developer.log('🧹 Cleared all prefs data', name: 'PREFS', level: 600);
      return result;
    } catch (e) {
      developer.log('❌ Failed to clear prefs: $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  // 🔍 دوال التحقق
  static bool containsKey(String key) {
    try {
      if (!_isInitialized) return false;
      return _prefs!.containsKey(key);
    } catch (e) {
      developer.log('❌ Failed to check key: $key - $e', name: 'PREFS', level: 1000);
      return false;
    }
  }

  static Set<String> getKeys() {
    try {
      if (!_isInitialized) return {};
      return _prefs!.getKeys();
    } catch (e) {
      developer.log('❌ Failed to get keys: $e', name: 'PREFS', level: 1000);
      return {};
    }
  }

  // 🌐 دوال مساعدة للتطبيق
  static Future<bool> setAppLanguage(String languageCode) async {
    return await saveString(keyLanguage, languageCode);
  }

  static String? getAppLanguage() {
    return getString(keyLanguage);
  }

  static Future<bool> setThemeMode(String themeMode) async {
    return await saveString(keyThemeMode, themeMode);
  }

  static String? getThemeMode() {
    return getString(keyThemeMode);
  }

  static Future<bool> setFirstLaunch(bool isFirstLaunch) async {
    return await saveBool(keyFirstLaunch, isFirstLaunch);
  }

  static bool isFirstLaunch() {
    return getBoolWithDefault(keyFirstLaunch, true);
  }

  static Future<bool> setUserToken(String token) async {
    return await saveString(keyUserToken, token);
  }

  static String? getUserToken() {
    return getString(keyUserToken);
  }

  static Future<bool> setLastSync(DateTime timestamp) async {
    return await saveInt(keyLastSync, timestamp.millisecondsSinceEpoch);
  }

  static DateTime? getLastSync() {
    final timestamp = getInt(keyLastSync);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// 📊 الحصول على إحصائيات التخزين
  static Map<String, dynamic> getStorageStats() {
    try {
      if (!_isInitialized) return {'error': 'Not initialized'};

      final keys = _prefs!.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        final value = _prefs!.get(key);
        if (value is String) {
          totalSize += value.length * 2; // تقدير الحجم بالبايت
        }
      }

      return {
        'total_keys': keys.length,
        'estimated_size_bytes': totalSize,
        'estimated_size_kb': (totalSize / 1024).toStringAsFixed(2),
        'keys_list': keys.toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 🧹 تنظيف المفاتيح القديمة (اختياري)
  static Future<int> cleanOldKeys(List<String> validKeys) async {
    try {
      await _ensureInitialized();
      final allKeys = _prefs!.getKeys();
      final obsoleteKeys = allKeys.where((key) => !validKeys.contains(key)).toList();
      
      int removedCount = 0;
      for (final key in obsoleteKeys) {
        if (await remove(key)) {
          removedCount++;
        }
      }

      developer.log('🧹 Cleaned $removedCount obsolete keys', name: 'PREFS');
      return removedCount;
    } catch (e) {
      developer.log('❌ Failed to clean old keys: $e', name: 'PREFS', level: 1000);
      return 0;
    }
  }

  static bool get isInitialized => _isInitialized;
}