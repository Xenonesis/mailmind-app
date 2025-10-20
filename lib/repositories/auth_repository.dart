import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../api/dio_client.dart';
import '../api/endpoints.dart';
import '../models/auth_response.dart';

class AuthRepository {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Register new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _storeAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _storeAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Google OAuth login
  Future<String> getGoogleAuthUrl() async {
    try {
      final response = await DioClient.get(ApiEndpoints.googleAuth);
      return response.data['authUrl'] ?? '';
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Handle Google OAuth callback
  Future<AuthResponse> handleGoogleCallback(String code) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.googleCallback,
        data: {'code': code},
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _storeAuthData(authResponse);
      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await DioClient.get(ApiEndpoints.userProfile);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = 
            Map<String, dynamic>.from(jsonDecode(userData));
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await DioClient.clearTokens();
      await _storage.deleteAll();
    } catch (e) {
      // Even if API call fails, clear local storage
      await _storage.deleteAll();
    }
  }

  // Store authentication data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await _storage.write(key: 'jwt_token', value: authResponse.token);
    if (authResponse.refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: authResponse.refreshToken!);
    }
    
    // Store user data as JSON string
    final userJson = jsonEncode(authResponse.user.toJson());
    await _storage.write(key: 'user_data', value: userJson);
  }

  // Handle authentication errors
  AuthException _handleAuthError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return AuthException('Invalid input data. Please check your information.');
        case 401:
          return AuthException('Invalid credentials. Please try again.');
        case 409:
          return AuthException('User already exists with this email.');
        case 404:
          return AuthException('User not found.');
        case 500:
          return AuthException('Server error. Please try again later.');
        default:
          return AuthException(error.message);
      }
    }
    return AuthException('An unexpected error occurred. Please try again.');
  }

  // Refresh token if needed
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return null;

      final response = await DioClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['token'];
      await _storage.write(key: 'jwt_token', value: newToken);
      return newToken;
    } catch (e) {
      return null;
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}