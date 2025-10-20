import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_faw_zakho/core/constants/app_constants.dart';

/// Manages the application's language and persists the setting locally.
/// Supported languages are Arabic and English.
class LanguageProvider with ChangeNotifier {
  // Constants to prevent typos
  static const String arabic = 'ar';
  static const String english = 'en';
  static const List<String> _supportedLanguages = [arabic, english];
static const String _prefsKey = AppConstants.languagePreferenceKey; // 'language_code'

  Locale _locale = const Locale(arabic);
  bool _isInitialized = false;
  SharedPreferences? _prefs; // Cache the SharedPreferences instance

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  String get languageCode => _locale.languageCode;

  TextDirection get textDirection =>
      _locale.languageCode == arabic ? TextDirection.rtl : TextDirection.ltr;

  /// Initializes the provider by loading the saved language preference.
  /// Should be called once during app startup.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = _prefs?.getString(_prefsKey);

      if (savedLanguageCode != null && _supportedLanguages.contains(savedLanguageCode)) {
        _locale = Locale(savedLanguageCode);
      }
      // If nothing is saved, the default ('ar') is already set.
    } catch (e) {
      debugPrint('Error loading language preference: $e');
      // Maintain the default locale in case of an error.
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Changes the application language and saves the choice.
  /// Does nothing if [languageCode] is not supported or already active.
  Future<void> setLanguage(String languageCode) async {
   /* if (!_supportedLanguages.contains(languageCode) || _locale.languageCode == languageCode) {
      return; // Exit early if invalid or same language.
    }*/
  if (!_supportedLanguages.contains(languageCode)) return;

    _locale = Locale(languageCode);
    notifyListeners(); // Update UI immediately

    // Persist the choice in the background.
    try {
      await _prefs?.setString(_prefsKey, languageCode);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
      // The in-memory state is already updated, so we don't revert the locale.
    }
  }

  /// Toggles between Arabic and English.
  void toggleLanguage() {
    final newLanguage = _locale.languageCode == arabic ? english : arabic;
    setLanguage(newLanguage);
  }

  /// Returns the display name for a given language code.
  String getLanguageName(String code) {
    final nameMap = { arabic: 'العربية', english: 'English' };
    return nameMap[code] ?? code;
  }
}