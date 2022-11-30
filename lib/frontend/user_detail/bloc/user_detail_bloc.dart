import 'package:bloc/bloc.dart';
import 'package:chat_app/frontend/auth/bloc/auth_bloc.dart';
import 'package:chat_app/frontend/user_detail/repository/repository.dart';
import 'package:chat_app/frontend/utils/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository repository;
  UserDetailBloc({required this.repository}) : super(UserDetailInitial()) {
    on<UserDetailEvent>((event, emit) async {
      if (event is InitialEvent) {
        emit(UserDetailInitial());
      } else if (event is FetchUserEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsResults auth =
              await repository.checkUserAlreadyExists(userName: event.userName);
          if (auth == UserDetailsResults.userNotFound) {
            emit(UserDetalsFetched());
          } else {
            emit(const UserDetailError(message: 'Username already Exists'));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is RegisterUserDetailsEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsAddedResults auth = await repository.registerUserDetails(
            username: event.userName,
            bio: event.bio,
            email: event.email,
          );

          if (auth == UserDetailsAddedResults.detailAdded) {
            emit(UserDetalsAdded());
          } else {
            return emit(
                const UserDetailError(message: 'Details could not be added'));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is UserRecordEvent) {
        emit(UserDetailLoading());
        try {
          UserDetailsRecordsResults records =
              await repository.searchUserRecords();

          if (records == UserDetailsRecordsResults.userNotFound) {
            emit(const UserDetailError(message: 'No user found'));
          } else if (records == UserDetailsRecordsResults.detailsNotFound) {
            emit(const UserDetailError(message: 'No records found'));
          } else {
            emit(UserDetalsExists());
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'Something went wrong'));
        }
      } else if (event is FetchUserPartnersEvent) {
        emit(UserDetailLoading());
        try {
          List partners =
              await repository.currentUserPartners(email: event.email);

          if (partners.isEmpty) {
            emit(const GetUserPartnersFailed(message: 'No partners found'));
          } else {
            emit(GetUserPartners(partner: partners));
          }
        } catch (e) {
          debugPrint(e.toString());

          emit(const UserDetailError(message: 'No partners found'));
        }
      }
    });
  }
}
