// lib/core/network/network_exceptions.dart
import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  final String message;

  NetworkExceptions(this.message);

  factory NetworkExceptions.getDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkExceptions('Connection timeout');
      case DioExceptionType.sendTimeout:
        return NetworkExceptions('Send timeout');
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions('Receive timeout');
      case DioExceptionType.badCertificate:
        return NetworkExceptions('Bad certificate');
      case DioExceptionType.badResponse:
        return NetworkExceptions('Bad response: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return NetworkExceptions('Request cancelled');
      case DioExceptionType.connectionError:
        return NetworkExceptions('Connection error');
      case DioExceptionType.unknown:
        return NetworkExceptions('Unknown error: ${error.message}');
    }
  }

  @override
  String toString() => message;
}
