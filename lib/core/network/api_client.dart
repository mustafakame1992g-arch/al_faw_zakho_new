// lib/core/network/api_client.dart
import 'dart:developer' as developer;

import 'package:al_faw_zakho/core/network/endpoints.dart';
import 'package:al_faw_zakho/core/network/network_exceptions.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _setupInterceptors();
  }
  late Dio _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '🚀 API Request: ${options.method} ${options.path}',
            name: 'NETWORK',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '✅ API Response: ${response.statusCode}',
            name: 'NETWORK',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          developer.log(
            '❌ API Error: ${e.type} - ${e.message}',
            name: 'NETWORK',
            error: e,
          );
          return handler.next(e);
        },
      ),
    );
  }

  // دوال مساعدة محددة الأنواع
  Future<Response<Map<String, dynamic>>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<Response<List<dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<Response<Map<String, dynamic>>> postJson(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  // للحفاظ على التوافق مع الكود الحالي (اختياري)
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return response;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    }
  }
}
