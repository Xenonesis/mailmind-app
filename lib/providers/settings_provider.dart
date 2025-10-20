import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/user_repository.dart';
import '../models/user_settings.dart';
import 'auth_provider.dart'; // Add this import

// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  return SettingsNotifier(userRepository, authState);
});

// Theme mode provider (derived from settings)
final themeModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.isDarkMode;
});

// Notification settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, Map<String, bool>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return NotificationSettingsNotifier(userRepository);
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  final UserRepository _userRepository;
  final AuthState _authState;
  SharedPreferences? _prefs;

  SettingsNotifier(this._userRepository, this._authState) : super(UserSettings()) {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Load settings from local storage first
      final localSettings = _loadLocalSettings();
      state = localSettings;
      
      // Only try to load from server if user is authenticated
      if (_authState.isAuthenticated) {
        try {
          final serverSettings = await _userRepository.getUserSettings();
          state = serverSettings;
          await _saveLocalSettings(serverSettings);
        } catch (e) {
          // If server fails, keep local settings
          print('Failed to load server settings: $e');
        }
      }
    } catch (e) {
      // Use default settings if everything fails
      state = UserSettings();
    }
  }

  UserSettings _loadLocalSettings() {
    if (_prefs == null) return UserSettings();
    
    return UserSettings(
      isDarkMode: _prefs!.getBool('isDarkMode') ?? false,
      aiModel: _prefs!.getString('aiModel') ?? 'gpt-3.5-turbo',
      syncFrequency: _prefs!.getInt('syncFrequency') ?? 15,
      enableNotifications: _prefs!.getBool('enableNotifications') ?? true,
      autoSync: _prefs!.getBool('autoSync') ?? true,
      language: _prefs!.getString('language') ?? 'en',
      enableSummaries: _prefs!.getBool('enableSummaries') ?? true,
      enableCategorization: _prefs!.getBool('enableCategorization') ?? true,
      enablePriorityDetection: _prefs!.getBool('enablePriorityDetection') ?? true,
    );
  }

  Future<void> _saveLocalSettings(UserSettings settings) async {
    if (_prefs == null) return;
    
    await _prefs!.setBool('isDarkMode', settings.isDarkMode);
    await _prefs!.setString('aiModel', settings.aiModel);
    await _prefs!.setInt('syncFrequency', settings.syncFrequency);
    await _prefs!.setBool('enableNotifications', settings.enableNotifications);
    await _prefs!.setBool('autoSync', settings.autoSync);
    await _prefs!.setString('language', settings.language);
    await _prefs!.setBool('enableSummaries', settings.enableSummaries);
    await _prefs!.setBool('enableCategorization', settings.enableCategorization);
    await _prefs!.setBool('enablePriorityDetection', settings.enablePriorityDetection);
  }

  // Update theme mode
  Future<void> updateThemeMode(bool isDarkMode) async {
    final newSettings = state.copyWith(isDarkMode: isDarkMode);
    await _updateSettings(newSettings);
  }

  // Update AI model
  Future<void> updateAiModel(String aiModel) async {
    final newSettings = state.copyWith(aiModel: aiModel);
    await _updateSettings(newSettings);
  }

  // Update sync frequency
  Future<void> updateSyncFrequency(int frequency) async {
    final newSettings = state.copyWith(syncFrequency: frequency);
    await _updateSettings(newSettings);
  }

  // Update notifications
  Future<void> updateNotifications(bool enabled) async {
    final newSettings = state.copyWith(enableNotifications: enabled);
    await _updateSettings(newSettings);
  }

  // Update auto sync
  Future<void> updateAutoSync(bool enabled) async {
    final newSettings = state.copyWith(autoSync: enabled);
    await _updateSettings(newSettings);
  }

  // Update language
  Future<void> updateLanguage(String language) async {
    final newSettings = state.copyWith(language: language);
    await _updateSettings(newSettings);
  }

  // Update AI features
  Future<void> updateAiFeatures({
    bool? enableSummaries,
    bool? enableCategorization,
    bool? enablePriorityDetection,
  }) async {
    final newSettings = state.copyWith(
      enableSummaries: enableSummaries,
      enableCategorization: enableCategorization,
      enablePriorityDetection: enablePriorityDetection,
    );
    await _updateSettings(newSettings);
  }

  // Update all settings
  Future<void> updateSettings(UserSettings settings) async {
    await _updateSettings(settings);
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    try {
      // Update local state immediately
      state = newSettings;
      await _saveLocalSettings(newSettings);
      
      // Try to update server only if authenticated
      if (_authState.isAuthenticated) {
        try {
          await _userRepository.updateUserSettings(newSettings);
        } catch (e) {
          // If server update fails, keep local changes
          print('Failed to update server settings: $e');
        }
      }
    } catch (e) {
      // If local save fails, revert state
      await _initializeSettings();
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    final defaultSettings = UserSettings();
    await _updateSettings(defaultSettings);
  }

  // Export settings
  Map<String, dynamic> exportSettings() {
    return state.toJson();
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settingsJson) async {
    try {
      final importedSettings = UserSettings.fromJson(settingsJson);
      await _updateSettings(importedSettings);
    } catch (e) {
      throw Exception('Invalid settings format');
    }
  }
}

class NotificationSettingsNotifier extends StateNotifier<Map<String, bool>> {
  final UserRepository _userRepository;

  NotificationSettingsNotifier(this._userRepository) : super({}) {
    // Don't automatically load notification settings on initialization
    // They will be loaded when needed and user is authenticated
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final settings = await _userRepository.getNotificationPreferences();
      state = settings;
    } catch (e) {
      state = {
        'enableNotifications': true,
        'enableEmailAlerts': true,
        'enablePushNotifications': true,
      };
    }
  }

  // Public method to load settings when needed
  Future<void> loadSettings() async {
    await _loadNotificationSettings();
  }

  Future<void> updateNotificationSettings({
    bool? enableNotifications,
    bool? enableEmailAlerts,
    bool? enablePushNotifications,
  }) async {
    try {
      final newSettings = Map<String, bool>.from(state);
      
      if (enableNotifications != null) {
        newSettings['enableNotifications'] = enableNotifications;
      }
      if (enableEmailAlerts != null) {
        newSettings['enableEmailAlerts'] = enableEmailAlerts;
      }
      if (enablePushNotifications != null) {
        newSettings['enablePushNotifications'] = enablePushNotifications;
      }

      state = newSettings;

      await _userRepository.updateNotificationPreferences(
        enableNotifications: newSettings['enableNotifications'] ?? true,
        enableEmailAlerts: newSettings['enableEmailAlerts'] ?? true,
        enablePushNotifications: newSettings['enablePushNotifications'] ?? true,
      );
    } catch (e) {
      // Revert on error
      await _loadNotificationSettings();
      rethrow;
    }
  }
}