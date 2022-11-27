import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:chat_app/frontend/auth/repository/repository.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is InitialEvent) {
        emit(AuthInitial());
      } else if (event is SignupEvent) {
        emit(AuthLoading());
        try {
          EmailSignupResults auth = await repository.signup(
              email: event.email, password: event.password);
          if (auth == EmailSignupResults.signupCompleted) {
            emit(SignupLoaded());
          } else {
            String message = auth == EmailSignupResults.emailAlreadyPresent
                ? 'Email Already Present. Please Login'
                : 'Signup Failed';
            emit(AuthError(message: message));
          }
        } catch (e) {
          String message = e == EmailSignupResults.emailAlreadyPresent
              ? 'Email Already Present. Please Login'
              : 'Signup Failed';
          emit(AuthError(message: message));
        }
      } else if (event is LoginEvent) {
        emit(AuthLoading());
        try {
          EmailLoginResults auth = await repository.login(
              email: event.email, password: event.password);

          if (auth == EmailLoginResults.loginCompleted) {
            emit(LoginLoaded());
          } else {
            String message = auth == EmailLoginResults.emailAndPasswordInvalid
                ? 'Invalid User Details'
                : auth == EmailLoginResults.emailNotVerified
                    ? 'Email Not verified. \n Please verify. Dont forget to check your spam mail'
                    : 'Login Failed';
            emit(AuthError(message: message));
          }
        } catch (e) {
          emit(AuthError(message: 'Invalid User Details'));
        }
      } else if (event is LogoutEvent) {
        emit(AuthLoading());
        try {
          bool auth = await repository.logout();

          if (auth) {
            emit(LogoutLoaded());
          } else {
            emit(AuthError(message: 'Logout Failed'));
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(AuthError(message: e.toString()));
        }
      } else if (event is GoogleSignInEvent) {
        emit(AuthLoading());
        try {
          GoogleSigninResults auth = await repository.googleSignIn();

          if (auth == GoogleSigninResults.loginCompleted) {
            emit(GoogleSignInLoaded());
          } else {
            emit(AuthError(message: 'Login Failed'));
          }
        } catch (e) {
          emit(AuthError(message: e.toString()));
        }
      } else if (event is GoogleSignOutEvent) {
        emit(AuthLoading());
        try {
          bool auth = await repository.googleSignOut();

          if (auth) {
            emit(LogoutLoaded());
          } else {
            emit(AuthError(message: 'Logout Failed'));
          }
        } catch (e) {
          emit(AuthError(message: e.toString()));
        }
      }
    });
  }
}
