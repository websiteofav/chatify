import 'package:bloc/bloc.dart';
import 'package:chat_app/frontend/chat/models/chat_model.dart';
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
          bool result = await repository
              .insertOrUpdateImportantUserDB(event.model, insert: event.insert);
          if (result) {
            emit(UserPrimaryDetailsLoaded(model: event.model));
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
      } else if (event is CreateUserMessageTableEvent) {
        emit(HomeLoading());
        try {
          bool result = await repository.createMessageTable(event.username);
          if (result) {
            emit(UserMessageTableCreated(username: event.username));
          } else {
            emit(const UserMessageTableCreationFailed(
                message: 'Message table could not be created'));
          }
        } catch (e) {
          emit(const UserMessageTableCreationFailed(
              message: 'Message table could not be created'));
        }
      } else if (event is InserMessageToTableEvent) {
        emit(HomeLoading());
        try {
          bool result = await repository.insertMessageInUserTable(
              event.model, event.username);
          if (result) {
            emit(UserMessageAddedToTable(model: event.model));
          } else {
            emit(const UserMessageAddedToTableFailed(
                message: 'Message table could not be created'));
          }
        } catch (e) {
          emit(const UserMessageAddedToTableFailed(
              message: 'Message table could not be created'));
        }
      }
    });
  }
}
