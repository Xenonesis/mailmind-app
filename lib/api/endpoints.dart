class ApiEndpoints {
  // Base URL - Update this with your actual backend URL
  static const String baseUrl = 'https://your-backend.vercel.app/api/v1';
  
  // Authentication endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleAuth = '/auth/google';
  static const String googleCallback = '/auth/google/callback';
  
  // User management endpoints
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  
  // Email management endpoints
  static const String emailSync = '/emails/sync';
  static const String emails = '/emails';
  static const String emailCategories = '/emails/categories';
  
  // Helper method to get email by ID
  static String emailById(String id) => '/emails/$id';
  
  // AI endpoints (if available)
  static const String aiSummarize = '/ai/summarize';
  static const String aiCategorize = '/ai/categorize';
  static const String aiPriority = '/ai/priority';
}