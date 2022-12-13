part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {}

class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

class SignupLoaded extends AuthState {
  SignupLoaded();
  @override
  List<Object> get props => [];
}

class LoginLoaded extends AuthState {
  LoginLoaded();
  @override
  List<Object> get props => [];
}

class LoginError extends AuthState {
  final String message;
  LoginError({required this.message});
  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
  @override
  List<Object> get props => [message];
}

class LogoutLoaded extends AuthState {
  LogoutLoaded();
  @override
  List<Object> get props => [];
}

class GoogleSignInLoaded extends AuthState {
  GoogleSignInLoaded();
  @override
  List<Object> get props => [];
}

class GoogleSignOutLoaded extends AuthState {
  GoogleSignOutLoaded();
  @override
  List<Object> get props => [];
}


// class LoginRegisterLoaded extends AuthState {
//   // final LoginRegisterResponseModel model;
//   LoginRegisterLoaded({required this.model});
// }


