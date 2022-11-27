part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {}

class InitialEvent extends AuthEvent {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.password, required this.email});
  @override
  List<Object?> get props => [password, password];
}

class SignupEvent extends AuthEvent {
  final String email;
  final String password;

  SignupEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {
  LogoutEvent();

  @override
  List<Object?> get props => [];
}

class GoogleSignInEvent extends AuthEvent {
  GoogleSignInEvent();

  @override
  List<Object?> get props => [];
}

class GoogleSignOutEvent extends AuthEvent {
  GoogleSignOutEvent();

  @override
  List<Object?> get props => [];
}
