import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/email_provider.dart';
import '../../models/email_model.dart';
import '../../widgets/email_card.dart';
import '../settings/settings_screen.dart';
import 'email_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load emails when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emailListProvider.notifier).loadEmails();
      ref.read(emailCategoriesProvider.notifier).loadCategories();
      ref.read(unreadCountProvider.notifier).loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildInboxScreen(),
          _buildCategoriesScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildInboxScreen() {
    final emailState = ref.watch(emailListProvider);
    final filteredEmails = ref.watch(filteredEmailsProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search emails...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  if (query.isNotEmpty) {
                    ref.read(searchResultsProvider.notifier).searchEmails(query);
                  } else {
                    ref.read(searchResultsProvider.notifier).clearResults();
                  }
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  'Hello, ${currentUser?.name ?? currentUser?.fullName ?? 'User'}!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                  Text(
                    'Inbox',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                ref.read(searchResultsProvider.notifier).clearResults();
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            if (unreadCount > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(emailListProvider.notifier).refreshEmails();
          ref.read(unreadCountProvider.notifier).loadUnreadCount();
        },
        child: _buildEmailList(emailState, filteredEmails),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(emailListProvider.notifier).refreshEmails();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildCategoriesScreen() {
    final categories = ref.watch(emailCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final emailState = ref.watch(emailListProvider);
    final filteredEmails = ref.watch(filteredEmailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedCategoryProvider.notifier).state = category;
                    },
                    avatar: Icon(
                      category == 'all' 
                          ? Icons.all_inbox 
                          : Icons.category,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Email List
          Expanded(
            child: _buildEmailList(emailState, filteredEmails),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList(EmailListState emailState, List<Email> emails) {
    if (emailState.isLoading && emails.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (emailState.error != null && emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading emails',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              emailState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(emailListProvider.notifier).loadEmails();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No emails found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or sync your emails',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: emails.length,
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
}