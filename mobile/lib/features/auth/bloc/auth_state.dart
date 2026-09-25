abstract class AuthState {}

class StateAuthInitial extends AuthState {}

class StateAuthLoading extends AuthState {}

class StateAuthAuthenticated extends AuthState {}

class StateAuthFailure extends AuthState {
  final String message;

  StateAuthFailure(this.message);
}
