import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_response.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getStoredUser();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authResponse = await _authRepository.login(
        email: email,
        password: password,
      );
      
      state = AuthState.authenticated(authResponse.user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Register new user
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authResponse = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      
      state = AuthState.authenticated(authResponse.user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Google OAuth login
  Future<void> loginWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // This would typically involve opening a web view or using google_sign_in
      // For now, we'll just get the auth URL
      final authUrl = await _authRepository.getGoogleAuthUrl();
      
      // In a real implementation, you would:
      // 1. Open the auth URL in a web view
      // 2. Handle the callback with the authorization code
      // 3. Call handleGoogleCallback with the code
      
      // For demo purposes, we'll just set an error
      state = state.copyWith(
        isLoading: false,
        error: 'Google OAuth not fully implemented yet',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Handle Google OAuth callback
  Future<void> handleGoogleCallback(String code) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authResponse = await _authRepository.handleGoogleCallback(code);
      state = AuthState.authenticated(authResponse.user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      // Even if logout fails, clear the state
      state = const AuthState.unauthenticated();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AuthState.authenticated(user);
    } catch (e) {
      // If refresh fails, user might need to login again
      state = const AuthState.unauthenticated();
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  const AuthState.initial() : this(isLoading: true);
  const AuthState.unauthenticated() : this();
  const AuthState.authenticated(User user) : this(user: user);

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? false,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(user: $user, isLoading: $isLoading, error: $error)';
  }
}