# MailMind - AI-Powered Email Management App

MailMind is a Flutter mobile application that provides intelligent email management with AI-powered features like automatic categorization, priority detection, and email summaries.

## Features

### 🔐 Authentication
- Email/password login and registration
- Google OAuth integration (ready for backend implementation)
- Secure token storage using Flutter Secure Storage
- Automatic authentication state management

### 📧 Email Management
- View emails organized by categories (Inbox, Work, Personal, Promotions, etc.)
- AI-powered email summaries
- Priority detection (High, Medium, Low)
- Automatic email categorization
- Mark emails as important/unimportant
- Delete emails with confirmation
- Pull-to-refresh functionality
- Search emails functionality

### 🎨 User Interface
- Material 3 design system
- Light and dark theme support
- Professional and modern UI/UX
- Responsive design for different screen sizes
- Smooth animations and transitions

### ⚙️ Settings & Preferences
- Theme toggle (Light/Dark mode)
- AI model selection
- Sync frequency configuration
- Notification preferences
- Auto-sync settings
- User profile management

### 🤖 AI Integration
- Email summarization
- Automatic categorization
- Priority detection
- Configurable AI models (GPT-3.5, GPT-4, Claude, etc.)

## Tech Stack

- **Framework**: Flutter 3.22+
- **Language**: Dart
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Hive + Flutter Secure Storage
- **Authentication**: Google Sign-In + Custom Auth
- **Theme**: Material 3 + Google Fonts
- **Build System**: Flutter Build Runner

## Project Structure

```
lib/
├── api/
│   ├── dio_client.dart          # HTTP client configuration
│   └── endpoints.dart           # API endpoint definitions
├── models/
│   ├── user_model.dart          # User data model
│   ├── email_model.dart         # Email data model
│   ├── auth_response.dart       # Authentication response model
│   └── user_settings.dart       # User settings model
├── providers/
│   ├── auth_provider.dart       # Authentication state management
│   ├── email_provider.dart      # Email state management
│   └── settings_provider.dart   # Settings state management
├── repositories/
│   ├── auth_repository.dart     # Authentication API calls
│   ├── email_repository.dart    # Email API calls
│   └── user_repository.dart     # User management API calls
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Login interface
│   │   └── signup_screen.dart   # Registration interface
│   ├── home/
│   │   ├── home_screen.dart     # Main email interface
│   │   └── email_details_screen.dart # Email details view
│   ├── settings/
│   │   └── settings_screen.dart # Settings interface
│   └── splash_screen.dart       # App initialization screen
├── widgets/
│   ├── email_card.dart          # Email list item widget
│   └── summary_box.dart         # AI summary display widget
├── theme/
│   └── app_theme.dart           # Material 3 theme configuration
└── main.dart                    # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.22 or higher
- Dart SDK 3.9 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mailmind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (Hive adapters)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure Backend URL**
   Update the `baseUrl` in `lib/api/endpoints.dart` with your backend URL:
   ```dart
   static const String baseUrl = 'https://your-backend-url.com/api/v1';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Backend Integration

The app is designed to work with a NestJS backend. Make sure your backend implements the following endpoints:

#### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /auth/google` - Google OAuth initiation
- `GET /auth/google/callback` - Google OAuth callback

#### User Management
- `GET /user/profile` - Get user profile
- `GET /user/settings` - Get user settings
- `PUT /user/settings` - Update user settings

#### Email Management
- `GET /emails/sync` - Sync emails from external provider
- `GET /emails` - Get user emails (with optional category filter)
- `GET /emails/:id` - Get specific email
- `GET /emails/categories` - Get available categories

For detailed API documentation, see `endpoints.md`.

## Configuration

### Environment Variables
Create a `.env` file in the root directory (if needed for additional configuration):
```
API_BASE_URL=https://your-backend-url.com/api/v1
GOOGLE_CLIENT_ID=your-google-client-id
```

### Google OAuth Setup
1. Create a project in Google Cloud Console
2. Enable Google Sign-In API
3. Configure OAuth consent screen
4. Add your app's SHA-1 fingerprint for Android
5. Update `android/app/google-services.json` with your configuration

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Features in Detail

### AI-Powered Email Management
- **Smart Summaries**: Get concise AI-generated summaries of long emails
- **Auto-Categorization**: Emails are automatically sorted into relevant categories
- **Priority Detection**: Important emails are automatically flagged based on content analysis
- **Configurable AI Models**: Choose from different AI models based on your needs

### Professional UI/UX
- **Material 3 Design**: Modern, accessible design following Google's latest design guidelines
- **Dark Mode Support**: Seamless switching between light and dark themes
- **Responsive Layout**: Optimized for different screen sizes and orientations
- **Smooth Animations**: Polished user experience with meaningful transitions

### Secure Data Management
- **Local Encryption**: Sensitive data stored securely using Flutter Secure Storage
- **Token Management**: Automatic token refresh and secure storage
- **Offline Support**: Core functionality available even without internet connection

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@mailmind.app or create an issue in the repository.

## Roadmap

- [ ] Push notifications
- [ ] Email composition and sending
- [ ] Advanced search filters
- [ ] Email templates
- [ ] Bulk operations
- [ ] Integration with more email providers
- [ ] Desktop version (Flutter Desktop)
- [ ] Web version (Flutter Web)

---

**MailMind** - Making email management smarter and simpler! 📧✨
