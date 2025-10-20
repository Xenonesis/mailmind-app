import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        (currentUser?.name.isNotEmpty == true
                            ? currentUser!.name[0].toUpperCase()
                            : currentUser?.fullName.isNotEmpty == true
                                ? currentUser!.fullName[0].toUpperCase()
                                : 'U'),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          currentUser?.fullName ?? 'User',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                          const SizedBox(height: 4),
                          Text(
                            currentUser?.email ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    IconButton(
                      onPressed: () {
                        // Edit profile functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile editing not implemented yet'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Appearance Section
            Text(
              'Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark themes'),
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateThemeMode(value);
                    },
                    secondary: Icon(
                      settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Email Settings Section
            Text(
              'Email Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Automatically sync emails in background'),
                    value: settings.autoSync,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAutoSync(value);
                    },
                    secondary: const Icon(Icons.sync),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Sync Frequency'),
                    subtitle: Text('Every ${settings.syncFrequency} minutes'),
                    leading: const Icon(Icons.schedule),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showSyncFrequencyDialog(context, ref, settings.syncFrequency);
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Receive notifications for new emails'),
                    value: settings.enableNotifications,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateNotifications(value);
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Features Section
            Text(
              'AI Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('AI Model'),
                    subtitle: Text(settings.aiModel),
                    leading: const Icon(Icons.psychology),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showAiModelDialog(context, ref, settings.aiModel);
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Email Summaries'),
                    subtitle: const Text('Generate AI summaries for emails'),
                    value: settings.enableSummaries,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAiFeatures(
                        enableSummaries: value,
                      );
                    },
                    secondary: const Icon(Icons.auto_awesome),
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Auto Categorization'),
                    subtitle: const Text('Automatically categorize emails'),
                    value: settings.enableCategorization,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAiFeatures(
                        enableCategorization: value,
                      );
                    },
                    secondary: const Icon(Icons.category),
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Priority Detection'),
                    subtitle: const Text('Detect email priority automatically'),
                    value: settings.enablePriorityDetection,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAiFeatures(
                        enablePriorityDetection: value,
                      );
                    },
                    secondary: const Icon(Icons.priority_high),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // About Section
            Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Privacy Policy'),
                    leading: const Icon(Icons.privacy_tip),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Open privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy policy not implemented yet'),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Terms of Service'),
                    leading: const Icon(Icons.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Open terms of service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of service not implemented yet'),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                    leading: const Icon(Icons.info),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSyncFrequencyDialog(BuildContext context, WidgetRef ref, int currentFrequency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('5 minutes'),
              value: 5,
              groupValue: currentFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSyncFrequency(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('15 minutes'),
              value: 15,
              groupValue: currentFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSyncFrequency(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('30 minutes'),
              value: 30,
              groupValue: currentFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSyncFrequency(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<int>(
              title: const Text('1 hour'),
              value: 60,
              groupValue: currentFrequency,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSyncFrequency(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAiModelDialog(BuildContext context, WidgetRef ref, String currentModel) {
    final models = [
      'gpt-3.5-turbo',
      'gpt-4',
      'claude-3-haiku',
      'claude-3-sonnet',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: models.map((model) => RadioListTile<String>(
            title: Text(model),
            value: model,
            groupValue: currentModel,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).updateAiModel(value);
                Navigator.of(context).pop();
              }
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}