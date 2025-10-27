// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'endpoints.dart'; // ← تأكد أن هذا الملف موجود
import 'network_exceptions.dart'; // ← وتأكد أن هذا الملف موجود
import 'dart:developer' as developer;

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: Endpoints.baseUrl, // ← الآن سيعرف Endpoints
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('🚀 API Request: ${options.method} ${options.path}',
            name: 'NETWORK');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('✅ API Response: ${response.statusCode}',
            name: 'NETWORK');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        developer.log('❌ API Error: ${e.type} - ${e.message}',
            name: 'NETWORK', error: e);
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(
          e); // ← الآن سيعرف NetworkExceptions
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(
          e); // ← الآن سيعرف NetworkExceptions
    }
  }
}
