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
  const AddPrimaryDataEvent({required this.model});

  @override
  List<Object> get props => [model];
}

class AddSecondaryDataEvent extends HomeEvent {
  final UserSecondaryModel model;
  const AddSecondaryDataEvent({required this.model});

  @override
  List<Object> get props => [model];
}
