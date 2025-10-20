import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/email_repository.dart';
import '../models/email_model.dart';

// Email repository provider
final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  return EmailRepository();
});

// Email list provider
final emailListProvider = StateNotifierProvider<EmailListNotifier, EmailListState>((ref) {
  final emailRepository = ref.watch(emailRepositoryProvider);
  return EmailListNotifier(emailRepository);
});

// Selected category provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

// Filtered emails provider
final filteredEmailsProvider = Provider<List<Email>>((ref) {
  final emailState = ref.watch(emailListProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  if (emailState.emails.isEmpty) return [];
  
  if (selectedCategory == 'all') {
    return emailState.emails;
  }
  
  return emailState.emails.where((email) => email.category == selectedCategory).toList();
});

// Email categories provider
final emailCategoriesProvider = StateNotifierProvider<EmailCategoriesNotifier, List<String>>((ref) {
  final emailRepository = ref.watch(emailRepositoryProvider);
  return EmailCategoriesNotifier(emailRepository);
});

// Unread count provider
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  final emailRepository = ref.watch(emailRepositoryProvider);
  return UnreadCountNotifier(emailRepository);
});

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Search results provider
final searchResultsProvider = StateNotifierProvider<SearchResultsNotifier, List<Email>>((ref) {
  final emailRepository = ref.watch(emailRepositoryProvider);
  return SearchResultsNotifier(emailRepository);
});

class EmailListNotifier extends StateNotifier<EmailListState> {
  final EmailRepository _emailRepository;

  EmailListNotifier(this._emailRepository) : super(const EmailListState.initial()) {
    loadEmails();
  }

  // Load emails
  Future<void> loadEmails({String? category}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final emails = await _emailRepository.getEmails(category: category);
      
      state = EmailListState.loaded(emails);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh emails
  Future<void> refreshEmails() async {
    try {
      // First sync emails from external provider
      await _emailRepository.syncEmails();
      
      // Then load the updated emails
      await loadEmails();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Mark email as read
  Future<void> markAsRead(String emailId) async {
    try {
      await _emailRepository.markAsRead(emailId);
      
      // Update local state
      final updatedEmails = state.emails.map((email) {
        if (email.id == emailId) {
          return Email(
            id: email.id,
            subject: email.subject,
            sender: email.sender,
            senderEmail: email.senderEmail,
            recipients: email.recipients,
            body: email.body,
            htmlBody: email.htmlBody,
            receivedAt: email.receivedAt,
            category: email.category,
            priority: email.priority,
            summary: email.summary,
            isRead: true,
            isImportant: email.isImportant,
            attachments: email.attachments,
            threadId: email.threadId,
          );
        }
        return email;
      }).toList();
      
      state = EmailListState.loaded(updatedEmails);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Mark email as important
  Future<void> markAsImportant(String emailId, bool isImportant) async {
    try {
      await _emailRepository.markAsImportant(emailId, isImportant);
      
      // Update local state
      final updatedEmails = state.emails.map((email) {
        if (email.id == emailId) {
          return Email(
            id: email.id,
            subject: email.subject,
            sender: email.sender,
            senderEmail: email.senderEmail,
            recipients: email.recipients,
            body: email.body,
            htmlBody: email.htmlBody,
            receivedAt: email.receivedAt,
            category: email.category,
            priority: email.priority,
            summary: email.summary,
            isRead: email.isRead,
            isImportant: isImportant,
            attachments: email.attachments,
            threadId: email.threadId,
          );
        }
        return email;
      }).toList();
      
      state = EmailListState.loaded(updatedEmails);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete email
  Future<void> deleteEmail(String emailId) async {
    try {
      await _emailRepository.deleteEmail(emailId);
      
      // Remove from local state
      final updatedEmails = state.emails.where((email) => email.id != emailId).toList();
      state = EmailListState.loaded(updatedEmails);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

class EmailListState {
  final List<Email> emails;
  final bool isLoading;
  final String? error;

  const EmailListState({
    this.emails = const [],
    this.isLoading = false,
    this.error,
  });

  const EmailListState.initial() : this(isLoading: true);
  const EmailListState.loaded(List<Email> emails) : this(emails: emails);

  EmailListState copyWith({
    List<Email>? emails,
    bool? isLoading,
    String? error,
  }) {
    return EmailListState(
      emails: emails ?? this.emails,
      isLoading: isLoading ?? false,
      error: error,
    );
  }
}

class EmailCategoriesNotifier extends StateNotifier<List<String>> {
  final EmailRepository _emailRepository;

  EmailCategoriesNotifier(this._emailRepository) : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _emailRepository.getEmailCategories();
      state = ['all', ...categories];
    } catch (e) {
      state = ['all', 'inbox', 'sent', 'drafts', 'spam'];
    }
  }
}

class UnreadCountNotifier extends StateNotifier<int> {
  final EmailRepository _emailRepository;

  UnreadCountNotifier(this._emailRepository) : super(0) {
    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _emailRepository.getUnreadCount();
      state = count;
    } catch (e) {
      state = 0;
    }
  }

  void updateCount(int newCount) {
    state = newCount;
  }
}

class SearchResultsNotifier extends StateNotifier<List<Email>> {
  final EmailRepository _emailRepository;

  SearchResultsNotifier(this._emailRepository) : super([]);

  Future<void> searchEmails(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    try {
      final results = await _emailRepository.searchEmails(query);
      state = results;
    } catch (e) {
      state = [];
    }
  }

  void clearResults() {
    state = [];
  }
}