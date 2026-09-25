abstract class AuthEvent {}

class EventSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  EventSignUpRequested({required this.email, required this.password});
}

class EventLoginRequested extends AuthEvent {
  final String email;
  final String password;

  EventLoginRequested({required this.email, required this.password});
}

class EventLogoutRequested extends AuthEvent {}
