// lib/data/repositories/faq_repository.dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// 🧩 واجهة المستودع العام للأسئلة الشائعة (Repository Interface)
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

/// 🧠 تطبيق المستودع الفعلي — يدعم JSON المحلي + كاش Hive
class FAQRepositoryImpl implements FAQRepository {
  static const String _faqBoxName = 'faqs_cache';
  static const String _faqListKey = 'cached_faqs_list';
  static const Duration _cacheDuration = Duration(hours: 24);
  static const int _maxRetryAttempts = 2;

// ✅ الصندوق المفتوح مسبقاً
  late final Box _faqBox;
  bool _isInitialized = false;

// ✅ تهيئة الصندوق مرة واحدة
  Future<void> initialize() async {
    if (!_isInitialized) {
      _faqBox = await Hive.openBox(_faqBoxName);
      _isInitialized = true;
      developer.log('✅ FAQ Repository initialized', name: 'FAQ_REPOSITORY');
    }
  }

  // ✅ التحقق من التهيئة قبل الاستخدام
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // ===========================================================
  // 🚀 دالة الجلب العامة — تستخدم أذكى تسلسل ممكن
  // ===========================================================
  @override
  Future<List<FaqModel>> getFAQs() async {
    developer.log('🔄 Loading FAQs from repository...', name: 'FAQ_REPOSITORY');

    try {
      // 🧹 تنظيف الكاش المنتهي أولاً
      await clearExpiredCache();

      // 1️⃣ محاولة من JSON المحلي (assets)
      final localFAQs = await _loadFromAssets();
      if (localFAQs.isNotEmpty) {
        developer.log(
          '✅ Loaded ${localFAQs.length} FAQs from assets',
          name: 'FAQ_REPOSITORY',
        );
        await cacheFAQs(localFAQs);
        return localFAQs;
      }

      // 2️⃣ محاولة من الكاش المحلي (Hive)
      developer.log(
        '⚠️ No local FAQs found, trying cache...',
        name: 'FAQ_REPOSITORY',
      );
      final cachedFAQs = await getCachedFAQs();
      if (cachedFAQs.isNotEmpty) {
        developer.log(
          '✅ Loaded ${cachedFAQs.length} FAQs from cache',
          name: 'FAQ_REPOSITORY',
        );
        return cachedFAQs;
      }

      // 3️⃣ لا توجد بيانات
      throw Exception('لا توجد بيانات متاحة');
    } catch (e) {
      developer.log('❌ Failed to load FAQs: $e', name: 'FAQ_REPOSITORY');
      throw Exception('فشل في تحميل الأسئلة الشائعة: ${e.toString()}');
    }
  }

  // ===========================================================
  // 📦 جلب من ملف JSON محلي مع إعادة المحاولة الذكية
  // ===========================================================
  Future<List<FaqModel>> _loadFromAssets() async {
    for (int attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        developer.log(
          '📁 Loading FAQs from assets (attempt $attempt)...',
          name: 'FAQ_REPOSITORY',
        );

        final String response =
            await rootBundle.loadString('assets/data/faqs.json');
        final List<dynamic> data = json.decode(response);

        /*if (data.isEmpty) {
          developer.log('⚠️ FAQs JSON file is empty', name: 'FAQ_REPOSITORY');
          return [];
        }*/

        // ✅ تحقق أكثر شمولاً
        if (data.isEmpty) {
          developer.log(
            '❌ Invalid or empty FAQs data structure',
            name: 'FAQ_REPOSITORY',
          );
          throw Exception('هيكل بيانات الأسئلة غير صالح');
        }

        final faqs = data
            .map((json) {
              try {
                return FaqModel.fromJson(Map<String, dynamic>.from(json));
              } catch (e) {
                developer.log(
                  '⚠️ Failed to parse FAQ item: $e',
                  name: 'FAQ_REPOSITORY',
                );
                return null;
              }
            })
            .where((faq) => faq != null)
            .cast<FaqModel>()
            .toList();

        developer.log(
          '✅ Parsed ${faqs.length}/${data.length} FAQ items successfully',
          name: 'FAQ_REPOSITORY',
        );
        return faqs;
      } catch (e) {
        developer.log('❌ Attempt $attempt failed: $e', name: 'FAQ_REPOSITORY');
        if (attempt == _maxRetryAttempts) rethrow;
        await Future.delayed(Duration(milliseconds: 200 * attempt));
      }
    }
    return [];
  }

  // ===========================================================
  // 💾 التخزين المؤقت (Caching)
  // ===========================================================
  @override
  Future<void> cacheFAQs(List<FaqModel> faqs) async {
    if (faqs.isEmpty) return;

    try {
      developer.log(
        '💾 Caching ${faqs.length} FAQs...',
        name: 'FAQ_REPOSITORY',
      );

      final box = await Hive.openBox(_faqBoxName);
      final cacheData = {
        'data': faqs.map((f) => f.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.${DateTime.now().year}',
        'item_count': faqs.length,
      };

      await box.put(_faqListKey, cacheData);
      await box.close();

      developer.log('✅ FAQs cached successfully', name: 'FAQ_REPOSITORY');
    } catch (e) {
      developer.log('⚠️ Cache failed: $e', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 🔍 جلب البيانات من الكاش Hive
  // ===========================================================

  @override
  Future<List<FaqModel>> getCachedFAQs() async {
    await _ensureInitialized(); // ✅ التأكد من التهيئة

    try {
      developer.log('🔍 Retrieving cached FAQs...', name: 'FAQ_REPOSITORY');

      // ✅ استخدام مباشر للصندوق المفتوح
      final cachedData = _faqBox.get(_faqListKey);

      if (cachedData == null) {
        developer.log('ℹ️ No cached data found', name: 'FAQ_REPOSITORY');
        return [];
      }

      final timestamp = DateTime.parse(cachedData['timestamp']);
      final age = DateTime.now().difference(timestamp);

      if (age > _cacheDuration) {
        developer.log(
          '🕒 Cache expired (${age.inHours}h old)',
          name: 'FAQ_REPOSITORY',
        );
        await _faqBox.delete(_faqListKey);
        return [];
      }

      final List<dynamic> data = cachedData['data'];
      final faqs = data
          .map((json) {
            try {
              return FaqModel.fromJson(Map<String, dynamic>.from(json));
            } catch (e) {
              developer.log(
                '⚠️ Failed to parse cached FAQ: $e',
                name: 'FAQ_REPOSITORY',
              );
              return null;
            }
          })
          .where((faq) => faq != null)
          .cast<FaqModel>()
          .toList();

      developer.log(
        '✅ Retrieved ${faqs.length} FAQs from cache',
        name: 'FAQ_REPOSITORY',
      );
      return faqs;
    } catch (e) {
      developer.log('❌ Cache retrieval failed: $e', name: 'FAQ_REPOSITORY');
      return []; // ✅ إرجاع قائمة فارغة في حالة الخطأ
    }
  }

  // ✅ تنظيف الموارد عند الانتهاء
  Future<void> dispose() async {
    if (_isInitialized && _faqBox.isOpen) {
      await _faqBox.close();
      _isInitialized = false;
      developer.log('🔒 FAQ Repository disposed', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 👀 تحديث عداد المشاهدات محليًا داخل الكاش
  // ===========================================================
  @override
  Future<void> incrementViewCount(String faqId) async {
    try {
      developer.log(
        '👁️ Incrementing view count for FAQ: $faqId',
        name: 'FAQ_REPOSITORY',
      );

      final box = await Hive.openBox(_faqBoxName);
      final cachedData = box.get(_faqListKey);

      if (cachedData != null) {
        final List<dynamic> data = cachedData['data'];
        bool updated = false;

        final updatedData = data.map((item) {
          final map = Map<String, dynamic>.from(item);
          if (map['id'] == faqId) {
            final currentCount = (map['view_count'] ?? 0) as int;
            map['view_count'] = currentCount + 1;
            updated = true;
            developer.log(
              '✅ View count incremented to ${currentCount + 1}',
              name: 'FAQ_REPOSITORY',
            );
          }
          return map;
        }).toList();

        if (updated) {
          await box.put(_faqListKey, {...cachedData, 'data': updatedData});
        }
      }

      await box.close();
    } catch (e) {
      developer.log(
        '⚠️ Failed to increment view count: $e',
        name: 'FAQ_REPOSITORY',
      );
    }
  }

  // ===========================================================
  // 🏷️ تصفية حسب الفئة
  // ===========================================================
  @override
  Future<List<FaqModel>> getFAQsByCategory(String category) async {
    try {
      developer.log(
        '🏷️ Filtering FAQs by category: $category',
        name: 'FAQ_REPOSITORY',
      );

      final allFAQs = await getFAQs();
      final filtered = allFAQs.where((f) => f.category == category).toList();

      developer.log(
        '✅ Found ${filtered.length} FAQs in category "$category"',
        name: 'FAQ_REPOSITORY',
      );
      return filtered;
    } catch (e) {
      developer.log('❌ Category filter failed: $e', name: 'FAQ_REPOSITORY');
      rethrow;
    }
  }

  // ===========================================================
  // 🔍 البحث الذكي في جميع الحقول
  // ===========================================================
  @override
  Future<List<FaqModel>> searchFAQs(String query) async {
    try {
      if (query.trim().isEmpty) return await getFAQs();

      developer.log('🔎 Searching FAQs for: "$query"', name: 'FAQ_REPOSITORY');

      final allFAQs = await getFAQs();
      final q = query.toLowerCase();

      final results = allFAQs
          .where(
            (f) =>
                f.questionAr.toLowerCase().contains(q) ||
                f.questionEn.toLowerCase().contains(q) ||
                f.answerAr.toLowerCase().contains(q) ||
                f.answerEn.toLowerCase().contains(q) ||
                f.tags.any((tag) => tag.toLowerCase().contains(q)),
          )
          .toList();

      developer.log(
        '✅ Search found ${results.length} results',
        name: 'FAQ_REPOSITORY',
      );
      return results;
    } catch (e) {
      developer.log('❌ Search failed: $e', name: 'FAQ_REPOSITORY');
      rethrow;
    }
  }

  // ===========================================================
  // 📂 جلب قائمة الفئات المتاحة
  // ===========================================================
  @override
  Future<List<String>> getAvailableCategories() async {
    try {
      final allFAQs = await getFAQs();
      final categories = allFAQs
          .map((f) => f.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      return categories;
    } catch (e) {
      developer.log('❌ Failed to get categories: $e', name: 'FAQ_REPOSITORY');
      return [];
    }
  }

  // ===========================================================
  // 🧹 تنظيف الكاش المنتهي
  // ===========================================================
  @override
  Future<void> clearExpiredCache() async {
    try {
      final box = await Hive.openBox(_faqBoxName);
      final cachedData = box.get(_faqListKey);

      if (cachedData != null) {
        final timestamp = DateTime.parse(cachedData['timestamp']);
        if (DateTime.now().difference(timestamp) > _cacheDuration) {
          await box.delete(_faqListKey);
          developer.log('🧹 Expired cache cleared', name: 'FAQ_REPOSITORY');
        } else {
          developer.log('ℹ️ Cache is still valid', name: 'FAQ_REPOSITORY');
        }
      } else {
        developer.log('ℹ️ No cache found to clean', name: 'FAQ_REPOSITORY');
      }

      await box.close();
    } catch (e) {
      developer.log('⚠️ Cache cleanup failed: $e', name: 'FAQ_REPOSITORY');
    }
  }

  // ===========================================================
  // 📊 إحصاءات الكاش (Debug/Analytics)
  // ===========================================================
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final box = await Hive.openBox(_faqBoxName);
      final cachedData = box.get(_faqListKey);

      if (cachedData == null) {
        await box.close();
        return {'status': 'empty', 'item_count': 0};
      }

      final timestamp = DateTime.parse(cachedData['timestamp']);
      final age = DateTime.now().difference(timestamp);
      final data = cachedData['data'] as List;

      await box.close();
      return {
        'status': age > _cacheDuration ? 'expired' : 'valid',
        'item_count': data.length,
        'age_hours': age.inHours,
        'created_at': timestamp.toIso8601String(),
      };
    } catch (e) {
      return {'status': 'error', 'error': e.toString()};
    }
  }
}
