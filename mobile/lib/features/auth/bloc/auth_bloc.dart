import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      super(StateAuthInitial()) {
    on<EventSignUpRequested>(_onSignUpRequested);
    on<EventLoginRequested>(_onLoginRequested);
    on<EventLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSignUpRequested(
    EventSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(StateAuthLoading());

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(StateAuthAuthenticated());
    } on FirebaseAuthException catch (error) {
      emit(StateAuthFailure(error.message ?? 'Sign up failed'));
    }
  }

  Future<void> _onLoginRequested(
    EventLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(StateAuthLoading());

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(StateAuthAuthenticated());
    } on FirebaseAuthException catch (error) {
      emit(StateAuthFailure(error.message ?? 'Login failed'));
    }
  }

  Future<void> _onLogoutRequested(
    EventLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _firebaseAuth.signOut();

    emit(StateAuthInitial());
  }
}
