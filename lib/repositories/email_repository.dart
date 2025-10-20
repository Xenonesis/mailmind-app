import '../api/dio_client.dart';
import '../api/endpoints.dart';
import '../models/email_model.dart';

class EmailRepository {
  // Sync emails from external provider
  Future<Map<String, dynamic>> syncEmails() async {
    try {
      final response = await DioClient.get(ApiEndpoints.emailSync);
      return response.data;
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get all emails with optional category filter
  Future<List<Email>> getEmails({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      final response = await DioClient.get(
        ApiEndpoints.emails,
        queryParameters: queryParams,
      );

      final List<dynamic> emailsData = response.data['emails'] ?? response.data;
      return emailsData.map((emailJson) => Email.fromJson(emailJson)).toList();
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get specific email by ID
  Future<Email> getEmailById(String id) async {
    try {
      final response = await DioClient.get(ApiEndpoints.emailById(id));
      return Email.fromJson(response.data);
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get available email categories
  Future<List<String>> getEmailCategories() async {
    try {
      final response = await DioClient.get(ApiEndpoints.emailCategories);
      final List<dynamic> categoriesData = response.data['categories'] ?? response.data;
      return categoriesData.map((category) => category.toString()).toList();
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Mark email as read
  Future<void> markAsRead(String emailId) async {
    try {
      await DioClient.put(
        ApiEndpoints.emailById(emailId),
        data: {'isRead': true},
      );
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Mark email as important
  Future<void> markAsImportant(String emailId, bool isImportant) async {
    try {
      await DioClient.put(
        ApiEndpoints.emailById(emailId),
        data: {'isImportant': isImportant},
      );
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Delete email
  Future<void> deleteEmail(String emailId) async {
    try {
      await DioClient.delete(ApiEndpoints.emailById(emailId));
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get AI summary for email
  Future<String> getEmailSummary(String emailId) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.aiSummarize,
        data: {'emailId': emailId},
      );
      return response.data['summary'] ?? '';
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get AI categorization for email
  Future<String> getEmailCategory(String emailId) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.aiCategorize,
        data: {'emailId': emailId},
      );
      return response.data['category'] ?? 'inbox';
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get AI priority for email
  Future<String> getEmailPriority(String emailId) async {
    try {
      final response = await DioClient.post(
        ApiEndpoints.aiPriority,
        data: {'emailId': emailId},
      );
      return response.data['priority'] ?? 'low';
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Search emails
  Future<List<Email>> searchEmails(String query) async {
    try {
      final response = await DioClient.get(
        ApiEndpoints.emails,
        queryParameters: {'search': query},
      );

      final List<dynamic> emailsData = response.data['emails'] ?? response.data;
      return emailsData.map((emailJson) => Email.fromJson(emailJson)).toList();
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get emails by priority
  Future<List<Email>> getEmailsByPriority(String priority) async {
    try {
      final response = await DioClient.get(
        ApiEndpoints.emails,
        queryParameters: {'priority': priority},
      );

      final List<dynamic> emailsData = response.data['emails'] ?? response.data;
      return emailsData.map((emailJson) => Email.fromJson(emailJson)).toList();
    } catch (e) {
      throw _handleEmailError(e);
    }
  }

  // Get unread emails count
  Future<int> getUnreadCount() async {
    try {
      final response = await DioClient.get(
        '${ApiEndpoints.emails}/unread-count',
      );
      return response.data['count'] ?? 0;
    } catch (e) {
      return 0; // Return 0 if error occurs
    }
  }

  // Handle email-related errors
  EmailException _handleEmailError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return EmailException('Invalid request. Please check your input.');
        case 401:
          return EmailException('Authentication required. Please login again.');
        case 403:
          return EmailException('Access denied. You don\'t have permission to access this email.');
        case 404:
          return EmailException('Email not found.');
        case 500:
          return EmailException('Server error. Please try again later.');
        default:
          return EmailException(error.message);
      }
    }
    return EmailException('An unexpected error occurred while processing emails.');
  }
}

class EmailException implements Exception {
  final String message;

  EmailException(this.message);

  @override
  String toString() => 'EmailException: $message';
}