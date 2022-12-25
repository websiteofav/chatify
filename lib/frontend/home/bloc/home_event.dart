part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeEvent {}

class CreatePrimaryTableEvent extends HomeEvent {
  const CreatePrimaryTableEvent();

  @override
  List<Object> get props => [];
}

class CreateSecondaryTableEvent extends HomeEvent {
  final String username;
  const CreateSecondaryTableEvent({required this.username});

  @override
  List<Object> get props => [];
}

class AddPrimaryDataEvent extends HomeEvent {
  final UserPrimaryModel model;
  bool insert;
  AddPrimaryDataEvent({required this.model, this.insert = true});

  @override
  List<Object> get props => [model];
}

class AddSecondaryDataEvent extends HomeEvent {
  final UserSecondaryModel model;
  const AddSecondaryDataEvent({required this.model});

  @override
  List<Object> get props => [model];
}

class CreateUserMessageTableEvent extends HomeEvent {
  final String username;
  const CreateUserMessageTableEvent({required this.username});

  @override
  List<Object> get props => [];
}

class InserMessageToTableEvent extends HomeEvent {
  final String username;
  ChatMessageModel model;
  InserMessageToTableEvent({required this.username, required this.model});

  @override
  List<Object> get props => [username, model];
}
