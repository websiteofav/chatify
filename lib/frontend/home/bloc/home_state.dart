part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoading extends HomeState {}

class UserPrimaryTableLoaded extends HomeState {}

class UserPrimaryDetailsLoaded extends HomeState {}

class UserPrimaryDetailsFaield extends HomeState {
  final String message;
  const UserPrimaryDetailsFaield({required this.message});
  @override
  List<Object> get props => [message];
}

class UserSecondaryTableLoaded extends HomeState {}

class UserSecondaryDetailsLoaded extends HomeState {}

class UserSecondaryDetailsFailed extends HomeState {
  final String message;
  const UserSecondaryDetailsFailed({required this.message});
  @override
  List<Object> get props => [message];
}
