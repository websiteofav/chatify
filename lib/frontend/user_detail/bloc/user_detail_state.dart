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

class RealTimeDateFetched extends UserDetailState {
  final Stream<QuerySnapshot<Map<String, dynamic>>> snapshot;

  const RealTimeDateFetched({required this.snapshot});
  @override
  List<Object> get props => [snapshot];
}

class RealTimeDateFetchingFailed extends UserDetailState {
  final String message;
  const RealTimeDateFetchingFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class RealTimeMessageFetched extends UserDetailState {
  final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshot;

  const RealTimeMessageFetched({required this.snapshot});
  @override
  List<Object> get props => [snapshot];
}

class RealTimeMessageFetchingFailed extends UserDetailState {
  final String message;
  const RealTimeMessageFetchingFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class ChatMessageAdded extends UserDetailState {
  const ChatMessageAdded();
  @override
  List<Object> get props => [];
}

class ChatMessageAddedFailed extends UserDetailState {
  final String message;
  const ChatMessageAddedFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class OldMessagesRemoved extends UserDetailState {
  const OldMessagesRemoved();

  @override
  List<Object> get props => [];
}

class OldMessagesRemovedFailed extends UserDetailState {
  final String message;
  const OldMessagesRemovedFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FileUploadedToStorage extends UserDetailState {
  final String downloadUrl;

  const FileUploadedToStorage({required this.downloadUrl});

  @override
  List<Object> get props => [];
}

class FileUploadedToStorageFaield extends UserDetailState {
  final String message;
  const FileUploadedToStorageFaield({required this.message});
  @override
  List<Object> get props => [message];
}
