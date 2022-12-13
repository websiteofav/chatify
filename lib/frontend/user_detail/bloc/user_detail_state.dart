part of 'user_detail_bloc.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {
  @override
  List<Object> get props => [];
}

class UserDetalsFetched extends UserDetailState {
  @override
  List<Object> get props => [];
}

class UserDetalsAdded extends UserDetailState {
  @override
  List<Object> get props => [];
}

class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError({required this.message});
  @override
  List<Object> get props => [message];
}

class UserDetalsExists extends UserDetailState {
  @override
  List<Object> get props => [];
}

class UserDetalsExistsFailed extends UserDetailState {
  @override
  List<Object> get props => [];
}

class GetAllUsers extends UserDetailState {
  final List<UserDetailsModel> model;

  const GetAllUsers({required this.model});
  @override
  List<Object> get props => [];
}

class GetAllUsersFailed extends UserDetailState {
  final String message;

  const GetAllUsersFailed({required this.message});
  @override
  List<Object> get props => [];
}

class GetUserPartners extends UserDetailState {
  final List partner;

  const GetUserPartners({required this.partner});
  @override
  List<Object> get props => [partner];
}

class GetUserPartnersFailed extends UserDetailState {
  final String message;
  const GetUserPartnersFailed({required this.message});
  @override
  List<Object> get props => [message];
}
