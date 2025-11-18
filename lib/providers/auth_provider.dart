import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'services_providers.dart';

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  const AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({User? user, bool? loading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  late final AuthService _authService;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _authService = ref.read(authServiceProvider);
  }

  Future<void> restoreSession() async {
    state = state.copyWith(loading: true, error: null);
    final restored = await _authService.restoreSession();
    if (restored) {
      state = state.copyWith(user: _authService.currentUser, loading: false);
    } else {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> socialLogin(String provider, String token) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final user = await _authService.socialLogin(provider, token);
      state = state.copyWith(user: user, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
