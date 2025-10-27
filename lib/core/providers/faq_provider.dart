// lib/core/providers/faq_provider.dart
import 'package:al_faw_zakho/core/localization/app_localizations.dart';
import 'package:al_faw_zakho/data/models/faq_model.dart';
import 'package:al_faw_zakho/data/repositories/faq_repository.dart';
import 'package:flutter/foundation.dart';

class FAQProvider with ChangeNotifier {
  FAQProvider(this._repository);
  final FAQRepository _repository;

  List<FaqModel> _faqs = [];
  List<FaqModel> _filteredFAQs = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  // Getters
  List<FaqModel> get faqs => _filteredFAQs;
  List<FaqModel> get allFAQs => _faqs;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _faqs.map((f) => f.category).nonNulls.toSet().toList();
    cats.sort();
    cats.insert(0, AppLocalizations.defaultLanguage == 'ar' ? 'الكل' : 'All');
    return cats;
  }

  // Actions
  Future<void> loadFAQs() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _faqs = await _repository.getFAQs();
      _applyFilters();
    } catch (e) {
      _error =
          '⚠️ فشل تحميل الأسئلة: ${e is Exception ? e.toString() : 'خطأ غير معروف'}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshFAQs() async {
    await loadFAQs();
  }

  void searchFAQs(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<FaqModel> filtered = _faqs;

    // 🔍 البحث
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((faq) {
        return faq.questionAr.toLowerCase().contains(q) ||
            faq.questionEn.toLowerCase().contains(q) ||
            faq.answerAr.toLowerCase().contains(q) ||
            faq.answerEn.toLowerCase().contains(q) ||
            faq.tags.any((tag) => tag.toLowerCase().contains(q));
      }).toList();
    }

    // 🏷️ التصنيف - بدون حذف "الكل"
    final allLabel = AppLocalizations.defaultLanguage == 'ar' ? 'الكل' : 'All';
    if (_selectedCategory != allLabel) {
      filtered = filtered.where((faq) {
        return faq.category == _selectedCategory ||
            faq.category == 'عام' ||
            faq.category.toLowerCase() == 'general';
      }).toList();
    }

    _filteredFAQs = filtered;
    notifyListeners();
  }

  Future<void> recordFAQView(String faqId) async {
    await _repository.incrementViewCount(faqId);
    // تحديث البيانات المحلية
    final index = _faqs.indexWhere((faq) => faq.id == faqId);
    if (index != -1) {
      _faqs[index] = _faqs[index].copyWith(
        viewCount: _faqs[index].viewCount + 1,
      );
      _applyFilters();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
