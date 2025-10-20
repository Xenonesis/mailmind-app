import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'endpoints.dart';

class DioClient {
  static Dio? _dio;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add request interceptor for authentication
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add JWT token to requests
          final token = await _storage.read(key: 'jwt_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add external access token for email sync operations
          if (options.path.contains('/emails/sync')) {
            final externalToken = await _storage.read(key: 'external_access_token');
            if (externalToken != null && externalToken.isNotEmpty) {
              options.headers['x-access-token'] = externalToken;
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) {
          // Only log in debug mode
          // print(object);
        },
      ),
    );

    return dio;
  }

  static Future<void> _handleUnauthorized() async {
    // Clear stored tokens
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'external_access_token');
    await _storage.delete(key: 'user_data');
    
    // Navigate to login screen
    // This should be handled by the app's navigation logic
  }

  // Helper methods for common HTTP operations
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await instance.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data?['message'] ?? 
                       error.response?.statusMessage ?? 
                       'An error occurred';
        return ApiException(
          message: message,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          statusCode: 0,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'Network error. Please check your internet connection.',
          statusCode: 0,
        );
    }
  }

  // Method to update base URL if needed
  static void updateBaseUrl(String newBaseUrl) {
    _dio?.options.baseUrl = newBaseUrl;
  }

  // Method to clear all stored tokens
  static Future<void> clearTokens() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'external_access_token');
    await _storage.delete(key: 'user_data');
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}