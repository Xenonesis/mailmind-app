import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailmind/providers/email_provider.dart';
import 'package:mailmind/providers/auth_provider.dart';
import 'package:mailmind/screens/settings/settings_screen.dart';
import 'package:mailmind/screens/home/email_details_screen.dart';
import 'package:mailmind/widgets/email_card.dart';
import 'package:mailmind/models/email_model.dart';
import 'package:mailmind/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emailListProvider.notifier).loadEmails();
      ref.read(emailCategoriesProvider.notifier).loadCategories();
      ref.read(unreadCountProvider.notifier).loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildInboxScreen(),
              _buildCategoriesScreen(),
              const SettingsScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final unreadCount = ref.watch(unreadCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.inbox_outlined,
                activeIcon: Icons.inbox,
                label: 'Inbox',
                index: 0,
                badge: unreadCount > 0 ? unreadCount.toString() : null,
              ),
              _buildNavItem(
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
                label: 'Categories',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Settings',
                index: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    String? badge,
  }) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.animationDurationMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: AppTheme.animationDurationFast,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInboxScreen() {
    final currentUser = ref.watch(authStateProvider);
    final emailState = ref.watch(emailListProvider);
    final filteredEmails = ref.watch(filteredEmailsProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildInboxHeader(currentUser, unreadCount),
            ),
            actions: [
              if (_isSearching)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                    ref.read(searchResultsProvider.notifier).clearResults();
                  },
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              const SizedBox(width: AppTheme.spacingSm),
            ],
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(emailListProvider.notifier).refreshEmails();
          ref.read(unreadCountProvider.notifier).loadUnreadCount();
        },
        child: _isSearching
            ? _buildSearchInterface()
            : _buildEmailList(emailState, filteredEmails),
      ),
    );
  }

  Widget _buildInboxHeader(currentUser, int unreadCount) {
    final theme = Theme.of(context);
    final userName = currentUser?.user?.fullName ?? 'User';
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLg,
        AppTheme.spacingXl,
        AppTheme.spacingLg,
        AppTheme.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // User avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.lightShadow,
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              
              // Greeting and inbox info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Inbox',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              '$unreadCount new',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildSearchInterface() {
    final theme = Theme.of(context);
    final searchResults = ref.watch(searchResultsProvider);

    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search emails...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchResultsProvider.notifier).clearResults();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingMd,
              ),
            ),
            onChanged: (query) {
              if (query.isNotEmpty) {
                ref.read(searchResultsProvider.notifier).searchEmails(query);
              } else {
                ref.read(searchResultsProvider.notifier).clearResults();
              }
            },
          ),
        ),
        
        // Search results
        Expanded(
          child: searchResults.isEmpty && _searchController.text.isNotEmpty
              ? _buildEmptySearchResults()
              : _buildEmailList(
                  ref.watch(emailListProvider),
                  searchResults,
                  isSearchResults: true,
                ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchResults() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No results found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Try different keywords or check spelling',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesScreen() {
    final categories = ref.watch(emailCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final emailState = ref.watch(emailListProvider);
    final filteredEmails = ref.watch(filteredEmailsProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingLg,
            AppTheme.spacingXl,
            AppTheme.spacingLg,
            AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        
        // Category chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                child: _buildCategoryChip(category, isSelected),
              );
            },
          ),
        ),
        
        // Email list
        Expanded(
          child: _buildEmailList(emailState, filteredEmails),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = category;
      },
      child: AnimatedContainer(
        duration: AppTheme.animationDurationMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 16,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              category.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.all_inbox_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'important':
        return Icons.star_rounded;
      case 'promotions':
        return Icons.local_offer_rounded;
      case 'social':
        return Icons.people_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildEmailList(
    EmailListState emailState,
    List<Email> emails, {
    bool isSearchResults = false,
  }) {
    if (emailState.isLoading && emails.isEmpty) {
      return _buildLoadingState();
    }

    if (emailState.error != null && emails.isEmpty) {
      return _buildErrorState(emailState.error!);
    }

    if (emails.isEmpty) {
      return _buildEmptyState(isSearchResults);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      itemCount: emails.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
      itemBuilder: (context, index) {
        final email = emails[index];
        return EmailCard(
          email: email,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EmailDetailsScreen(email: email),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Loading emails...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(emailListProvider.notifier).loadEmails();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearchResults) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Icon(
                isSearchResults 
                    ? Icons.search_off_rounded 
                    : Icons.inbox_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              isSearchResults ? 'No results found' : 'Your inbox is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              isSearchResults
                  ? 'Try different keywords or check spelling'
                  : 'Pull down to refresh or sync your emails',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}