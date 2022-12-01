import 'package:bloc/bloc.dart';
import 'package:chat_app/frontend/home/models/user_primary_details.dart';
import 'package:chat_app/frontend/home/models/user_secondary_details.dart';
import 'package:chat_app/frontend/home/repository/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeRepository repository;
  HomeBloc({required this.repository}) : super(HomeInitialState()) {
    on<HomeEvent>((event, emit) async {
      if (event is HomeInitial) {
        emit(HomeInitialState());
      } else if (event is CreatePrimaryTableEvent) {
        emit(HomeLoading());
        try {
          bool result = await repository.createimportantUserDB();
          if (result) {
            emit(UserPrimaryTableLoaded());
          } else {
            emit(const UserPrimaryDetailsFaield(
                message: 'User details could not be added'));
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(const UserPrimaryDetailsFaield(
              message: 'User details could not be added'));
        }
      } else if (event is AddPrimaryDataEvent) {
        emit(HomeLoading());
        try {
          bool result =
              await repository.insertOrUpdateImportantUserDB(event.model);
          if (result) {
            emit(UserPrimaryDetailsLoaded());
          } else {
            emit(const UserPrimaryDetailsFaield(
                message: 'User details could not be added'));
          }
        } catch (e) {
          emit(const UserPrimaryDetailsFaield(
              message: 'User details could not be added'));
        }
      } else if (event is CreateSecondaryTableEvent) {
        emit(HomeLoading());
        try {
          bool result =
              await repository.createSecondarytUserDB(username: event.username);
          if (result) {
            emit(UserSecondaryTableLoaded());
          } else {
            emit(const UserSecondaryDetailsFailed(
                message: 'User additional details could not be added'));
          }
        } catch (e) {
          debugPrint(e.toString());
          emit(const UserSecondaryDetailsFailed(
              message: 'User additional details could not be added'));
        }
      } else if (event is AddSecondaryDataEvent) {
        emit(HomeLoading());
        try {
          bool result =
              await repository.insertOrUpdateSecondaryUserDB(event.model);
          if (result) {
            emit(UserSecondaryDetailsLoaded());
          } else {
            emit(const UserSecondaryDetailsFailed(
                message: 'User additional details could not be added'));
          }
        } catch (e) {
          emit(const UserSecondaryDetailsFailed(
              message: 'User additional details could not be added'));
        }
      }
    });
  }
}
