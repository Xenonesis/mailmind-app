import '../api/dio_client.dart';
import '../api/endpoints.dart';
import '../models/user_settings.dart';
import '../models/auth_response.dart';

class UserRepository {
  // Get user settings
  Future<UserSettings> getUserSettings() async {
    try {
      final response = await DioClient.get(ApiEndpoints.userSettings);
      return UserSettings.fromJson(response.data);
    } catch (e) {
      // Return default settings if API call fails
      return UserSettings();
    }
  }

  // Update user settings
  Future<UserSettings> updateUserSettings(UserSettings settings) async {
    try {
      final response = await DioClient.put(
        ApiEndpoints.userSettings,
        data: settings.toJson(),
      );
      return UserSettings.fromJson(response.data);
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Get user profile
  Future<User> getUserProfile() async {
    try {
      final response = await DioClient.get(ApiEndpoints.userProfile);
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update user profile
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (email != null) data['email'] = email;

      final response = await DioClient.put(
        ApiEndpoints.userProfile,
        data: data,
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await DioClient.put(
        '${ApiEndpoints.userProfile}/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await DioClient.delete(ApiEndpoints.userProfile);
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await DioClient.get('${ApiEndpoints.userProfile}/stats');
      return response.data;
    } catch (e) {
      return {
        'totalEmails': 0,
        'unreadEmails': 0,
        'importantEmails': 0,
        'categorizedEmails': 0,
      };
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences({
    required bool enableNotifications,
    required bool enableEmailAlerts,
    required bool enablePushNotifications,
  }) async {
    try {
      await DioClient.put(
        '${ApiEndpoints.userSettings}/notifications',
        data: {
          'enableNotifications': enableNotifications,
          'enableEmailAlerts': enableEmailAlerts,
          'enablePushNotifications': enablePushNotifications,
        },
      );
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await DioClient.get('${ApiEndpoints.userSettings}/notifications');
      return {
        'enableNotifications': response.data['enableNotifications'] ?? true,
        'enableEmailAlerts': response.data['enableEmailAlerts'] ?? true,
        'enablePushNotifications': response.data['enablePushNotifications'] ?? true,
      };
    } catch (e) {
      return {
        'enableNotifications': true,
        'enableEmailAlerts': true,
        'enablePushNotifications': true,
      };
    }
  }

  // Handle user-related errors
  UserException _handleUserError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return UserException('Invalid request. Please check your input.');
        case 401:
          return UserException('Authentication required. Please login again.');
        case 403:
          return UserException('Access denied. You don\'t have permission to perform this action.');
        case 404:
          return UserException('User not found.');
        case 409:
          return UserException('Conflict. The email address is already in use.');
        case 500:
          return UserException('Server error. Please try again later.');
        default:
          return UserException(error.message);
      }
    }
    return UserException('An unexpected error occurred while processing user data.');
  }
}

class UserException implements Exception {
  final String message;

  UserException(this.message);

  @override
  String toString() => 'UserException: $message';
}