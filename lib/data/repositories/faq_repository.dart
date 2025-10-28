// lib/data/repositories/faq_repository.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// 🧩 واجهة المستودع
abstract class FAQRepository {
  Future<List<FaqModel>> getFAQs();
  Future<void> cacheFAQs(List<FaqModel> faqs);
  Future<List<FaqModel>> getCachedFAQs();
  Future<void> incrementViewCount(String faqId);
  Future<List<FaqModel>> getFAQsByCategory(String category);
  Future<List<FaqModel>> searchFAQs(String query);
  Future<List<String>> getAvailableCategories();
  Future<void> clearExpiredCache();
  Future<Map<String, dynamic>> getCacheStats();
}

/// 🧠 التطبيق الفعلي
class FAQRepositoryImpl implements FAQRepository {
  static const String _faqBoxName = 'faqs_cache';
  static const String _faqListKey = 'cached_faqs_list';
  static const Duration _cacheDuration = Duration(hours: 24);
  static const int _maxRetryAttempts = 2;

  late Box<Map<String, dynamic>> _faqBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _faqBox = await Hive.openBox<Map<String, dynamic>>(_faqBoxName);
    _isInitialized = true;
    developer.log('✅ FAQ Repository initialized', name: 'FAQ_REPOSITORY');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ===========================================================
  // 🚀 الجلب العام
  // ===========================================================
  @override
  Future<List<FaqModel>> getFAQs() async {
    developer.log('🔄 Loading FAQs from repository...', name: 'FAQ_REPOSITORY');
    try {
      await clearExpiredCache();

      // 1) من الأصول
      final List<FaqModel> localFAQs = await _loadFromAssets();
      if (localFAQs.isNotEmpty) {
        developer.log('✅ Loaded ${localFAQs.length} FAQs from assets',
            name: 'FAQ_REPOSITORY',);
        await cacheFAQs(localFAQs);
        return localFAQs;
      }

      // 2) من الكاش
      developer.log('⚠️ No local FAQs found, trying cache...',
          name: 'FAQ_REPOSITORY',);
      final List<FaqModel> cachedFAQs = await getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        developer.log('✅ Loaded ${cachedFAQs.length} FAQs from cache',
            name: 'FAQ_REPOSITORY',);
        return cachedFAQs;
      }

      throw Exception('لا توجد بيانات متاحة');
    } catch (e) {
      developer.log('❌ Failed to load FAQs: $e', name: 'FAQ_REPOSITORY');
      throw Exception('فشل في تحميل الأسئلة الشائعة: ${e.toString()}');
    }
  }

  // ===========================================================
  // 📦 من JSON محلي
  // ===========================================================
  Future<List<FaqModel>> _loadFromAssets() async {
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        developer.log('📁 Loading FAQs from assets (attempt $attempt)...',
            name: 'FAQ_REPOSITORY',);

        final String response =
            await rootBundle.loadString('assets/data/faqs.json');
        final List<dynamic> data = json.decode(response) as List<dynamic>;

        if (data.isEmpty) {
          throw Exception('هيكل بيانات الأسئلة غير صالح');
        }

        final List<FaqModel> faqs = data
            .whereType<Map>() // فقط العناصر التي هي Map
            .map((Map<dynamic, dynamic> m) =>
                FaqModel.fromJson(m.cast<String, dynamic>()),)
            .toList(growable: false);

        developer.log(
            '✅ Parsed ${faqs.length}/${data.length} FAQ items successfully',
            name: 'FAQ_REPOSITORY',);
        return faqs;
      } catch (e) {
        developer.log('❌ Attempt $attempt failed: $e',
            name: 'FAQ_REPOSITORY',);
        if (attempt == _maxRetryAttempts) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
    return <FaqModel>[];
  }

  // ===========================================================
  // 💾 التخزين المؤقت
  // ===========================================================
  @override
  Future<void> cacheFAQs(List<FaqModel> faqs) async {
    if (faqs.isEmpty) return;
    await _ensureInitialized();

    try {
      developer.log('💾 Caching ${faqs.length} FAQs...',
          name: 'FAQ_REPOSITORY',);

      final Map<String, dynamic> cacheData = <String, dynamic>{
        'data': faqs.map((f) => f.toJson()).toList(growable: false),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.${DateTime.now().year}',
        'item_count': faqs.length,
      };

      await _faqBox.put(_faqListKey, cacheData);
      developer.log('✅ FAQs cached successfully', name: 'FAQ_REPOSITORY');
    } catch (e) {
      developer.log('⚠️ Cache failed: $e', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 🔍 من الكاش
  // ===========================================================
  @override
  Future<List<FaqModel>> getCachedFAQs() async {
    await _ensureInitialized();
    try {
      developer.log('🔍 Retrieving cached FAQs...', name: 'FAQ_REPOSITORY');

      final Map<String, dynamic>? cachedData = _faqBox.get(_faqListKey);
      if (cachedData == null) {
        developer.log('ℹ️ No cached data found', name: 'FAQ_REPOSITORY');
        return <FaqModel>[];
      }

      final String tsStr = (cachedData['timestamp'] as String?) ?? '';
      final DateTime timestamp =
          DateTime.tryParse(tsStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final Duration age = DateTime.now().difference(timestamp);

      if (age > _cacheDuration) {
        developer.log('🕒 Cache expired (${age.inHours}h old)',
            name: 'FAQ_REPOSITORY',);
        await _faqBox.delete(_faqListKey);
        return <FaqModel>[];
      }

      final List<Map<String, dynamic>> data =
          ((cachedData['data'] as List?) ?? const <dynamic>[])
              .whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList(growable: false);

      final List<FaqModel> faqs =
          data.map((m) => FaqModel.fromJson(m)).toList(growable: false);

      developer.log('✅ Retrieved ${faqs.length} FAQs from cache',
          name: 'FAQ_REPOSITORY',);
      return faqs;
    } catch (e) {
      developer.log('❌ Cache retrieval failed: $e', name: 'FAQ_REPOSITORY');
      return <FaqModel>[];
    }
  }

  Future<void> dispose() async {
    if (_isInitialized && _faqBox.isOpen) {
      await _faqBox.close();
      _isInitialized = false;
      developer.log('🔒 FAQ Repository disposed', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 👀 زيادة العداد
  // ===========================================================
  @override
  Future<void> incrementViewCount(String faqId) async {
    await _ensureInitialized();
    try {
      developer.log('👁️ Incrementing view count for FAQ: $faqId',
          name: 'FAQ_REPOSITORY',);

      final Map<String, dynamic>? cachedData = _faqBox.get(_faqListKey);
      if (cachedData == null) return;

      final List<Map<String, dynamic>> data =
          ((cachedData['data'] as List?) ?? const <dynamic>[])
              .whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList(growable: false);

      bool updated = false;
      final List<Map<String, dynamic>> updatedData =
          data.map((Map<String, dynamic> map) {
        if (map['id'] == faqId) {
          final int current = (map['view_count'] as int?) ?? 0;
          map = Map<String, dynamic>.from(map)..['view_count'] = current + 1;
          updated = true;
          developer.log('✅ View count incremented to ${current + 1}',
              name: 'FAQ_REPOSITORY',);
        }
        return map;
      }).toList(growable: false);

      if (updated) {
        final Map<String, dynamic> payload =
            Map<String, dynamic>.from(cachedData)..['data'] = updatedData;
        await _faqBox.put(_faqListKey, payload);
      }
    } catch (e) {
      developer.log('⚠️ Failed to increment view count: $e',
          name: 'FAQ_REPOSITORY',);
    }
  }

  // ===========================================================
  // 🏷️ حسب الفئة
  // ===========================================================
  @override
  Future<List<FaqModel>> getFAQsByCategory(String category) async {
    try {
      developer.log('🏷️ Filtering FAQs by category: $category',
          name: 'FAQ_REPOSITORY',);

      final List<FaqModel> allFAQs = await getFAQs();
      final List<FaqModel> filtered =
          allFAQs.where((f) => f.category == category).toList(growable: false);

      developer.log(
          '✅ Found ${filtered.length} FAQs in category "$category"',
          name: 'FAQ_REPOSITORY',);
      return filtered;
    } catch (e) {
      developer.log('❌ Category filter failed: $e', name: 'FAQ_REPOSITORY');
      rethrow;
    }
  }

  // ===========================================================
  // 🔎 البحث
  // ===========================================================
  @override
  Future<List<FaqModel>> searchFAQs(String query) async {
    try {
      if (query.trim().isEmpty) return await getFAQs();

      developer.log('🔎 Searching FAQs for: "$query"',
          name: 'FAQ_REPOSITORY',);

      final List<FaqModel> allFAQs = await getFAQs();
      final String q = query.toLowerCase();

      final List<FaqModel> results = allFAQs
          .where((f) =>
              f.questionAr.toLowerCase().contains(q) ||
              f.questionEn.toLowerCase().contains(q) ||
              f.answerAr.toLowerCase().contains(q) ||
              f.answerEn.toLowerCase().contains(q) ||
              f.tags.any((tag) => tag.toLowerCase().contains(q)),)
          .toList(growable: false);

      developer.log('✅ Search found ${results.length} results',
          name: 'FAQ_REPOSITORY',);
      return results;
    } catch (e) {
      developer.log('❌ Search failed: $e', name: 'FAQ_REPOSITORY');
      rethrow;
    }
  }

  // ===========================================================
  // 📂 الفئات المتاحة
  // ===========================================================
  @override
  Future<List<String>> getAvailableCategories() async {
    try {
      final List<FaqModel> allFAQs = await getFAQs();
      final List<String> categories = allFAQs
          .map((f) => f.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return categories;
    } catch (e) {
      developer.log('❌ Failed to get categories: $e',
          name: 'FAQ_REPOSITORY',);
      return <String>[];
    }
  }

  // ===========================================================
  // 🧹 تنظيف الكاش المنتهي
  // ===========================================================
  @override
  Future<void> clearExpiredCache() async {
    await _ensureInitialized();
    try {
      final Map<String, dynamic>? cachedData = _faqBox.get(_faqListKey);
      if (cachedData == null) {
        developer.log('ℹ️ No cache found to clean', name: 'FAQ_REPOSITORY');
        return;
      }

      final String tsStr = (cachedData['timestamp'] as String?) ?? '';
      final DateTime timestamp =
          DateTime.tryParse(tsStr) ?? DateTime.fromMillisecondsSinceEpoch(0);

      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await _faqBox.delete(_faqListKey);
        developer.log('🧹 Expired cache cleared', name: 'FAQ_REPOSITORY');
      } else {
        developer.log('ℹ️ Cache is still valid', name: 'FAQ_REPOSITORY');
      }
    } catch (e) {
      developer.log('⚠️ Cache cleanup failed: $e', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 📊 إحصاءات الكاش
  // ===========================================================
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    await _ensureInitialized();
    try {
      final Map<String, dynamic>? cachedData = _faqBox.get(_faqListKey);
      if (cachedData == null) {
        return <String, dynamic>{'status': 'empty', 'item_count': 0};
      }

      final String tsStr = (cachedData['timestamp'] as String?) ?? '';
      final DateTime timestamp =
          DateTime.tryParse(tsStr) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final Duration age = DateTime.now().difference(timestamp);
      final int itemCount =
          ((cachedData['data'] as List?) ?? const <dynamic>[]).length;

      return <String, dynamic>{
        'status': age > _cacheDuration ? 'expired' : 'valid',
        'item_count': itemCount,
        'age_hours': age.inHours,
        'created_at': timestamp.toIso8601String(),
      };
    } catch (e) {
      return <String, dynamic>{'status': 'error', 'error': e.toString()};
    }
  }
}
