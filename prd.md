Frontend PRD – MailMind (Flutter App)

Goal: Build a Flutter mobile app (Android-first) that connects to your NestJS backend and provides an elegant, AI-powered email management experience.

🧩 1. Overview

The Flutter app will allow users to:

Log in using real credentials (email/password or Google OAuth)

View all emails fetched from backend (organized by category)

Use AI summaries and priorities fetched from your backend

Switch dark/light mode

Manage settings and preferences

Backend → Your existing NestJS API
AI → OpenRouter (already integrated in backend)

🎨 2. UI/UX Design
Main Screens:

Splash Screen

App logo + tagline: “Smarter Inbox. Simpler Life.”

Auto-checks for stored token → Redirects to Home or Login.

Login Screen

Email + password fields

“Login with Google” button

Register link → opens Signup screen

Calls backend: /auth/login

Stores JWT securely using flutter_secure_storage

Signup Screen

Fields: Name, Email, Password, Confirm Password

Calls /auth/register

Home (Inbox) Screen

Top AppBar → Search bar + Profile icon

Bottom Navigation:

Inbox 📨

Categories 🗂️

Settings ⚙️

Tabs for categories: All, Work, Personal, Promotions

Each email card shows:

Sender, Subject, Short preview

AI Summary (fetched from backend /ai/summarize)

Priority Badge (Low, Medium, High)

Email Details Screen

Shows:

Full email body

AI Summary block at top

Category + Priority chips

Buttons: “Mark as Important” / “Delete”

Option to trigger re-summarization

Settings Screen

Toggle dark/light mode

Select AI model (if allowed from backend)

Sync frequency dropdown

Logout button (clears token + redirects to login)

⚙️ 3. Functional Flow
Action	API Endpoint	Description
Login	POST /auth/login	User login, returns JWT
Register	POST /auth/register	Creates new user
Fetch Emails	GET /emails	Fetches user emails
Fetch Summary	POST /ai/summarize	Returns AI-generated summary
Fetch Category	POST /ai/categorize	Returns category
Fetch Priority	POST /ai/priority	Returns importance level
Update Settings	PATCH /user/settings	Updates preferences
🧠 4. Tech Stack (Frontend)
Component	Tool
Framework	Flutter 3.22+
Language	Dart
State Management	Riverpod or Bloc
HTTP	Dio
Local Storage	Hive (email cache) + flutter_secure_storage (token)
Theme	Material 3 + DynamicColor
Notifications	Firebase Cloud Messaging
Authentication	google_sign_in + appauth
Deployment	Play Store
🗂️ 5. Project Folder Structure
lib/
 ┣ api/
 ┃ ┣ dio_client.dart          # Dio setup
 ┃ ┗ endpoints.dart           # API URLs
 ┣ models/
 ┃ ┣ user_model.dart
 ┃ ┗ email_model.dart
 ┣ providers/
 ┃ ┗ auth_provider.dart
 ┣ repositories/
 ┃ ┣ auth_repository.dart
 ┃ ┗ email_repository.dart
 ┣ screens/
 ┃ ┣ auth/
 ┃ ┃ ┣ login_screen.dart
 ┃ ┃ ┗ signup_screen.dart
 ┃ ┣ home/
 ┃ ┃ ┣ home_screen.dart
 ┃ ┃ ┗ email_details_screen.dart
 ┃ ┗ settings/settings_screen.dart
 ┣ widgets/
 ┃ ┣ email_card.dart
 ┃ ┗ summary_box.dart
 ┣ theme/
 ┃ ┣ app_theme.dart
 ┗ main.dart

🧩 6. Sample API Integration
dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'https://your-backend.vercel.app/api/v1'));

  static Future<Dio> getClient() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    _dio.options.headers['Authorization'] = 'Bearer $token';
    return _dio;
  }
}

Fetch Emails Example
Future<List<Email>> fetchEmails() async {
  final dio = await DioClient.getClient();
  final res = await dio.get('/emails');
  return (res.data as List).map((e) => Email.fromJson(e)).toList();
}

🎨 7. UI Example – Email Card
class EmailCard extends StatelessWidget {
  final Email email;

  const EmailCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(email.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email.sender),
            const SizedBox(height: 4),
            Text(email.summary ?? 'Fetching AI summary...'),
          ],
        ),
        trailing: Chip(
          label: Text(email.priority ?? 'Low'),
          backgroundColor: _getPriorityColor(email.priority),
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      default:
        return Colors.greenAccent;
    }
  }
}

🌗 8. Theming
final lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.deepPurple,
    secondary: Colors.amber,
  ),
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurpleAccent,
    secondary: Colors.amberAccent,
  ),
);

🔐 9. Local Storage

Token → flutter_secure_storage

Cached emails → Hive

Theme preference → SharedPreferences

☁️ 10. Deployment Plan
Stage	Action
Development	Test with local NestJS API via ngrok
Build	flutter build apk --release
Hosting	Upload to Play Store
Notification Setup	Link Firebase Cloud Messaging