import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.animationDurationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    // Load notification settings when the screen is built and user is authenticated
    final authState = ref.watch(authStateProvider);
    if (authState.isAuthenticated) {
      ref.read(notificationSettingsProvider.notifier).loadSettings();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserProfile(currentUser, theme),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildAppearanceSection(settings, theme),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildEmailSettingsSection(settings, theme),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildAiFeaturesSection(settings, theme),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildAboutSection(theme),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildLogoutButton(theme),
                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        titlePadding: const EdgeInsets.only(
          left: AppTheme.spacingMd,
          bottom: AppTheme.spacingMd,
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(dynamic currentUser, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildUserAvatar(currentUser, theme),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.fullName ?? 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    'Premium Member',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildEditProfileButton(theme),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(dynamic currentUser, ThemeData theme) {
    final initial = (currentUser?.fullName.isNotEmpty == true
                ? currentUser!.fullName[0].toUpperCase()
        : currentUser?.fullName?.isNotEmpty == true
            ? currentUser!.fullName[0].toUpperCase()
            : 'U');

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: IconButton(
        onPressed: () {
          _showSnackBar('Profile editing not implemented yet');
        },
        icon: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(dynamic settings, ThemeData theme) {
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette_rounded,
      theme: theme,
      children: [
        _buildModernSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark themes',
          icon: settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          value: settings.isDarkMode,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateThemeMode(value);
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildEmailSettingsSection(dynamic settings, ThemeData theme) {
    return _buildSection(
      title: 'Email Settings',
      icon: Icons.email_rounded,
      theme: theme,
      children: [
        _buildModernSwitchTile(
          title: 'Auto Sync',
          subtitle: 'Automatically sync emails in background',
          icon: Icons.sync_rounded,
          value: settings.autoSync,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAutoSync(value);
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernListTile(
          title: 'Sync Frequency',
          subtitle: 'Every ${settings.syncFrequency} minutes',
          icon: Icons.schedule_rounded,
          onTap: () {
            _showSyncFrequencyDialog(context, ref, settings.syncFrequency);
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernSwitchTile(
          title: 'Notifications',
          subtitle: 'Receive notifications for new emails',
          icon: Icons.notifications_rounded,
          value: settings.enableNotifications,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateNotifications(value);
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildAiFeaturesSection(dynamic settings, ThemeData theme) {
    return _buildSection(
      title: 'AI Features',
      icon: Icons.psychology_rounded,
      theme: theme,
      children: [
        _buildModernListTile(
          title: 'AI Model',
          subtitle: settings.aiModel,
          icon: Icons.smart_toy_rounded,
          onTap: () {
            _showAiModelDialog(context, ref, settings.aiModel);
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernSwitchTile(
          title: 'Email Summaries',
          subtitle: 'Generate AI summaries for emails',
          icon: Icons.auto_awesome_rounded,
          value: settings.enableSummaries,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAiFeatures(
              enableSummaries: value,
            );
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernSwitchTile(
          title: 'Auto Categorization',
          subtitle: 'Automatically categorize emails',
          icon: Icons.category_rounded,
          value: settings.enableCategorization,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAiFeatures(
              enableCategorization: value,
            );
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernSwitchTile(
          title: 'Priority Detection',
          subtitle: 'Detect email priority automatically',
          icon: Icons.priority_high_rounded,
          value: settings.enablePriorityDetection,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).updateAiFeatures(
              enablePriorityDetection: value,
            );
          },
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return _buildSection(
      title: 'About',
      icon: Icons.info_rounded,
      theme: theme,
      children: [
        _buildModernListTile(
          title: 'Privacy Policy',
          subtitle: 'Learn how we protect your data',
          icon: Icons.privacy_tip_rounded,
          onTap: () {
            _showSnackBar('Privacy policy not implemented yet');
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernListTile(
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          icon: Icons.description_rounded,
          onTap: () {
            _showSnackBar('Terms of service not implemented yet');
          },
          theme: theme,
        ),
        _buildDivider(theme),
        _buildModernListTile(
          title: 'App Version',
          subtitle: '1.0.0',
          icon: Icons.info_outline_rounded,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingSm,
            bottom: AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildModernSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: Divider(
        height: 1,
        color: theme.colorScheme.outline.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.error.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context, ref),
        icon: const Icon(Icons.logout_rounded),
        label: Text(
                  'Logout',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _showSyncFrequencyDialog(BuildContext context, WidgetRef ref, int currentFrequency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Sync Frequency'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption(context, ref, '5 minutes', 5, currentFrequency),
            _buildRadioOption(context, ref, '15 minutes', 15, currentFrequency),
            _buildRadioOption(context, ref, '30 minutes', 30, currentFrequency),
            _buildRadioOption(context, ref, '1 hour', 60, currentFrequency),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(BuildContext context, WidgetRef ref, String title, int value, int currentFrequency) {
    return RadioListTile<int>(
      title: Text(title),
      value: value,
      groupValue: currentFrequency,
      onChanged: (selectedValue) {
        if (selectedValue != null) {
          ref.read(settingsProvider.notifier).updateSyncFrequency(selectedValue);
          Navigator.of(context).pop();
        }
      },
      activeColor: Theme.of(context).colorScheme.primary,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.smart_toy_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('AI Model'),
          ],
        ),
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
            activeColor: Theme.of(context).colorScheme.primary,
          )).toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMd),
      ),
    );
  }
}