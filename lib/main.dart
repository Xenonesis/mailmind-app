import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_model.dart';
import 'models/email_model.dart';
import 'models/user_settings.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(EmailAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  
  // Open Hive boxes
  await Hive.openBox<User>('users');
  await Hive.openBox<Email>('emails');
  await Hive.openBox<UserSettings>('settings');
  
  runApp(
    const ProviderScope(
      child: MailMindApp(),
    ),
  );
}

class MailMindApp extends ConsumerWidget {
  const MailMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'MailMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
