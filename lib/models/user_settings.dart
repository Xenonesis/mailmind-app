import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final String aiModel;

  @HiveField(2)
  final int syncFrequency; // in minutes

  @HiveField(3)
  final bool enableNotifications;

  @HiveField(4)
  final bool autoSync;

  @HiveField(5)
  final String language;

  @HiveField(6)
  final bool enableSummaries;

  @HiveField(7)
  final bool enableCategorization;

  @HiveField(8)
  final bool enablePriorityDetection;

  UserSettings({
    this.isDarkMode = false,
    this.aiModel = 'gpt-3.5-turbo',
    this.syncFrequency = 15,
    this.enableNotifications = true,
    this.autoSync = true,
    this.language = 'en',
    this.enableSummaries = true,
    this.enableCategorization = true,
    this.enablePriorityDetection = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      aiModel: json['aiModel'] ?? 'gpt-3.5-turbo',
      syncFrequency: json['syncFrequency'] ?? 15,
      enableNotifications: json['enableNotifications'] ?? true,
      autoSync: json['autoSync'] ?? true,
      language: json['language'] ?? 'en',
      enableSummaries: json['enableSummaries'] ?? true,
      enableCategorization: json['enableCategorization'] ?? true,
      enablePriorityDetection: json['enablePriorityDetection'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'aiModel': aiModel,
      'syncFrequency': syncFrequency,
      'enableNotifications': enableNotifications,
      'autoSync': autoSync,
      'language': language,
      'enableSummaries': enableSummaries,
      'enableCategorization': enableCategorization,
      'enablePriorityDetection': enablePriorityDetection,
    };
  }

  UserSettings copyWith({
    bool? isDarkMode,
    String? aiModel,
    int? syncFrequency,
    bool? enableNotifications,
    bool? autoSync,
    String? language,
    bool? enableSummaries,
    bool? enableCategorization,
    bool? enablePriorityDetection,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      aiModel: aiModel ?? this.aiModel,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSync: autoSync ?? this.autoSync,
      language: language ?? this.language,
      enableSummaries: enableSummaries ?? this.enableSummaries,
      enableCategorization: enableCategorization ?? this.enableCategorization,
      enablePriorityDetection: enablePriorityDetection ?? this.enablePriorityDetection,
    );
  }

  @override
  String toString() {
    return 'UserSettings(isDarkMode: $isDarkMode, aiModel: $aiModel, syncFrequency: $syncFrequency)';
  }
}