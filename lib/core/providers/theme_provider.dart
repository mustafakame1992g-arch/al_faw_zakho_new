import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:al_faw_zakho/core/services/analytics_service.dart';
import 'package:al_faw_zakho/core/services/performance_tracker.dart';
import 'package:al_faw_zakho/core/constants/app_constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = AppConstants.defaultTheme;
  bool _isInitialized = false;
  int _retryCount = 0;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    final stopwatch = Stopwatch()..start();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(AppConstants.themePreferenceKey);

      _themeMode = _parseThemeMode(savedTheme);
      _isInitialized = true;
      _retryCount = 0;

      AnalyticsService.trackInitialization('ThemeProvider', success: true);
      debugPrint('✅ ThemeProvider initialized with theme: $_themeMode');
    } catch (e, stackTrace) {
      _handleInitializationError(e, stackTrace);
    } finally {
      stopwatch.stop();
      PerformanceTracker.track('ThemeProvider_Init', stopwatch.elapsed);
      notifyListeners();
    }
  }

  ThemeMode _parseThemeMode(String? themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return AppConstants.defaultTheme;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    return mode.toString().split('.').last;
  }

  Future<void> setTheme(ThemeMode newTheme) async {
    final previousTheme = _themeMode;
    _themeMode = newTheme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.themePreferenceKey, _themeModeToString(newTheme));

      AnalyticsService.trackEvent(
        'theme_changed',
        parameters: {
          'from': _themeModeToString(previousTheme),
          'to': _themeModeToString(newTheme),
        },
        category: 'ui',
      );

      debugPrint(
          '🎨 Theme changed: ${_themeModeToString(previousTheme)} → ${_themeModeToString(newTheme)}');
    } catch (e, stackTrace) {
      // Fallback: التراجع عن التغيير
      _themeMode = previousTheme;
      AnalyticsService.trackError('ThemeChange', e, stackTrace);
      debugPrint(
          '⚠️ Failed to save theme preference, reverted to previous theme');
    }

    notifyListeners();
  }

  void toggleTheme() {
    final newTheme =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(newTheme);
  }

  void _handleInitializationError(dynamic error, StackTrace stackTrace) {
    _retryCount++;

    if (_retryCount <= AppConstants.maxRetryAttempts) {
      final retryDelay = AppConstants.retryDelay * _retryCount;
      debugPrint(
          '🔄 Retrying ThemeProvider initialization in ${retryDelay.inSeconds}s');
      Future.delayed(retryDelay, init);
    } else {
      _themeMode = AppConstants.defaultTheme;
      _isInitialized = true;

      AnalyticsService.trackInitialization(
        'ThemeProvider',
        success: false,
        error: 'Fallback to default theme after $_retryCount attempts',
      );

      debugPrint('🛡️ ThemeProvider fallback activated - using default theme');
    }

    AnalyticsService.trackError('ThemeProvider_Init', error, stackTrace);
  }
}
