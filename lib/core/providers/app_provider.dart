import 'dart:developer' as developer;

import 'package:al_faw_zakho/core/network/api_client.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  ApiClient? _apiClient;
  bool _isAppInitialized = false;
  String? _initializationError;
  String _dataState = 'initial';

  bool get isAppInitialized => _isAppInitialized;
  String? get initializationError => _initializationError;
  String get dataState => _dataState;

  void setApiClient(ApiClient apiClient) {
    _apiClient = apiClient;
  }

  Future<void> generateMockData({
    bool forceRefresh = false,
    bool demoMode = false,
  }) async {
    try {
      developer.log('[AppProvider] Generating mock data...', name: 'DATA');
      _dataState = 'generating';
      notifyListeners();

      _dataState = 'mock_data_loaded';
      developer.log(
        '[AppProvider] Mock data generated successfully',
        name: 'DATA',
      );
      notifyListeners();
    } catch (e) {
      _dataState = 'error';
      developer.log(
        '[AppProvider] Error generating mock data: $e',
        name: 'ERROR',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> loadFreshData() async {
    try {
      developer.log(
        '[AppProvider] Loading fresh data from API...',
        name: 'DATA',
      );
      _dataState = 'loading';
      notifyListeners();

      // ✅ محاكاة تحميل البيانات من API
      await Future<void>.delayed(const Duration(milliseconds: 300));

      // هنا سيتم استدعاء API Client عندما يكون جاهزاً
      if (_apiClient != null) {
        // await _apiClient!.get('/candidates');
        developer.log(
          '[AppProvider] API data loaded successfully',
          name: 'DATA',
        );
      }

      _dataState = 'fresh_data_loaded';
      notifyListeners();
    } catch (e) {
      _dataState = 'error';
      developer.log(
        '[AppProvider] Error loading fresh data: $e',
        name: 'ERROR',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> initializeApp({
    required Future<void> Function() initializeConnectivity,
    required Future<void> Function() initializeTheme,
    required Future<void> Function() initializeLanguage,
  }) async {
    try {
      developer.log(
        '[AppProvider] Starting app initialization...',
        name: 'INIT',
      );

      await initializeConnectivity();
      await initializeTheme();
      await initializeLanguage();

      if (_apiClient != null) {
        developer.log('[AppProvider] API Client is available', name: 'API');
      }

      _isAppInitialized = true;
      _dataState = 'app_initialized';
      notifyListeners();

      developer.log(
        '[AppProvider] App initialization completed ✅',
        name: 'INIT',
      );
    } catch (e) {
      _initializationError = e.toString();
      _dataState = 'initialization_error';
      notifyListeners();
      developer.log(
        '[AppProvider] Initialization error: $e',
        name: 'ERROR',
        error: e,
      );
      rethrow;
    }
  }

  void resetInitialization() {
    _isAppInitialized = false;
    _initializationError = null;
    _dataState = 'initial';
    notifyListeners();
  }
}
