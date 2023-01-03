part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoading extends HomeState {}

class UserPrimaryTableLoaded extends HomeState {}

class UserPrimaryDetailsLoaded extends HomeState {
  final UserPrimaryModel model;

  const UserPrimaryDetailsLoaded({required this.model});
  @override
  List<Object> get props => [model];
}

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

class UserMessageTableCreated extends HomeState {
  final String username;
  const UserMessageTableCreated({required this.username});
  @override
  List<Object> get props => [username];
}

class UserMessageTableCreationFailed extends HomeState {
  final String message;
  const UserMessageTableCreationFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class UserMessageAddedToTable extends HomeState {
  final ChatMessageModel model;
  const UserMessageAddedToTable({required this.model});
  @override
  List<Object> get props => [model];
}

class UserMessageAddedToTableFailed extends HomeState {
  final String message;
  const UserMessageAddedToTableFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class PartnerMessageFetched extends HomeState {
  final List<ChatMessageModel> model;
  final String uername;
  const PartnerMessageFetched({required this.model, required this.uername});
  @override
  List<Object> get props => [model];
}

class PartnerMessageFetchedFailed extends HomeState {
  final String message;
  const PartnerMessageFetchedFailed({required this.message});
  @override
  List<Object> get props => [message];
}
