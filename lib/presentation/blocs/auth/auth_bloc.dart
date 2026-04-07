import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC for authentication state management
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient;

  AuthBloc({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);

    // Listen to auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        add(const AuthCheckRequested());
      } else if (event == AuthChangeEvent.signedOut) {
        add(const AuthSignOutRequested());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final currentUser = _supabaseClient.auth.currentUser;

      if (currentUser != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: currentUser,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        ));
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Authentication failed',
        ));
      }
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session == null) {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Please check your email to confirm your account',
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: response.user,
          ));
        }
      } else {
        emit(state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign up failed',
        ));
      }
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _supabaseClient.auth.signOut();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _supabaseClient.auth.resetPasswordForEmail(event.email);
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Password reset email sent. Please check your inbox.',
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: SupabaseErrorHandler.getMessage(e),
      ));
    }
  }
}
